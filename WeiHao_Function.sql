-- register_session: This routine is used when a customer requests to register for a session in a course offering. 
-- The inputs to the routine include the following: customer identifier, course offering identifier, session number, and payment method (credit card or redemption from active package).
-- If the registration transaction is valid, this routine will process the registration with the necessary updates (e.g., payment/redemption).

-- It is given that if the payment method is redeems, it is from an active package so not need to check for inactive package.
CREATE OR REPLACE PROCEDURE register_sessions(IN customer_id INTEGER, IN course_identifier INTEGER, IN offering_launch_date DATE, IN session_id INTEGER, payment_method TEXT)
AS $$
DECLARE
    curs CURSOR FOR (SELECT card_number FROM Owns_credit_cards WHERE Owns_credit_cards.cust_id = customer_id);
    r RECORD;
    is_redeem INTEGER;
    is_register INTEGER;
    customer_cc_num TEXT;
    redeem_package_id INTEGER;
    package_purchase_date DATE;
BEGIN
    is_redeem := 0;
    is_register := 0;

    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;

        SELECT COUNT(*) INTO is_redeem  -- Check whether custoemr redeems or purchase the session
        FROM Redeems
        WHERE Redeems.course_id = course_identifier 
        AND Redeems.launch_date = offering_launch_date 
        AND Redeems.card_number = r.card_number;

        SELECT COUNT(*) INTO is_register
        FROM Registers
        WHERE Registers.course_id = course_identifier
        AND Registers.launch_date = offering_launch_date
        AND Registers.card_number = r.card_number;

        IF is_redeem > 0 OR is_register > 0 THEN
            CLOSE curs;
            RAISE EXCEPTION 'This customer has already redeem or register for this course offering';
        END IF;
    END LOOP;
    CLOSE curs;
    
    SELECT card_number INTO customer_cc_num FROM Owns_credit_cards 
    WHERE Owns_credit_cards.cust_id = customer_id 
    LIMIT 1; -- If customer has multiple cc card then we choose the first.

    IF payment_method = 'credit card' THEN -- insert into register table.
        INSERT INTO Registers VALUES (customer_cc_num, course_identifier, offering_launch_date, session_id, CURRENT_DATE);
    ELSIF payment_method = 'redemption' THEN -- insert into redeems table
        SELECT package_id INTO redeem_package_id FROM Buys
        WHERE Buys.card_number = customer_cc_num
        AND num_of_redemption > 0;

        SELECT purchase_date INTO package_purchase_date FROM Buys
        WHERE Buys.card_number = customer_cc_num
        AND num_of_redemption > 0;

        INSERT INTO Redeems VALUES (customer_cc_num, redeem_package_id, package_purchase_date, course_identifier, offering_launch_date, session_id, CURRENT_DATE);

        UPDATE Buys SET num_of_redemption = num_of_redemption - 1
        WHERE card_number = customer_cc_num
        AND package_id = redeem_package_id
        AND purchase_date = package_purchase_date;
    ELSE
        RAISE EXCEPTION 'Payment method has to be stated in credit card or redemption';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- find_instructors: This routine is used to find all the instructors who could be assigned to teach a course session. 
-- The inputs to the routine include the following: course identifier, session date, and session start hour. 
-- The routine returns a table of records consisting of employee identifier and name.
CREATE OR REPLACE FUNCTION find_instructors(IN course_id1 INTEGER, IN session_date1 DATE, IN start_time1 TIME) -- Is it suppose to be start_time or launch_date because launch date is the PK
RETURNS TABLE(eid INT, name TEXT) AS $$
DECLARE
    curs CURSOR FOR (SELECT Employees.eid, Employees.name FROM Employees -- Instructors can teach course_id1 and avaliable on session_date1
        WHERE Employees.eid IN (
            SELECT Instructors.eid FROM Instructors
                WHERE Instructors.course_area = (SELECT Courses.name FROM Courses WHERE Courses.course_id = course_id1)
        )
        AND Employees.depart_date IS NULL -- Meaning the employees is still in the company.
    );
    r RECORD;
    is_unavail INTEGER;
    course_duration INTERVAL;
BEGIN
    SELECT duration INTO course_duration
    FROM Courses
    WHERE Courses.course_id = course_id1;

    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        
        SELECT COUNT(*) INTO is_unavail FROM Sessions -- Instructor already has a session clashing with the start_time
        WHERE r.eid = Sessions.eid 
        AND (start_time1, start_time1 + course_duration) OVERLAPS ((Sessions.start_time - INTERVAL '1 hour'), (Sessions.end_time + INTERVAL '1 hour'))
        AND session_date1 = Sessions.session_date
        AND course_id1 = Sessions.course_id; -- This might be redundant but no harm putting. Safer.

        IF is_unavail = 0 THEN
            eid := r.eid;
            name := r.name;
            RETURN NEXT;
        END IF;
    END LOOP;
    CLOSE curs;
END;
$$ LANGUAGE plpgsql;

/*
Explanation and Implementation
1. I have to find employees that are an instructor who are able to teach the course AND the date of the session has to during his time in the company.
    Implementation: I filter the instructor who is able to teach the course then I filter the employees' join date and start date with the session date.
2. Now there might be clash in timing with the instructor existing session and the new session. So I have to find out which instructor has this clash
    Implementation: I filter out the all the sessions where new session start time clashes with the sessions that has the same date, course_id and
                        taught by the instructor I filtered earlier. If it clashes means the filtered instructor is not available, so i set to 0.
*/




/*
get_available_instructors :
This routine is used to retrieve the availability information of instructors who could be assigned to teach a specified course. 
The inputs to the routine include the following: course identifier, start date, and end date. 
The routine returns a table of records consisting of the following information: 
employee identifier, name, total number of teaching hours that the instructor has been assigned for this month, day (which is within the input date range [start date, end date]), 
and an array of the available hours for the instructor on the specified day. The output is sorted in ascending order of employee identifier and day, 
and the array entries are sorted in ascending order of hour
*/

CREATE OR REPLACE FUNCTION get_available_instructors(IN course_id INTEGER, IN start_date DATE, IN end_date DATE)
RETURNS TABLE(eid INTEGER, total_teaching_hours INTERVAL, month INTEGER, day INTEGER, available_hours TIME[]) AS $$ -- Or use [] for array?
DECLARE
    curs CURSOR FOR (SELECT eid, name FROM Employees
        WHERE Employees.eid IN (
            SELECT eid FROM Instructors
                WHERE Instructors.course_area = (SELECT name FROM Courses WHERE Courses.course_id = NEW.course_id1)
        )
        ORDER BY eid ASC
    );
    r RECORD;
    start_date_helper DATE;
    start_time_helper TIME;
    is_avail INTEGER;
    total_teaching_hours_helper INTEGER;
    available_hours_helper TIME[] DEFAULT '{}'; -- Stackoverflow xD
BEGIN
    start_date_helper := NEW.start_date;
    start_time_helper := '09:00:00';
    is_avail := 1;
    total_teaching_hours_helper := '0 hour';

    OPEN curs;
    LOOP
        FETCH curs INTO r;
        EXIT WHEN NOT FOUND;
        LOOP
            EXIT WHEN start_date_helper = NEW.end_date;

            is_avail := 1;

            SELECT SUM(end_time - start_time) INTO total_teaching_hours_helper FROM Sessions
            WHERE Sessions.course_id = NEW.course_id
            AND Sessions.eid = r.eid
            AND EXTRACT(Month FROM start_date_helper) = EXTRACT(Month FROM Sessions.session_date);

            IF start_time_helper = '18:00:00' THEN -- 6pm no more lessons.
                IF array_length(available_hours_helper, 1) > 0 THEN
                    eid := r.eid;
                    total_teaching_hours := total_teaching_hours_helper;
                    SELECT EXTRACT(Month FROM start_date_helper) INTO month;
                    SELECT EXTRACT(Day FROM start_date_helper) INTO day;
                    available_hours := available_hours_helper;
                    RETURN NEXT;
                END IF;
                start_time_helper := '09:00:00'; -- Earliest lesson at 9
                start_date_helper := start_date_helper + INTERVAL '1 day'; -- Next day
            ELSIF start_time_helper = '12:00:00' THEN
                start_time_helper := '14:00:00';
            ELSE
                SELECT 0 INTO is_avail FROM Sessions 
                WHERE Sessions.course_id = NEW.course_id
                AND Session.eid = r.eid
                AND Sessions.session_date = start_date_helper
                AND (start_time_helper BETWEEN (Sessions.start_time - INTERVAL '1 hour') AND (Sessions.end_time + INTERVAL '1 hour'))
                LIMIT 1; -- In case of multiple entry.

                IF is_avail = 1 THEN
                    SELECT ARRAY_APPEND(available_hours, start_time_helper) INTO available_hours;
                END IF;
                start_time_helper := start_time_helper + INTERVAL '1 hour';
            END IF;
        END LOOP;
        start_date_helper := NEW.start_date;
        start_time_helper := '09:00:00';
    END LOOP;
    CLOSE curs;

END;
$$ LANGUAGE plpgsql;
/* Explanation and Implementation:
1. I have to find instructors who are able to teach the course.
    Implementation: It is done in the cursor. I filter out the employees who are instructor and are able to teach that course. (eid asc order)
2. For each day from start_date and end_date, I need to check each instructors (which is filtered already) avaliable HOURS.
    Implementation: There is 2 loops. Outer loop is loop through the cursor. Outer loop is loop through the date and time.
        There is nothing much about the outer loop. So for the inner loop, I always calculate the total_work_hour for that month before any checking.
        The start_date and end_date might stretch across 2 months or more. So there is a possbility that the total_work_hour is different for each iteration.
        So the IF in the first if-else clause is to transition to the next day and add an entry into the table if there is avaliable hours during that day.
        The ElSIF is to transition from 12pm to 2pm because that's the break time.
        The else in the first if-else clause is to check whether there is any hours that the instructor is free on that day. So the select query help me
        check if the instructor is avaliable for that HOUR.
        So if the instructor is avaliable on that hour, i append to the avaliable_hours array.
        The loop only ends after start_date is equal to end_date. Then I proceed do the same for the next filtered instructor.
*/




/*
cancel_registration: This routine is used when a customer requests to cancel a registered course session. 
The inputs to the routine include the following: customer identifier, and course offering identifier. 
If the cancellation request is valid, the routine will process the request with the necessary updates.
*/

-- change customer_id to email. => I can't because cancels need this customer ID
-- A customer can ONLY have 1 register/redeems for each COURSE OFFERING.
-- For each course offered by the company, a customer can register for at most one of its sessions before its registration deadline
-- cancel 1 of the sessions.
CREATE OR REPLACE PROCEDURE cancel_registration(IN customer_id INTEGER, IN course_identifier INTEGER, IN offering_launch_date DATE)
AS $$
DECLARE
    curs1 CURSOR FOR (SELECT card_number FROM Owns_credit_cards WHERE Owns_credit_cards.cust_id = customer_id);
    r RECORD;
    is_redeem INTEGER;
    is_register INTEGER;
    course_offering_price NUMERIC(12,2);
    session_id INTEGER;
BEGIN
    is_redeem := 0;
    is_register := 0;
    course_offering_price := 0;

    SELECT fees INTO course_offering_price -- Get the price of the course session/offerings. Its the same.
    FROM Offerings
    WHERE Offerings.course_id = course_identifier
    AND Offerings.launch_date = offering_launch_date;

    OPEN curs1;
    LOOP
        FETCH curs1 INTO r;
        EXIT WHEN NOT FOUND;

        SELECT COUNT(*) INTO is_redeem  -- Check whether custoemr redeems or purchase the session
        FROM Redeems
        WHERE Redeems.course_id = course_identifier 
        AND Redeems.launch_date = offering_launch_date 
        AND Redeems.card_number = r.card_number
        AND CURRENT_DATE - Redeems.purchase_date <= 7;

        SELECT COUNT(*) INTO is_register
        FROM Registers
        WHERE Registers.course_id = course_identifier
        AND Registers.launch_date = offering_launch_date
        AND Registers.card_number = r.card_number
        AND CURRENT_DATE - Registers.registration_date <= 7;

        IF (is_redeem > 0) THEN
            SELECT sid INTO session_id FROM Redeems
            WHERE Redeems.course_id = course_identifier 
            AND Redeems.launch_date = offering_launch_date 
            AND Redeems.card_number = r.card_number
            AND CURRENT_DATE - Redeems.purchase_date <= 7
            LIMIT 1; -- There is suppose to be only 1 entry but just to be safe.

            INSERT INTO Cancels
            VALUES (customer_id, course_identifier, offering_launch_date, session_id, CURRENT_DATE, 0, 1); 

        ELSIF (is_register > 0) THEN
            SELECT sid INTO session_id
            FROM Registers
            WHERE Registers.course_id = course_identifier
            AND Registers.launch_date = offering_launch_date
            AND Registers.card_number = r.card_number
            AND CURRENT_DATE - Registers.registration_date <= 7
            LIMIT 1; -- There is suppose to be only 1 entry but just to be safe.

            INSERT INTO Cancels
            VALUES (customer_id, course_identifier, offering_launch_date, session_id, CURRENT_DATE, 0.9 * course_offering_price, 0);
        END IF;
    END LOOP;
    CLOSE curs1;
END;
$$ LANGUAGE plpgsql;

/*
update_instructor: This routine is used to change the instructor for a course session. 
The inputs to the routine include the following: course offering identifier, session number, and identifier of the new instructor. 
If the course session has not yet started and the update request is valid, the routine will process the request with the necessary updates.
*/

-- CALL cancel_registration(2, 1, DATE '2020-01-01');

-- DELETE FROM Cancels;
-- SELECT * FROM Cancels;

-- SELECT * FROM Registers;
-- SELECT * FROM redeems;
-- SELECT * FROM buys;

-- CALL register_sessions(2, 1, DATE '2020-01-01', 1, 'redemption');

CREATE OR REPLACE PROCEDURE update_instructor(IN course_identifier INTEGER, IN offering_launch_date DATE, IN session_id INTEGER, IN new_eid INTEGER)
AS $$
DECLARE
    course_session_start_time TIME;
    course_session_date DATE;
BEGIN
    SELECT start_time INTO course_session_start_time
    FROM Sessions
    WHERE Sessions.course_id = course_identifier
    AND Sessions.launch_date = offering_launch_date
    AND Sessions.sid = session_id;
	
	SELECT session_date INTO course_session_date
    FROM Sessions
    WHERE Sessions.course_id = course_identifier
    AND Sessions.launch_date = offering_launch_date
    AND Sessions.sid = session_id;
	
    IF (CURRENT_TIME < course_session_start_time) AND (CURRENT_DATE <= course_session_date) THEN
        UPDATE Sessions
        SET eid = new_eid
        WHERE Sessions.course_id = course_identifier
        AND Sessions.launch_date = offering_launch_date
        AND Sessions.sid = session_id;
    ELSE
        RAISE EXCEPTION 'The course session has started';
    END IF;
END;
$$ LANGUAGE plpgsql;


/*
update_room: This routine is used to change the room for a course session.
The inputs to the routine include the following: course offering identifier, session number, and identifier of the new room.
If the course session has not yet started and the update request is valid, the routine will process the request with the necessary updates.
Note that update request should not be performed if the number of registrations for the session exceeds the seating capacity of the new room.
*/

CREATE OR REPLACE PROCEDURE update_room(IN course_identifier INTEGER, IN offering_launch_date DATE, IN session_id INTEGER, IN new_rid INTEGER)
AS $$
DECLARE
    course_session_start_time TIME;
    course_session_date DATE;
    new_room_seating_capacity INTEGER;
    num_of_registration INTEGER;
BEGIN
    SELECT start_time INTO course_session_start_time
    FROM Sessions
    WHERE Sessions.course_id = course_identifier
    AND Sessions.launch_date = offering_launch_date
    AND Sessions.sid = session_id;

    SELECT session_date INTO course_session_date
    FROM Sessions
    WHERE Sessions.course_id = course_identifier
    AND Sessions.launch_date = offering_launch_date
    AND Sessions.sid = session_id;

    SELECT seating_capacity INTO new_room_seating_capacity
    FROM Rooms
    WHERE Rooms.rid = new_rid;

    SELECT COUNT(*) INTO num_of_registration
    FROM Registers
    WHERE Registers.course_id = course_identifier
    AND Registers.launch_date = offering_launch_date
    AND Registers.sid = session_id;

    IF (CURRENT_DATE <= course_session_date) AND (CURRENT_TIME < course_session_start_time)
        AND (num_of_registration > new_room_seating_capacity) THEN
            UPDATE Sessions
            SET rid = new_rid
            WHERE Sessions.course_id = course_identifier
            AND Sessions.launch_date = offering_launch_date
            AND Sessions.sid = session_id;
    ELSE
        RAISE EXCEPTION 'The course probably has started or the new room doesnt have enough seating capacity';
    END IF;
END;
$$ LANGUAGE plpgsql
