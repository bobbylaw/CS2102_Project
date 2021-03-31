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

CREATE OR REPLACE FUNCTION EACH_COURSE_AT_MOST_ONE_REGISTER_BEFORE_REG_DEADLINE_PER_CUSTOMER()
RETURNS TRIGGER AS $$
DECLARE
    counter INTEGER;
    cid text;
    credit_cards record;
BEGIN
    /* only credit cards that exist in registers are joined, only expecting 1 to return */
    /* because card_number is tagged to one person */
    cid := (
        SELECT DISTINCT cust_id
            FROM (Registers NATURAL JOIN Owns_Credit_Cards) as rcc JOIN Customers as c ON rcc.cust_id = c.cust_id
            WHERE NEW.card_number = card_number
    );

    /* all of the credit cards this particular customer owns */
    credit_cards := (
        SELECT DISTINCT card_number
        FROM Owns_Credit_Cards
        WHERE cust_id in (SELECT cust_id FROM cid)
    );

    counter := (
        SELECT COALESCE(COUNT(*), 0)
        FROM Registers as r NATURAL JOIN Sessions as s NATURAL JOIN Course_Offerings as co
        WHERE card_number IN (SELECT card_number FROM credit_cards)
            AND NEW.date < registration_deadline
    );

    IF(counter <> 0) THEN
        RAISE EXCEPTION 'A Customer can only register for atmost one session from an offered course!';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER EACH_CSE_AT_MOST_ONCE_BEFORE_REG_DEADLINE_PER_CUSTOMER_TRIGGER
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION EACH_COURSE_AT_MOST_ONE_REGISTER_BEFORE_REG_DEADLINE_PER_CUSTOMER();

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
BEGIN

    total_capacity := (SELECT SUM(COALESCE(seating_capacity, 0))
                    FROM Sessions as s NATURAL JOIN Rooms as r
                    WHERE (s.course_id, s.launch_date) IN (SELECT s2.course_id, s2.launch_date
                            FROM Sessions as s2
                            WHERE NEW.rid = s2.rid));

    UPDATE Offerings SET seating_capacity = total_capacity 
        WHERE (course_id, launch_date) IN (SELECT s2.course_id, s2.launch_date
                FROM Sessions as s2
                WHERE NEW.rid = s2.rid);

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
    before_add_capacity INTEGER;
BEGIN
    avail_capacity := (SELECT o.seating_capacity
                        FROM registers as r NATURAL JOIN Sessions as s NATURAL JOIN Offerings as o
                        WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date AND
                            NEW.sid = sid);

    /* this works because Sessions is a weak entity set to Offerings */
    before_add_capacity := (SELECT COUNT(*)
                            FROM Registers
                            WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date AND
                            NEW.sid = sid);
    
    IF (avail_capacity - before_add_capacity <= 0) THEN
        RAISE EXCEPTION 'Course offering is fully booked!';
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER CSE_OFFERING_AVAIL_TRIGGER
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION CSE_OFFERING_AVAIL();