--  An instructor who is assigned to teach a course session must be specialized in that course area.

CREATE OR REPLACE FUNCTION valid_course_instructor_assignment_func()
RETURNS TRIGGER AS
$$
DECLARE
    session_course_area TEXT;
BEGIN
    SELECT name INTO session_course_area
    FROM Courses
    WHERE Courses.course_id = NEW.course_id;

    IF NEW.course_area = session_course_area THEN
        RETURN NEW;
    ElSE
        RETURN NULL;
    END IF;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER valid_course_instructor_assignment
BEFORE INSERT OR UPDATE
ON Sessions
FOR EACH ROW
EXECUTE FUNCTION valid_course_instructor_assignment_func();

-- Each instructor can teach at most one course session at any hour.

CREATE OR REPLACE FUNCTION check_instructor_overlap_session_func()
RETURNS TRIGGER AS
$$
DECLARE
    curs CURSOR FOR (SELECT * FROM Sessions WHERE NEW.eid = Sessions.eid);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF (NEW.start_time BETWEEN r.start_time AND r.end_time) OR
            (NEW.end_time BETWEEN r.start_time and r.end_time) THEN
                CLOSE curs;
                RETURN NULL;
        END IF;
    END LOOP;
    CLOSE curs;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_instructor_overlap_session
BEFORE INSERT OR UPDATE
ON Sessions
FOR EACH ROW
EXECUTE FUNCTION check_instructor_overlap_session_func();

-- Each instructor must not be assigned to teach two consecutive course sessions

CREATE OR REPLACE FUNCTION check_consec_course_session_func()
RETURNS TRIGGER AS
$$
DECLARE
    curs CURSOR FOR (SELECT * FROM Session WHERE Session.session_date = NEW.session_date AND Session.eid = NEW.eid);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF ((AGE(NEW.start_time, r.start_time) => INTERVAL '0 hour') AND
            (AGE(NEW.start_time, r.end_time) < INTERVAL '1 hour')) OR
            ((AGE(NEW.end_time, r.start_time) <= INTERVAL '0 hour') AND
            (AGE(r.start_time, NEW.end_time) < INTERVAL '1 hour')) THEN
            CLOSE curs;
            RETURN NULL;
        END IF;
    END LOOP;
    CLOSE curs;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_consec_course_session
BEFORE INSERT OR UPDATE
ON Sessions
FOR EACH ROW
EXECUTE FUNCTION check_consec_course_session_func();

--  Each part-time instructor must not teach more than 30 hours for each month.

CREATE OR REPLACE FUNCTION max_consec_course_session_func()
RETURNS TRIGGER AS
$$
DECLARE
    curs CURSOR FOR (SELECT * FROM Session WHERE Session.eid = NEW.eid and NEW.eid IN (SELECT eid FROM Part_time_instructors));
    r RECORD;
    total_work_hours INTERVAL;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        total_work_hours:= total_work_hours +  AGE(r.end_time, r.start_time);
    END LOOP;
    CLOSE curs;

    IF total_work_hours <= INTERVAL '30 hours' THEN
        RETURN NEW;
    ELSE
        RETURN NULL;
    END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER max_work_hour
BEFORE INSERT OR UPDATE
ON Sessions
FOR EACH ROW
EXECUTE FUNCTION max_consec_course_session_func();