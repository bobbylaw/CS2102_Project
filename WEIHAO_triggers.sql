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
        RAISE EXCEPTION 'An instructor who is assigned to teach a course session must be specialized in that course area.';
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
    curs CURSOR FOR (SELECT * FROM Sessions WHERE Sessions.session_date = NEW.session_date AND NEW.eid = Sessions.eid);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF (NEW.start_time, NEW.end_time) OVERLAPS (r.start_time, r.end_time) THEN
                CLOSE curs;
                RAISE EXCEPTION 'Instructor can teach at most one course session at any hour';
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
    curs CURSOR FOR (SELECT * FROM Sessions WHERE Sessions.session_date = NEW.session_date AND Sessions.eid = NEW.eid);
    r RECORD;
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        IF ((NEW.start_time - r.start_time >= INTERVAL '0 hour') AND
            (NEW.start_time- r.end_time < INTERVAL '1 hour')) OR
            ((NEW.end_time - r.start_time <= INTERVAL '0 hour') AND
            (r.start_time - NEW.end_time < INTERVAL '1 hour')) THEN
            CLOSE curs;
            RAISE EXCEPTION 'No instructor can be assigned to teach two consecutive course sessions';
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

CREATE OR REPLACE FUNCTION max_work_hour_func()
RETURNS TRIGGER AS
$$
DECLARE
    curs CURSOR FOR (SELECT * FROM Sessions WHERE Sessions.eid = NEW.eid AND NEW.eid IN (SELECT eid FROM Part_time_instructors)
        AND EXTRACT(month from Sessions.session_date) = EXTRACT(month FROM NEW.session_date));
    r RECORD;
    total_work_hours INTERVAL;
BEGIN
    total_work_hours:= INTERVAL '0 hours';
    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        total_work_hours:= total_work_hours +  (r.end_time - r.start_time);
    END LOOP;
    CLOSE curs;

    total_work_hours := total_work_hours + (NEW.end_time - NEW.start_time);
    IF total_work_hours <= INTERVAL '30 hours' THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Each part-time instructor must not teach more than 30 hours for each month.';
    END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER max_work_hour
BEFORE INSERT OR UPDATE
ON Sessions
FOR EACH ROW
EXECUTE FUNCTION max_work_hour_func();






/*
Test for valid_course_instructor_assignment_func()
-- INSERT INTO Employees VALUES (1, 'John', 'Bedok', 'John@gmail.com', '2021-05-01', '2021-04-01', 90909090);
-- INSERT INTO Full_time_Emp VALUES (1, (2000, 'monthly'));
-- INSERT INTO Managers VALUES (1);

-- INSERT INTO course_areas VALUES ('Math', 1);
-- INSERT INTO courses VALUES (1, 'Math', 'Math 1', 60);


-- INSERT INTO Employees VALUES (2, 'James', 'Tampines', 'James@gmail.com', '2021-05-01', '2021-04-01', 80808080);
-- INSERT INTO Full_time_Emp VALUES (2, (1800, 'monthly'));
-- INSERT INTO Administrators VALUES (2);

-- INSERT INTO Offerings VALUES (1, '2020-01-01', '2020-02-19', 2, '2020-06-01', '2020-02-01', 200, 200, 15.99);

-- INSERT INTO Employees VALUES (3, 'Jane', 'Pasir Ris', 'Jane@gmail.com', '2021-05-01', '2021-04-01', 70707070);
-- INSERT INTO Full_time_Emp VALUES (3, (1500, 'monthly'));
-- INSERT INTO Instructors VALUES (3, 'Math');
-- INSERT INTO Full_time_instructors VALUES (3, 'Math');

-- INSERT INTO Rooms VALUES (1, 'Office1', 300);
-- INSERT INTO Sessions VALUES (1, '2020-01-01', 'Math', 1, 3, 1, '2020-04-15', '2020-04-14 09:00:00', '2020-04-14 11:00:00');

-- INSERT INTO Employees VALUES (4, 'Kevin', 'Woodland', 'Kevin@gmail.com', '2021-05-01', '2021-04-01', 60606060);
-- INSERT INTO Full_time_Emp VALUES (4, (2000, 'monthly'));
-- INSERT INTO Managers VALUES (4);
-- INSERT INTO course_areas VALUES ('Science', 4);
-- INSERT INTO courses VALUES (4, 'Science', 'Science 1', 60);

-- c
-- INSERT INTO Full_time_Emp VALUES (5, (1500, 'monthly'));
-- INSERT INTO Instructors VALUES (5, 'Science');
-- INSERT INTO Full_time_instructors VALUES (5, 'Science');

-- INSERT INTO Sessions VALUES (1, '2020-01-01', 'Science', 1, 5, 2, '2020-04-15', '2020-04-14 09:00:00', '2020-04-14 11:00:00');

SELECT * FROM Sessions;

*/


/*
-- check_instructor_overlap_session_func()
-- INSERT INTO Sessions VALUES (1, '2020-01-01', 'Math', 1, 3, 3, '2020-04-15', '2020-04-14 14:00:00', '2020-04-14 17:00:00');
*/

/*
-- INSERT INTO Sessions VALUES (1, '2020-01-01', 'Math', 1, 3, 3, '2020-04-15', '2020-04-14 16:00:00', '2020-04-14 17:00:00');
-- INSERT INTO Sessions VALUES (1, '2020-01-01', 'Math', 1, 3, 3, '2020-04-15', '2020-04-14 14:00:00', '2020-04-14 15:00:00');

-- INSERT INTO Sessions VALUES (1, '2020-01-01', 'Math', 1, 3, 3, '2020-04-15', '2020-04-14 17:00:00', '2020-04-14 18:00:00');
Last insert suppose to work.
*/

