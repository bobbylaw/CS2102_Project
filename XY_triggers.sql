/* === No two sessions for the same course offering can be conducted on the same day and at the same time. === */
/* ============== CHECKS BASED ON DRAWING IN ./drawings IF THERE'S SUCH A SESSION THAT EXISTS ============== */
CREATE OR REPLACE FUNCTION NO_SESS_SAME_CSE_SAME_DAY_AND_TIME()
RETURNS TRIGGER AS $$
DECLARE
    counter INTEGER;
    sid_val INTEGER;
BEGIN
    counter := (SELECT COALESCE(COUNT(*), 0)
                FROM Sessions
                WHERE (csc_id = NEW.csc_id AND launch_date = NEW.launch_date AND date = NEW.date) AND
                    ((NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time < end_time) OR
                    (NEW.start_time > start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time) OR
                    (NEW.start_time >= start_time AND NEW.start_time <= end_time AND NEW.end_time >= start_time AND NEW.end_time <= end_time) OR
                    (NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time)
                    ));
    
    sid_val := (SELECT sid
            FROM Sessions
            WHERE (csc_id = NEW.csc_id AND launch_date = NEW.launch_date AND date = NEW.date) AND
                ((NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time < end_time) OR
                (NEW.start_time > start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time) OR
                (NEW.start_time >= start_time AND NEW.start_time <= end_time AND NEW.end_time >= start_time AND NEW.end_time <= end_time) OR
                (NEW.start_time < start_time AND NEW.start_time < end_time AND NEW.end_time > start_time AND NEW.end_time > end_time)
                ));
    IF(counter > 0) THEN
        RAISE NOTICE 'Clashes with (%)', sid_val;
        RETURN NULL;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER NO_SESS_SAME_CSE_SAME_DAY_AND_TIME_TRIGGER
BEFORE INSERT OR UPDATE ON Sessions
FOR EACH ROW EXECUTE FUNCTION NO_SESS_SAME_CSE_SAME_DAY_AND_TIME();
/* ============================================================================================================ */

CREATE OR REPLACE FUNCTION NO_SESS_SAME_CSE_SAME_DAY_AND_TIME()
RETURNS TRIGGER AS $$
DECLARE
    counter INTEGER;
    sid_val INTEGER;
BEGIN

END
$$ LANGUAGE plpgsql;

CREATE TRIGGER NO_SESS_SAME_CSE_SAME_DAY_AND_TIME_TRIGGER
BEFORE INSERT OR UPDATE ON Sessions
FOR EACH ROW EXECUTE FUNCTION NO_SESS_SAME_CSE_SAME_DAY_AND_TIME();