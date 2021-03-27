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
            WHERE (csc_id = NEW.csc_id AND launch_date = NEW.launch_date AND date = NEW.date) AND
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
    cid := (
        SELECT DISTINCT cust_id
            FROM Registers as r NATURAL JOIN Owns_Credit_Cards NATURAL JOIN Customers as c
            WHERE NEW.card_number = card_number
    );

    credit_cards := (
        SELECT DISTINCT card_number
        FROM Owns_Credit_Cards
        WHERE cid = cust_id
    );

    counter := (
        SELECT COALESCE(COUNT(*), 0)
        FROM Registers as r NATURAL JOIN Sessions as s NATURAL JOIN Course_Offerings as co
        WHERE card_number IN (SELECT * FROM credit_cards)
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