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
            FROM Registers as r NATURAL JOIN Owns_Credit_Cards NATURAL JOIN Customers as c
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
    total_capacity := (SELECT SUM(seating_capacity)
                        FROM Sessions as s NATURAL JOIN Rooms as r
                        WHERE NEW.course_id = s.course_id AND
                            NEW.launch_date = s.launch_date AND
                            NEW.sid = s.sid);

    UPDATE Offerings SET seating_capacity = total_capacity;

END
$$ LANGUAGE plpgsql;

CREATE TRIGGER SEATING_CAPACITY_COURSE_EQUAL_SUM_OF_SESSIONS_TRIGGER
AFTER INSERT OR UPDATE OR DELETE ON Sessions
FOR EACH ROW EXECUTE FUNCTION SEATING_CAPACITY_COURSE_EQUAL_SUM_OF_SESSIONS();

/* ============================================================================================================ */

