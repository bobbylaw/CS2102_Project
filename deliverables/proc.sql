/* ============================================================== FUNCTIONS ============================================================== */
-- 1.add_employee:
/*
This routine is used to add a new employee. 
The inputs to the routine include the following: 
    name, home address, contact number, email address, 
    salary information (i.e., monthly salary for a full-time employee or hourly rate for a part-time employee), 
    date that the employee joined the company, 
    the employee category (manager, administrator, or instructor), 
    and a (possibly empty) set of course areas. 
If the new employee is a manager, the set of course areas refers to the areas that are managed by the manager. 
If the new employee is an instructor, the set of course areas refers to the instructor’s specialization areas. 
The set of course areas must be empty if the new employee is a administrator; and non-empty, otherwise. 
The employee identifier is generated by the system.
*/


-- 2.remove_employee:
/*
This routine is used to update an employee’s departed date a non-null value. 
The inputs to the routine is an employee identifier and a departure date. 
The update operation is rejected if any one of the following conditions hold: 
    (1) the employee is an administrator who is handling some course offering where its registration deadline is after the employee’s departure date; 
    (2) the employee is an instructor who is teaching some course session that starts after the employee’s departure date; or 
    (3) the employee is a manager who is managing some area.
*/


-- 3.add_customer:
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

-- 4.update_credit_card:
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

-- 5.add_course:
/*
This routine is used to add a new course. 
The inputs to the routine include the following: course title, course description, course area, and duration. 
The course identifier is generated by the system.
*/

-- 6.find_instructors:
/*
This routine is used to find all the instructors who could be assigned to teach a course session. 
The inputs to the routine include the following: course identifier, session date, and session start hour. 
The routine returns a table of records consisting of employee identifier and name.
*/

-- 7.get_available_instructors: 
/*
This routine is used to retrieve the availability information of instructors who could be assigned to teach a specified course. 
The inputs to the routine include the following: course identifier, start date, and end date. 
The routine returns a table of records consisting of the following information: 
    employee identifier, name, total number of teaching hours that the instructor has been assigned for this month, 
    day (which is within the input date range [start date, end date]), and an array of the available hours for the instructor on the specified day. 
The output is sorted in ascending order of employee identifier and day, and the array entries are sorted in ascending order of hour.
*/

-- 8.find_rooms: 
/*
This routine is used to find all the rooms that could be used for a course session. 
The inputs to the routine include the following: session date, session start hour, and session duration. 
The routine returns a table of room identifiers.
*/

-- 9.get_available_rooms: 
/*
This routine is used to retrieve the availability information of rooms for a specific duration. 
The inputs to the routine include a start date and an end date. 
The routine returns a table of records consisting of the following information: 
    room identifier, room capacity, day (which is within the input date range [start date, end date]), 
    and an array of the hours that the room is available on the specified day. 
The output is sorted in ascending order of room identifier and day, and the array entries are sorted in ascending order of hour.
*/

-- 10.add_course_offering: 
/*
This routine is used to add a new offering of an existing course. 
The inputs to the routine include the following: 
    course offering identifier, course identifier, course fees, launch date, registration deadline, administrator’s identifier, 
    and information for each session (session date, session start hour, and room identifier). 
If the input course offering information is valid, the routine will assign instructors for the sessions. 
If a valid instructor assignment exists, the routine will perform the necessary updates to add the course offering; 
    otherwise, the routine will abort the course offering addition. 
Note that the seating capacity of the course offering must be at least equal to the course offering’s target number of registrations.
*/

-- 11.add_course_package: 
/*
This routine is used to add a new course package for sale. 
The inputs to the routine include the following: 
    package name, number of free course sessions, start and 
    end date indicating the duration that the promotional package is available for sale, 
    and the price of the package. 
The course package identifier is generated by the system. 
If the course package information is valid, the routine will perform the necessary updates to add the new course package.
*/

-- 12.get_available_course_packages: 
/*
This routine is used to retrieve the course packages that are available for sale. 
The routine returns a table of records with the following information for each available course package: 
    package name, number of free course sessions, end date for promotional package, and the price of the package.
*/

-- 13.buy_course_package: 
/*
This routine is used when a customer requests to purchase a course package. 
The inputs to the routine include the customer and course package identifiers. 
If the purchase transaction is valid, the routine will process the purchase with the necessary updates (e.g., payment).
*/

-- 14.get_my_course_package: 
/*
This routine is used when a customer requests to view his/her active/partially active course package. 
The input to the routine is a customer identifier. 
The routine returns the following information as a JSON value: 
    package name, purchase date, price of package, 
    number of free sessions included in the package, 
    number of sessions that have not been redeemed, 
    and information for each redeemed session (course name, session date, session start hour). 
The redeemed session information is sorted in ascending order of session date and start hour.
*/

-- 15.get_available_course_offerings: 
/*
This routine is used to retrieve all the available course offerings that could be registered. 
The routine returns a table of records with the following information for each course offering: 
    course title, course area, start date, end date, registration deadline, course fees, 
    and the number of remaining seats. 
The output is sorted in ascending order of registration deadline and course title.
*/

-- 16.get_available_course_sessions:
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

-- 17.register_session: 
/*
This routine is used when a customer requests to register for a session in a course offering. 
The inputs to the routine include the following:
    customer identifier, course offering identifier, session number, 
    and payment method (credit card or redemption from active package). 
If the registration transaction is valid, this routine will process the registration with the necessary updates (e.g., payment/redemption).
*/

-- 18.get_my_registrations
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

-- 19.update_course_session
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

-- 20.cancel_registration: 
/*
This routine is used when a customer requests to cancel a registered course session. 
The inputs to the routine include the following: customer identifier, and course offering identifier. 
If the cancellation request is valid, the routine will process the request with the necessary updates.
*/

-- 21.update_instructor: 
/*
This routine is used to change the instructor for a course session. 
The inputs to the routine include the following: 
    course offering identifier, session number, and identifier of the new instructor. 
If the course session has not yet started and the update request is valid, the routine will process the request with the necessary updates.
*/

-- 22.update_room: 
/*
This routine is used to change the room for a course session. 
The inputs to the routine include the following: 
    course offering identifier, session number, and identifier of the new room. 
If the course session has not yet started and the update request is valid, the routine will process the request with the necessary updates. 
Note that update request should not be performed if the number of registrations for the session exceeds the seating capacity of the new room.
*/

-- 23.remove_session:
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

-- 24.add_session:
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
    input_course_duration INTERVAL;
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
        VALUES (input_course_id, input_launch_date, input_course_area, input_rid, input_instructor_eid, input_sid, input_session_day, input_session_start_hour, input_session_start_hour + input_course_duration);
    ELSE
        RAISE EXCEPTION 'Invalid sessions added!';
    END IF;
END
$$ LANGUAGE plpgsql;

-- 25.pay_salary: 
/*
This routine is used at the end of the month to pay salaries to employees. 
The routine inserts the new salary payment records and returns a table of records (sorted in ascending order of employee identifier) 
with the following information for each employee who is paid for the month: 
    employee identifier, name, status (either part-time or full-time), number of work days for the month, number of work hours for the month, 
    hourly rate, monthly salary, and salary amount paid. For a part-time employees, the values for number of work days for the month and monthly salary should be null. 
For a full-time employees, the values for number of work hours for the month and hourly rate should be null.
*/

-- 26.promote_courses: 
/*
This routine is used to identify potential course offerings that could be of interest to inactive customers. 
A customer is classified as an active customer if the customer has registered for some course offering in the last six months (inclusive of the current month); 
otherwise, the customer is considered to be inactive customer. 
A course area A is of interest to a customer C if there is some course offering in area A among the three most recent course offerings registered by C. 
If a customer has not yet registered for any course offering, we assume that every course area is of interest to that customer. 
The routine returns a table of records consisting of the following information for each inactive customer: 
    customer identifier, customer name, course area A that is of interest to the customer, course identifier of a course C in area A, course title of C, 
    launch date of course offering of course C that still accepts registrations, course offering’s registration deadline, and fees for the course offering. 
The output is sorted in ascending order of customer identifier and course offering’s registration deadline.
*/

-- 27.top_packages: 
/*
This routine is used to find the top N course packages in terms of the total number of packages sold for this year (i.e., the package’s start date is within this year). 
The input to the routine is a positive integer number N. 
The routine returns a table of records consisting of the following information for each of the top N course packages: 
    package identifier, number of included free course sessions, price of package, start date, end date, and number of packages sold. 
The output is sorted in descending order of number of packages sold followed by descending order of price of package. 
In the event that there are multiple packages that tie for the top Nth position, all these packages should be included in the output records; thus, the output table could have more than N records. 
It is also possible for the output table to have fewer than N records if N is larger than the number of packages launched this year.
*/

-- 28.popular_courses:
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
    curr_course_duration INTERVAL;

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

-- 29.view_summary_report: 
/*
This routine is used to view a monthly summary report of the company’s sales and expenses for a specified number of months. 
The input to the routine is a number of months (say N) and the routine returns a table of records consisting of the following information for each of the last N months (starting from the current month): 
    month and year, total salary paid for the month, total amount of sales of course packages for the month, total registration fees paid via credit card payment for the month, 
    total amount of refunded registration fees (due to cancellations) for the month, and total number of course registrations via course package redemptions for the month. 
For example, if the number of specified months is 3 and the current month is January 2021, the output will consist of one record for each of the following three months: January 2021, December 2020, and November 2020.
*/

-- 30.view_manager_report: 
/*
This routine is used to view a report on the sales generated by each manager. 
The routine returns a table of records consisting of the following information for each manager: 
    manager name, total number of course areas that are managed by the manager, total number of course offerings that ended this year (i.e., the course offering’s end date is within this year) that are managed by the manager, 
    total net registration fees for all the course offerings that ended this year that are managed by the manager, 
    the course offering title (i.e., course title) that has the highest total net registration fees among all the course offerings that ended this year that are managed by the manager; 
        if there are ties, list all these top course offering titles. 
The total net registration fees for a course offering is defined to be the sum of the total registration fees paid for the course offering via credit card payment (excluding any refunded fees due to cancellations) 
and the total redemption registration fees for the course offering. 
The redemption registration fees for a course offering refers to the registration fees for a course offering that is paid via a redemption from a course package; 
    this registration fees is given by the price of the course package divided by the number of sessions included in the course package (rounded down to the nearest dollar). 
There must be one output record for each manager in the company and the output is to be sorted by ascending order of manager name.
*/

/* ============================================================== TRIGGERS ============================================================== */

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

CREATE OR REPLACE FUNCTION AT_MOST_ONE_REG_BEFORE_DEADLINE_PER_CUSTOMER()
RETURNS TRIGGER AS $$
DECLARE
    counter INTEGER;
    reg_deadline DATE;
BEGIN

    reg_deadline := (SELECT o.registration_deadline
                        FROM Offerings as o
                        WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date);
    
    IF (NEW.registration_date > reg_deadline) THEN
        RAISE EXCEPTION 'You are registering after the deadline!';
        RETURN NULL;
    END IF;

    counter := (
        SELECT COALESCE(COUNT(*), 0) -- this query returns the count of credit cards insert customer owns that exist in registers table AND reg_date < deadline
        FROM Registers as r NATURAL JOIN Sessions as s NATURAL JOIN Offerings as co
        WHERE card_number IN (SELECT DISTINCT occ.card_number -- this subquery gets all the credit cards this customer owns
                FROM Owns_Credit_Cards as occ
                WHERE cust_id in (SELECT DISTINCT rcc.cust_id -- this subquery fetches customers who own NEW.credit card
                    FROM (Registers NATURAL JOIN Owns_Credit_Cards) as rcc JOIN Customers as c ON rcc.cust_id = c.cust_id
                    WHERE NEW.card_number = card_number))
            AND NEW.registration_date <= registration_deadline
            AND NEW.course_id = course_id
            AND NEW.launch_date = launch_date
    );

    IF(counter <> 0) THEN
        RAISE EXCEPTION 'A Customer can only register for atmost one session from an offered course!';
        RETURN NULL;
    ELSE 
        RETURN NEW;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER AT_MOST_ONE_REG_BEFORE_DEADLINE_PER_CUSTOMER_TRIGGER
BEFORE INSERT OR UPDATE ON Registers
FOR EACH ROW EXECUTE FUNCTION AT_MOST_ONE_REG_BEFORE_DEADLINE_PER_CUSTOMER();

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
    r record;
    curs CURSOR FOR (SELECT SUM(COALESCE(seating_capacity, 0)) as total_capacity, s.course_id, s.launch_date
                    FROM Sessions as s NATURAL JOIN Rooms as r
                    WHERE (s.course_id, s.launch_date, s.sid) IN (SELECT s2.course_id, s2.launch_date, s2.sid
                            FROM Sessions as s2
                            WHERE NEW.rid = s2.rid)
            GROUP BY s.course_id, s.launch_date);
BEGIN

    OPEN curs;
    LOOP
        FETCH curs into r; 
        EXIT WHEN NOT FOUND;

        UPDATE Offerings 
        SET seating_capacity = r.total_capacity 
        WHERE r.course_id = course_id AND r.launch_date = launch_date;

    END LOOP;

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
                        FROM Offerings as o
                        WHERE NEW.course_id = course_id AND 
                            NEW.launch_date = launch_date);

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
BEFORE INSERT ON Registers
FOR EACH ROW EXECUTE FUNCTION CSE_OFFERING_AVAIL();