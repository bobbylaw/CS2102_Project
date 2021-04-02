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
        SELECT s.session_date as session_date, EXTRACT(hours from s.start_time) as start_hour, e.name as instructor_name, (o.seating_capacity - COUNT(r.card_number)) as remaining_seats
        FROM Registers as r NATURAL FULL JOIN Sessions as s NATURAL FULL JOIN (SELECT course_id, launch_date, start_date, seating_capacity FROM Offerings) as o NATURAL FULL JOIN Instructors as i NATURAL FULL JOIN Employees as e
        GROUP BY s.session_date, s.start_time, e.name, o.seating_capacity, o.course_id, o.launch_date
        HAVING input_course_id = o.course_id AND input_launch_date = o.launch_date
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

-- remove_session
/*
This routine is used to remove a course session. 
The inputs to the routine include the following: course offering identifier and session number. 
If the course session has not yet started and the request is valid, the routine will process the request with the necessary updates. 
The request must not be performed if there is at least one registration for the session. 
Note that the resultant seating capacity of the course offering could fall below the course offering’s target number of registrations, which is allowed.
*/

-- add_session
/*
This routine is used to add a new session to a course offering. 
The inputs to the routine include the following: course offering identifier, new session number, new session day, new session start hour, instructor identifier for new session, and room identifier for new session. 
If the course offering’s registration deadline has not passed and the the addition request is valid, the routine will process the request with the necessary updates.
*/