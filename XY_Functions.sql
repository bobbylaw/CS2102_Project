-- add_customer
/*
This routine is used to add a new customer. 
The inputs to the routine include the following: name, home address, contact number, email address, and credit card details (credit card number, expiry date, CVV code). 
The customer identifier is generated by the system.
*/
CREATE OR REPLACE PROCEDURE add_customer(IN input_cust_name TEXT, IN input_address TEXT, IN input_phone TEXT, IN input_email TEXT, IN input_card_number TEXT, IN input_expiry_date DATE, IN input_CVV INTEGER)
AS $$
DECLARE
    customer_id INTEGER;
BEGIN

    INSERT INTO Customers(name, address, phone, email)
        VALUES (input_cust_name, input_address, input_phone, input_email);

    SELECT c.cust_id into customer_id
        FROM Customers as c
        WHERE input_email = c.email; -- email is unique, so this identifies a unique cust_id

    INSERT INTO Owns_credit_cards(card_number, cust_id, CVV, from_date, expiry_date)
        VALUES(input_card_number, customer_id, input_CVV, NOW(), input_expiry_date);

END
$$ LANGUAGE plpgsql;

-- update_credit_card
/* 
This routine is used when a customer requests to change his/her credit card details. 
The inputs to the routine include the customer identifier and his/her new credit card details (credit card number, expiry date, CVV code).
*/
CREATE OR REPLACE PROCEDURE update_credit_card(IN input_email TEXT, IN input_card_number TEXT, IN input_expiry_date DATE, IN input_CVV INTEGER)
AS $$
DECLARE
    customer_id INTEGER;
BEGIN

    SELECT c.cust_id into customer_id
        FROM Customers as c
        WHERE input_email = c.email; -- email is unique, so this identifies a unique cust_id
    
    UPDATE Owns_credit_cards
        SET card_number = input_card_number,
            CVV = input_CVV,
            expiry_date = input_expiry_date
    WHERE customer_id = cust_id;

END
$$ LANGUAGE plpgsql;

-- get_available_course_sessions
/* 
This routine is used to retrieve all the available sessions for a course offering that could be registered. 
The input to the routine is a course offering identifier. 
The routine returns a table of records with the following information for each available session: session date, session start hour, instructor name, and number of remaining seats for that session. 
The output is sorted in ascending order of session date and start hour.
*/
CREATE OR REPLACE FUNCTION get_available_course_sessions(IN input_course_id INTEGER, IN input_launch_date DATE)
RETURNS TABLE (session_date DATE, start_hour float, instructor_name TEXT, remaining_seats BIGINT)
AS $$
BEGIN

    RETURN query (
        SELECT s.session_date as session_date, EXTRACT(hours from s.start_time) as start_hour, e.name as instructor_name, (o.seating_capacity - COUNT(re.redemption_date) - COUNT(r.card_number)) as remaining_seats
        FROM Registers as r NATURAL FULL JOIN Redeems as re NATURAL FULL JOIN Sessions as s NATURAL FULL JOIN (SELECT course_id, launch_date, start_date, seating_capacity FROM Offerings) as o NATURAL FULL JOIN Instructors as i NATURAL FULL JOIN Employees as e
        GROUP BY s.session_date, s.start_time, e.name, o.seating_capacity, o.course_id, o.launch_date
        HAVING input_course_id = o.course_id AND input_launch_date = o.launch_date AND o.seating_capacity - COUNT(re.redemption_date) - COUNT(r.card_number) > 0
        ORDER BY session_date, start_hour
    );

END
$$ LANGUAGE plpgsql;

-- get_my_registrations
/*
This routine is used when a customer requests to view his/her active course registrations (i.e, registrations for course sessions that have not ended). 
The input to the routine is a customer identifier. 
The routine returns a table of records with the following information for each active registration session: course name, course fees, session date, session start hour, session duration, and instructor name. 
The output is sorted in ascending order of session date and session start hour.
*/

CREATE OR REPLACE FUNCTION get_my_registrations(IN cust_email TEXT)
RETURNS TABLE (course_name TEXT, course_fees NUMERIC(12, 2), session_date DATE, start_hour float, session_duration float, instructor_name TEXT)
AS $$
BEGIN

    RETURN query (
        SELECT cse_name as course_name, COALESCE(o.fees, 0) as course_fees, s.session_date as session_date, EXTRACT(hours from s.start_time) as start_hour, COALESCE(EXTRACT(minutes from (s.end_time - s.start_time)), 0) as session_duration, ename as instructor_name
        FROM Customers as c NATURAL FULL JOIN Owns_credit_cards as occ NATURAL FULL JOIN Buys as b NATURAL FULL JOIN Registers as r NATURAL FULL JOIN Sessions as s NATURAL FULL JOIN (SELECT course_id, launch_date, start_date, seating_capacity, fees, end_date FROM Offerings) as o NATURAL FULL JOIN Instructors as i NATURAL FULL JOIN (SELECT eid, name as ename FROM Employees) as e NATURAL FULL JOIN (SELECT course_id, name as cse_name FROM Courses) as cse
        WHERE cust_email = c.email 
            AND now() <= o.end_date -- not ended condition
            AND b.num_of_redemption > 0 -- is active condition
        ORDER BY session_date, start_hour
    );

END
$$ LANGUAGE plpgsql;

-- update_course_session
/*
This routine is used when a customer requests to change a registered course session to another session. 
The inputs to the routine include the following: customer identifier, course offering identifier, and new session number. 
If the update request is valid and there is an available seat in the new session, the routine will process the request with the necessary updates.
*/

CREATE OR REPLACE PROCEDURE update_course_session(IN input_cust_email TEXT, IN input_course_id INTEGER, IN input_launch_date DATE, IN input_sid INTEGER)
AS $$
DECLARE
    avail_capacity INTEGER;
    old_sid INTEGER;
    customer_card_number TEXT;
BEGIN
    avail_capacity := (SELECT COALESCE((o.seating_capacity - COUNT(r.card_number)), 0) as remaining_seats -- coalesce 0 is if newly chosen session does not exist
                        FROM registers as r NATURAL JOIN Sessions as s NATURAL JOIN (SELECT launch_date, course_id, seating_capacity FROM Offerings) as o
                        GROUP BY o.seating_capacity, course_id, launch_date, sid
                        HAVING input_course_id = course_id AND 
                            input_launch_date = launch_date AND
                            input_sid = sid);
    
    IF (avail_capacity <= 0) THEN -- handles validity and avail check here
        RAISE EXCEPTION 'There isnt an availible seat in the selected session!';
    ELSE
        customer_card_number := (
            SELECT card_number
            FROM Customers as c NATURAL JOIN Owns_Credit_Cards as o
            WHERE c.email = input_cust_email
        );

        old_sid := ( -- allowed because for each course offered by the company, a customer can register for at most one of its sessions before its registration deadline
            SELECT sid
            FROM Registers as r
            WHERE input_course_id = course_id
                AND input_launch_date = launch_date
                AND customer_card_number = card_number
            LIMIT 1
        );

        UPDATE Registers
        SET sid = input_sid
        WHERE old_sid = sid
            AND input_course_id = course_id
            AND input_launch_date = launch_date
            AND customer_card_number = card_number;
    END IF;
END
$$ LANGUAGE plpgsql;

-- remove_session
/*
This routine is used to remove a course session. 
The inputs to the routine include the following: course offering identifier and session number. 
If the course session has not yet started and the request is valid, the routine will process the request with the necessary updates. 
The request must not be performed if there is at least one registration for the session. 
Note that the resultant seating capacity of the course offering could fall below the course offering’s target number of registrations, which is allowed.
*/

CREATE OR REPLACE PROCEDURE remove_session(IN input_course_id INTEGER, IN input_launch_date DATE, IN input_sid INTEGER)
AS $$
DECLARE
    num_registration INTEGER;
    num_redemption INTEGER;
    has_started BOOLEAN;
BEGIN
    num_registration := (
        SELECT COUNT(*)
        FROM Registers
        WHERE input_course_id = course_id
            AND input_launch_date = launch_date
            AND input_sid = sid
    );

    num_redemption := (
        SELECT COUNT(*)
        FROM Redeems
        WHERE input_course_id = course_id
            AND input_launch_date = launch_date
            AND input_sid = sid
    );

    IF (num_registration <> 0 OR num_redemption <> 0) THEN
        RAISE EXCEPTION 'There are existing registrations for this session!';
    END IF;

    has_started := (
        SELECT now() >= s.start_time
        FROM Sessions as s
        WHERE input_course_id = course_id
            AND input_launch_date = launch_date
            AND input_sid = sid
    );

    IF (has_started) THEN
        RAISE EXCEPTION 'Session has already started!';
    ELSE 
        DELETE FROM Sessions
        WHERE input_course_id = course_id
            AND input_launch_date = launch_date
            AND input_sid = sid;
    END IF;
END
$$ LANGUAGE plpgsql;

-- add_session
/*
This routine is used to add a new session to a course offering. 
The inputs to the routine include the following: course offering identifier, new session number, new session day, new session start hour, instructor identifier for new session, and room identifier for new session. 
If the course offering’s registration deadline has not passed and the the addition request is valid, the routine will process the request with the necessary updates.
*/

CREATE OR REPLACE PROCEDURE add_session(IN input_course_id INTEGER, IN input_launch_date DATE, IN input_sid INTEGER, IN input_session_day DATE, IN input_session_start_hour TIME, IN input_instructor_eid INTEGER, IN input_rid INTEGER)
AS $$
DECLARE
    is_valid_session BOOLEAN;
    input_course_area TEXT;
    input_course_duration INTEGER;
BEGIN
    is_valid_session := (
        SELECT input_session_day <= o.registration_deadline
        FROM Offerings as o
        WHERE input_course_id = course_id
            AND input_launch_date = launch_date
    );

    input_course_area := (
        SELECT name
        FROM Courses
        WHERE course_id = input_course_id
    );

    input_course_duration := (
        SELECT duration
        FROM Courses
        WHERE course_id = input_course_id
    );

    IF (is_valid_session) THEN
        INSERT INTO Sessions(course_id, launch_date, course_area, rid, eid, sid, session_date, start_time, end_time)
        VALUES (input_course_id, input_launch_date, input_course_area, input_rid, input_instructor_eid, input_sid, input_session_day, input_session_start_hour, input_session_start_hour + (interval '01:00' * input_course_duration));
    ELSE
        RAISE EXCEPTION 'Input session day is beyond registration deadline!';
    END IF;
END
$$ LANGUAGE plpgsql;

-- popular_courses
/*
This routine is used to find the popular courses offered this year (i.e., start date is within this year). 
A course is popular if 
    the course has at least two offerings this year, 
    and for every pair of offerings of the course this year, 
        the offering with the later start date has a higher number of registrations than that of the offering with the earlier start date. 
The routine returns a table of records consisting of the following information for each popular course: 
    course identifier, course title, course area, number of offerings this year, and number of registrations for the latest offering this year. 
The output is sorted in descending order of the number of registrations for the latest offering this year followed by in ascending order of course identifier.
*/

CREATE OR REPLACE FUNCTION popular_courses_driver()
RETURNS TABLE (output_course_id INTEGER, 
                output_course_title TEXT, 
                output_course_area TEXT, 
                output_number_of_offerings INTEGER, 
                output_num_registration_latest_offering INTEGER)
AS $$
DECLARE
    curs1 CURSOR FOR (
        SELECT DISTINCT course_id, name, title, duration
        FROM Offerings as o NATURAL JOIN Courses as c
        WHERE EXTRACT(years FROM now()) = EXTRACT(years from o.start_date)
        ORDER BY course_id
    );
    r1 record;

    curs2 refcursor;
    r2 record;

    curs3 refcursor;
    r3 record;

    curr_course_id INTEGER;
    curr_course_name TEXT;
    curr_course_title TEXT;
    curr_course_duration INTEGER;

    later_launch_date DATE;
    later_start_date DATE;
    later_num_reg INTEGER;

    earlier_start_date DATE;
    earlier_num_reg INTEGER;

    is_popular BOOLEAN;
    num_offerings INTEGER;

BEGIN
    OPEN curs1; -- this returns offerings that occured this year
    LOOP -- loop through all the courses
        FETCH curs1 into r1;
        EXIT WHEN NOT FOUND;

        is_popular := 1; -- assume course is popular until counter example

        curr_course_id := r1.course_id;
        curr_course_name := r1.name;
        curr_course_title := r1.title;
        curr_course_duration := r1.duration;

        num_offerings := (
            SELECT count(*)
            FROM Offerings as o1
            WHERE curr_course_id = course_id -- select the correct courses
        );

        IF (num_offerings >= 2) THEN -- only allows courses with num_offerings >= 2
            OPEN curs2 FOR ( -- loops through all of offerings that has this course_id
                SELECT *
                FROM Offerings as o1
                WHERE curr_course_id = course_id -- select the correct courses
                ORDER BY start_date
            );

            LOOP
                FETCH curs2 into r2;
                EXIT WHEN NOT FOUND;

                output_course_id := curr_course_id;
                output_course_title := curr_course_title;
                output_course_area := curr_course_name;
                output_number_of_offerings := num_offerings;

                later_start_date := r2.start_date;
                later_launch_date := r2.launch_date;
                later_num_reg := (
                    SELECT COUNT(r.card_number)
                    FROM Registers as r NATURAL JOIN Offerings as o
                    WHERE curr_course_id = course_id -- select the correct courses
                        AND later_launch_date = launch_date -- select the correct offering
                        AND later_start_date = start_date -- select the later start_date
                );

                OPEN curs3 FOR ( -- this curs is for looping through all the offerings with earlier start_dates
                    SELECT *
                    FROM Registers as r NATURAL FULL JOIN Offerings as o -- do full join incase no one registered for offering
                    WHERE curr_course_id = course_id -- select the correct courses
                        AND start_date < later_start_date  -- if start date is earlier
                    ORDER BY start_date
                );

                LOOP -- loops through all earlier start dates
                    FETCH curs3 into r3;
                    EXIT WHEN NOT FOUND;

                    earlier_num_reg := (
                        SELECT COUNT(r.card_number)
                        FROM Registers as r NATURAL FULL JOIN Offerings as o -- do full join incase no one registered for offering
                        WHERE curr_course_id = course_id -- select the correct courses
                            AND r3.launch_date = launch_date -- select correct offering
                            AND r3.start_date = start_date  -- select the corresponding earlier start date
                    );

                    IF (earlier_num_reg >= later_num_reg) THEN -- since we want all later_num_reg > earlier_num_reg, counter eg is when later_num_reg <= earlier_num_reg
                        is_popular := 0; -- counter example found when there exist an earlier offering with more or equals number_of_registration
                    END IF;
                    
                END LOOP;
                CLOSE curs3;

                output_num_registration_latest_offering := later_num_reg; -- this is guranteeed to be latest offering as curs2 is sorted by start_date
            END LOOP;
            CLOSE curs2;

            IF (is_popular) THEN
                RETURN NEXT; -- if it went through all the pairs and haven't found a counter example, then insert into answer
            END IF;

        END IF;

    END LOOP;
    CLOSE curs1;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION popular_courses() -- wrapper function so orderby ezpz
RETURNS TABLE (output_course_id INTEGER, 
                output_course_title TEXT, 
                output_course_area TEXT, 
                output_number_of_offerings INTEGER, 
                output_num_registration_latest_offering INTEGER)
AS $$
BEGIN
    RETURN QUERY (
        SELECT *
        FROM popular_courses_driver()
        ORDER BY output_num_registration_latest_offering DESC, output_course_id ASC
    );

END
$$ LANGUAGE plpgsql;

-- view_manager_report
/*
This routine is used to view a report on the sales generated by each manager. 
The routine returns a table of records consisting of the following information for each manager: 
    manager name, 
    total number of course areas that are managed by the manager, 
    total number of course offerings that ended this year (i.e., the course offering’s end date is within this year) that are managed by the manager, 
    total net registration fees for all the course offerings that ended this year that are managed by the manager, 
    the course offering title (i.e., course title) that has the highest total net registration fees among all the course offerings that ended this year that are managed by the manager; 
        if there are ties, list all these top course offering titles. 
The total net registration fees for a course offering is defined to be 
    the sum of the total registration fees paid for the course offering via credit card payment (excluding any refunded fees due to cancellations) 
    and the total redemption registration fees for the course offering. 
The redemption registration fees for a course offering refers to the registration fees for a course offering that is paid via a redemption from a course package; 
    this registration fees is given by the price of the course package divided by the number of sessions included in the course package (rounded down to the nearest dollar). 
There must be one output record for each manager in the company and the output is to be sorted by ascending order of manager name.
*/