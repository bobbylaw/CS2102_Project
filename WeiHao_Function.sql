-- find_instructors: This routine is used to find all the instructors who could be assigned to teach a course session. 
-- The inputs to the routine include the following: course identifier, session date, and session start hour. 
-- The routine returns a table of records consisting of employee identifier and name.
CREATE OR REPLACE FUNCTION find_instructors(IN course_id1 INTEGER, IN session_date1 DATE, IN start_time1) -- Is it suppose to be start_time or launch_date because launch date is the PK
RETURNS TABLE(eid INT, name TEXT) AS $$
BEGIN
    SELECT DISTINCT eid, name -- There might be chance that there are duplicated instructor.
    FROM Session S1, Employees E1
    WHERE S1.eid = E1.eid 
    AND S1.course_id = course_id1 
    AND S1.session_date = session_date1
    AND S1.start_time = start_time1;
END;
$$ LANGUAGE plpgsql;
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
RETURNS TABLE() AS $$
DECLARE
BEGIN
END;
$$ LANGUAGE plpgsql;

/*
cancel_registration: This routine is used when a customer requests to cancel a registered course session. 
The inputs to the routine include the following: customer identifier, and course offering identifier. 
If the cancellation request is valid, the routine will process the request with the necessary updates.
*/

CREATE OR REPLACE PROCEDURE cancel_registration(IN customer_id INTEGER, IN course_identifier INTEGER, IN offering_launch_date DATE, IN session_id INTEGER)
-- course offering identifier is not enough, we need course session also because customer requests to cancel a REGISTERED COURSE SESSION. <- write in report
AS $$
DECLARE
    is_redeem INTEGER;
    is_register INTEGER;
    customer_cc_num TEXT;
    course_offering_price NUMERIC(12,2);
BEGIN
    is_redeem := 0;
    is_register := 0;
    course_offering_price := 0;

    SELECT fees INTO course_offering_price -- Get the price of the course session/offerings. Its the same.
    FROM Offerings
    WHERE Offerings.course_id = course_identifier
    AND Offerings.launch_date = offering_launch_date;

    SELECT card_number INTO customer_cc_num  -- Get the cc num of the customer
    FROM Owns_credit_cards
    WHERE Owns_credit_card.cust_id = customer_id;

    SELECT 1 INTO is_redeem  -- Check whether custoemr redeems or purchase the session
    FROM Redeems
    WHERE Redeems.course_id = course_identifier 
    AND Redeems.launch_date = offering_launch_date 
    AND Redeems.sid = session_id
    AND Redeems.card_number = customer_cc_num
    AND CURRENT_DATE - Redeems.purchase_date <= 7;

    SELECT 1 INTO is_register
    FROM Registers
    WHERE Registers.course_id = course_identifier
    AND Registers.launch_date = offering_launch_date
    AND Registers.sid = session_id
    AND Registers.card_number = customer_cc_num
    AND CURRENT_DATE - Registers.registration_date <= 7;

    IF (is_redeem = 1) THEN
        INSERT INTO Cancels
        VALUES (customer_id, course_identifier, offering_launch_date, session_id, CURRENT_DATE, 0, 1);  --Current_date is a "static method"
    ELSIF (is_register = 1) THEN
        INSERT INTO Cancels
        VALUES (customer_id, course_identifier, offering_launch_date, session_id, CURRENT_DATE, 0.9 * course_offering_price, 0);
    ELSE
        RAISE NOTICE 'Something went wrong. No insertion is done.';
    END IF;
END;
$$ LANGUAGE plpgsql;

/*
update_instructor: This routine is used to change the instructor for a course session. 
The inputs to the routine include the following: course offering identifier, session number, and identifier of the new instructor. 
If the course session has not yet started and the update request is valid, the routine will process the request with the necessary updates.
*/

CREATE OR REPLACE PROCEDURE update_instructor(IN course_identifier INTEGER, IN offering_launch_date DATE, IN session_id INTEGER, IN new_eid INTEGER)
AS $$
DECLARE
    course_session_start_time TIMESTAMP;
BEGIN
    SELECT start_time INTO course_session_start_time
    FROM Sessions
    WHERE Sessions.course_id = course_identifier
    AND Sessions.launch_date = offering_launch_date
    AND Sessions.sid = session_id;

    IF (CURRENT_TIMESTAMP - course_session_start_time > INTERVAL '0 second') THEN
        UPDATE Sessions
        SET eid = new_eid
        WHERE Sessions.course_id = course_identifier
        AND Sessions.launch_date = offering_launch_date
        AND Sessions.sid = session_id;
    ELSE
        RAISE NOTICE 'Invalid request';
    END IF
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
    course_session_start_time TIMESTAMP;
    course_seating_capacity INTEGER;
    new_room_seating_capacity INTEGER;
BEGIN
    SELECT start_time INTO course_session_start_time
    FROM Sessions
    WHERE Sessions.course_id = course_identifier
    AND Sessions.launch_date = offering_launch_date
    AND Sessions.sid = session_id;

    SELECT seating_capacity INTO course_seating_capacity
    FROM offerings
    WHERE Offerings.course_id = course_identifier
    AND Offerings.launch_date = offering_launch_date;

    SELECT seating_capacity INTO new_room_seating_capacity
    FROM Rooms
    WHERE Rooms.rid = new_rid;

    IF (CURRENT_TIMESTAMP - course_session_start_time > INTERVAL '0 second') AND (new_room_seating_capacity > course_seating_capacity) THEN
        UPDATE Sessions
        SET rid = new_rid
        WHERE Sessions.course_id = course_identifier
        AND Sessions.launch_date = offering_launch_date
        AND Sessions.sid = session_id;
    ELSE
        RAISE NOTICE 'Invalid request';
    END IF;  
END;
$$ LANGUAGE plpgsql