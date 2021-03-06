/* === No two sessions for the same course offering can be conducted on the same day and at the same time. === */
/* ============== CHECKS BASED ON DRAWING IN ./drawings IF THERE'S SUCH A SESSION THAT EXISTS ============== */
CREATE OR REPLACE FUNCTION NO_SESS_SAME_CSE_SAME_DAY_AND_TIME()
RETURNS TRIGGER AS $$
DECLARE
    counter INTEGER;
BEGIN
    counter := (
        SELECT COALESCE(COUNT(*), 0)
            FROM Sessions
            WHERE (course_id = NEW.course_id AND launch_date = NEW.launch_date AND session_date = NEW.session_date) AND
                ((NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time <= end_time) OR
                (NEW.start_time >= start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time) OR
                (NEW.start_time >= start_time AND NEW.start_time <= end_time AND NEW.end_time >= start_time AND NEW.end_time <= end_time) OR
                (NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time)
                )
        );

    IF(counter <> 0) THEN
        RAISE EXCEPTION 'Clashes with existing session(s)!';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER NO_SESS_SAME_CSE_SAME_DAY_AND_TIME_TRIGGER
BEFORE INSERT OR UPDATE ON Sessions
FOR EACH ROW EXECUTE FUNCTION NO_SESS_SAME_CSE_SAME_DAY_AND_TIME();

/* ============================================================================================================ */

CREATE OR REPLACE FUNCTION AT_MOST_ONE_REG_BEFORE_DEADLINE_PER_CUSTOMER()
RETURNS TRIGGER AS $$
DECLARE
    counter INTEGER;
    reg_deadline DATE;
BEGIN

    reg_deadline := (SELECT o.registration_deadline
                        FROM Offerings as o
                        WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date);
    
    IF (NEW.registration_date > reg_deadline) THEN
        RAISE EXCEPTION 'You are registering after the deadline!';
        RETURN NULL;
    END IF;

    counter := (
        SELECT COALESCE(COUNT(card_number), 0) -- this query returns the count of credit cards insert customer owns that exist in registers table AND reg_date < deadline
        FROM Registers as r NATURAL FULL JOIN Redeems as re NATURAL JOIN Sessions as s NATURAL JOIN (SELECT course_id, launch_date, registration_deadline FROM Offerings) as co
        WHERE card_number IN (SELECT DISTINCT occ.card_number -- this subquery gets all the credit cards this customer owns
                FROM Owns_Credit_Cards as occ
                WHERE cust_id in (SELECT DISTINCT rcc.cust_id -- this subquery fetches customers who own NEW.credit card
                    FROM (Registers NATURAL FULL JOIN Redeems NATURAL JOIN Owns_Credit_Cards) as rcc JOIN Customers as c ON rcc.cust_id = c.cust_id
                    WHERE NEW.card_number = card_number))
            AND NEW.registration_date <= registration_deadline
            AND NEW.course_id = course_id
            AND NEW.launch_date = launch_date
    );

    IF(counter <> 0) THEN
        RAISE EXCEPTION 'A Customer can only register or redeems for atmost one session from an offered course!';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER AT_MOST_ONE_REG_BEFORE_DEADLINE_PER_CUSTOMER_TRIGGER
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION AT_MOST_ONE_REG_BEFORE_DEADLINE_PER_CUSTOMER();

/* ============================================================================================================ */

CREATE OR REPLACE FUNCTION SEATING_CAPACITY_COURSE_EQUAL_SUM_OF_SESSIONS()
RETURNS TRIGGER AS $$
DECLARE
    total_capacity INTEGER;
BEGIN
    IF (TG_OP = 'DELETE') THEN
    -- old here means what was deleted
        total_capacity := (SELECT SUM(COALESCE(seating_capacity, 0))
                    FROM Sessions as s NATURAL JOIN Rooms as r
                    WHERE OLD.course_id = s.course_id AND
                        OLD.launch_date = s.launch_date);

        UPDATE Offerings SET seating_capacity = total_capacity 
        WHERE course_id = OLD.course_id 
            AND launch_date = OLD.launch_date;

        RETURN NEW;
    ELSE
        total_capacity := (SELECT SUM(COALESCE(seating_capacity, 0))
                            FROM Sessions as s NATURAL JOIN Rooms as r
                            WHERE NEW.course_id = s.course_id AND
                                NEW.launch_date = s.launch_date);

        UPDATE Offerings SET seating_capacity = total_capacity 
        WHERE course_id = NEW.course_id 
            AND launch_date = NEW.launch_date;

        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER SEATING_CAPACITY_COURSE_EQUAL_SUM_OF_SESSIONS_TRIGGER
AFTER INSERT OR UPDATE OR DELETE ON Sessions
FOR EACH ROW EXECUTE FUNCTION SEATING_CAPACITY_COURSE_EQUAL_SUM_OF_SESSIONS();

CREATE OR REPLACE FUNCTION ROOMS_CAPACITY_CHANGE()
RETURNS TRIGGER AS $$
DECLARE
    total_capacity INTEGER;
    r record;
    curs CURSOR FOR (SELECT SUM(COALESCE(seating_capacity, 0)) as total_capacity, s.course_id, s.launch_date
                    FROM Sessions as s NATURAL JOIN Rooms as r
                    WHERE (s.course_id, s.launch_date, s.sid) IN (SELECT s2.course_id, s2.launch_date, s2.sid
                            FROM Sessions as s2
                            WHERE NEW.rid = s2.rid)
            GROUP BY s.course_id, s.launch_date);
BEGIN

    OPEN curs;
    LOOP
        FETCH curs into r; 
        EXIT WHEN NOT FOUND;

        UPDATE Offerings 
        SET seating_capacity = r.total_capacity 
        WHERE r.course_id = course_id AND r.launch_date = launch_date;

    END LOOP;

    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER ROOMS_CAPACITY_CHANGE_TRIGGER
AFTER UPDATE ON Rooms
FOR EACH ROW EXECUTE FUNCTION ROOMS_CAPACITY_CHANGE();

/* ============================================================================================================ */

CREATE OR REPLACE FUNCTION CSE_OFFERING_AVAIL()
RETURNS TRIGGER AS $$
DECLARE
    avail_capacity INTEGER;
    before_add_capacity_registers INTEGER;
    before_add_capacity_redeems INTEGER;
    before_add_capacity INTEGER;
BEGIN
    avail_capacity := (SELECT o.seating_capacity
                        FROM Offerings as o
                        WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date);

    /* this works because Sessions is a weak entity set to Offerings */
    before_add_capacity_registers := (SELECT COUNT(*)
                            FROM Registers
                            WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date AND 
                            NEW.sid = sid);

    before_add_capacity_redeems := (
        SELECT COUNT(*)
        FROM Redeems
        WHERE NEW.course_id = course_id AND 
        NEW.launch_date = launch_date AND 
        NEW.sid = sid
    );

    before_add_capacity := before_add_capacity_redeems + before_add_capacity_registers;
    
    IF (avail_capacity - before_add_capacity <= 0) THEN
        RAISE EXCEPTION 'Course offering is fully booked!';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER CSE_OFFERING_AVAIL_TRIGGER
BEFORE INSERT ON Registers
FOR EACH ROW EXECUTE FUNCTION CSE_OFFERING_AVAIL();