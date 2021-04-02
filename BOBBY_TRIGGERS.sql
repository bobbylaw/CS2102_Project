-- credits to https://stackoverflow.com/questions/25202133/how-to-get-the-triggers-associated-with-a-view-or-a-table-in-postgresql
CREATE OR REPLACE FUNCTION strip_all_triggers() RETURNS text AS $$ DECLARE
    triggNameRecord RECORD;
    triggTableRecord RECORD;
BEGIN
    FOR triggNameRecord IN select distinct(trigger_name) from information_schema.triggers where trigger_schema = 'public' LOOP
        FOR triggTableRecord IN SELECT distinct(event_object_table) from information_schema.triggers where trigger_name = triggNameRecord.trigger_name LOOP
            RAISE NOTICE 'Dropping trigger: % on table: %', triggNameRecord.trigger_name, triggTableRecord.event_object_table;
            EXECUTE 'DROP TRIGGER ' || triggNameRecord.trigger_name || ' ON ' || triggTableRecord.event_object_table || ';';
        END LOOP;
    END LOOP;

    RETURN 'done';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

select strip_all_triggers();

CREATE OR REPLACE FUNCTION check_unique_instances_for_managers()
RETURNS TRIGGER AS $$
DECLARE
	count_administrator INTEGER;
	count_instructor INTEGER;
BEGIN
	SELECT COUNT(*) INTO count_administrator
	FROM administrators
	WHERE NEW.eid = administrators.eid;
	
	SELECT COUNT(*) INTO count_instructor
	FROM instructors
	WHERE NEW.eid = instructors.eid;
	
	IF (count_administrator > 0) OR (count_instructor > 0) THEN
		RAISE NOTICE 'OPERATION FAILED: Current Employee exist in Administrators or Instructors';
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_unique_instances_for_managers
BEFORE INSERT OR UPDATE ON Managers
FOR EACH ROW EXECUTE FUNCTION check_unique_instances_for_managers();

CREATE OR REPLACE FUNCTION check_unique_instances_for_administrators()
RETURNS TRIGGER AS $$
DECLARE
	count_manager INTEGER;
	count_instructor INTEGER;
BEGIN
	SELECT COUNT(*) INTO count_manager
	FROM managers
	WHERE NEW.eid = managers.eid;
	
	SELECT COUNT(*) INTO count_instructor
	FROM instructors
	WHERE NEW.eid = instructors.eid;
	
	IF (count_manager > 0) OR (count_instructor > 0) THEN
		RAISE NOTICE 'OPERATION FAILED: Current Employee exist in Managers or Instructors';
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_unique_instances_for_administrators
BEFORE INSERT OR UPDATE ON Administrators
FOR EACH ROW EXECUTE FUNCTION check_unique_instances_for_administrators();

CREATE OR REPLACE FUNCTION check_unique_instances_for_instructors()
RETURNS TRIGGER AS $$
DECLARE
	count_manager INTEGER;
	count_administrator INTEGER;
BEGIN
	SELECT COUNT(*) INTO count_manager
	FROM managers
	WHERE NEW.eid = managers.eid;
	
	SELECT COUNT(*) INTO count_administrator
	FROM administrators
	WHERE NEW.eid = administrators.eid;
	
	IF (count_manager > 0) OR (count_administrator > 0) THEN
		RAISE NOTICE 'OPERATION FAILED: Current Employee exist in Managers or Administrators';
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_unique_instances_for_instructors
BEFORE INSERT OR UPDATE ON Instructors
FOR EACH ROW EXECUTE FUNCTION check_unique_instances_for_instructors();

CREATE OR REPLACE FUNCTION check_unique_instances_for_full_time_emp()
RETURNS TRIGGER AS $$
DECLARE
	count_part_timer INTEGER;
BEGIN
	SELECT COUNT(*) INTO count_part_timer
	FROM part_time_emp
	WHERE NEW.eid = part_time_emp.eid;
	
	IF count_part_timer > 0 THEN
		RAISE NOTICE 'OPERATION FAILED: Current Employee exist in Part Timer Employee';
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_unique_instances_for_full_time_emp
BEFORE INSERT OR UPDATE ON Full_time_emp
FOR EACH ROW EXECUTE FUNCTION check_unique_instances_for_full_time_emp();

CREATE OR REPLACE FUNCTION check_unique_instances_for_part_time_emp()
RETURNS TRIGGER AS $$
DECLARE
	count_full_timer INTEGER;
BEGIN
	SELECT COUNT(*) INTO count_full_timer
	FROM full_time_emp
	WHERE NEW.eid = full_time_emp.eid;
	
	IF count_full_timer > 0 THEN
		RAISE NOTICE 'OPERATION FAILED: Current Employee exist in Full Timer Employee';
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_unique_instances_for_part_time_emp
BEFORE INSERT OR UPDATE ON Part_time_emp
FOR EACH ROW EXECUTE FUNCTION check_unique_instances_for_part_time_emp();

CREATE OR REPLACE PROCEDURE add_employee(name TEXT, home_address TEXT, contact_number TEXT, email_address TEXT, salary_information SALARY_INFORMATION, join_date DATE, catagory TEXT, course_areas TEXT[] DEFAULT NULL)
AS $$
DECLARE
	eid INTEGER := 0;
BEGIN
	IF course_areas ISNULL AND catagory <> 'administrator' THEN
		RAISE EXCEPTION 'OPERATION FAILED: missing course_areas when employee is either instructor or manager';
	ELSIF course_areas NOTNULL AND catagory = 'administrator' THEN
		RAISE EXCEPTION 'OPERATION FAILED: course_areas presented when employee is administrator';
	ELSIF (salary_information.rate) != 'hourly' AND (salary_information.rate) != 'monthly' THEN
		RAISE EXCEPTION 'OPERATION FAILED: missing salary information';
	ELSIF (salary_information.rate) != 'hourly' AND catagory = 'instructor' THEN
		RAISE EXCEPTION 'OPERATION FAILED: Only Instructor can be part-time';
	END IF;
	
	INSERT INTO Employees (name, address, email, join_date, phone) VALUES(name, home_address, email_address, join_date, contact_number);
	
	-- Get latest eid number from Employees table
	SELECT currval(pg_get_serial_sequence('Employees', 'eid')) into eid;

	IF catagory = 'manager' THEN
		INSERT INTO full_time_emp (eid, monthly_salary) VALUES (eid, salary_information);
		INSERT INTO Managers (eid) VALUES (eid);
		INSERT INTO course_areas (name, eid)
		SELECT course_area, eid FROM unnest(course_areas) AS course_area;
	ELSIF catagory = 'administrator' THEN
		INSERT INTO full_time_emp (eid, monthly_salary) VALUES (eid, salary_information);
		INSERT INTO Administrators (eid) VALUES (eid);
	ELSIF catagory = 'instructor' THEN
		INSERT INTO instructors (eid, course_area)
		SELECT eid, course_area FROM unnest(course_areas) AS course_area;
		IF (salary_information).rate = 'monthly' THEN
			INSERT INTO full_time_emp (eid, monthly_salary) VALUES (eid, salary_information);
			INSERT INTO full_time_instructors (eid, course_area)
			SELECT eid, course_area FROM unnest(course_areas) AS course_area;
		ELSIF (salary_information).rate = 'hourly' THEN
			INSERT INTO part_time_emp (eid, hourly_rate) VALUES (eid, salary_information);
			INSERT INTO part_time_instructors (eid, course_area)
			SELECT eid, course_area FROM unnest(course_areas) AS course_area;
		END IF;
	ELSE
		ROLLBACK;
		RAISE EXCEPTION 'OPERATION FAILED: please specify the employee catagory correctly';
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE remove_employee(employee_id INTEGER, departure_date DATE) AS $$
DECLARE
	eid_handling_course_offering_count INTEGER = 0;
	eid_teaching_course_count INTEGER= 0;
	eid_managing_area_count INTEGER = 0;
BEGIN

	-- Check if EID exist
	IF NOT EXISTS(SELECT * from Employees where eid = employee_id) THEN
		RAISE NOTICE 'Employee ID do not exist';
		RETURN;
	END IF;
	
	SELECT count(*) INTO eid_handling_course_offering_count
	FROM Offerings O
	WHERE O.eid = employee_id;
	
	SELECT count(*) INTO eid_teaching_course_count
	FROM Sessions S
	WHERE S.eid = employee_id;
	
	SELECT count(*) INTO eid_managing_area_count
	FROM Course_areas C
	WHERE C.eid = employee_id;
	
	IF eid_handling_course_offering_count = 0 AND eid_teaching_course_count = 0 AND eid_managing_area_count = 0 THEN
	
		UPDATE Employees
		SET depart_date = departure_date
		WHERE eid = employee_id;
		RAISE NOTICE 'OPERATION SUCCESS';
	ELSE
		RAISE NOTICE 'OPERATION FAILED';
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_course_offerings (course_id INTEGER, course_fees NUMERIC(12,2), launch_date DATE, registration_deadline DATE, target_number_of_registration INTEGER, administrator_id INTEGER, session_info SESSION_INFORMATION[])
AS $$
DECLARE
	available_instructor_id INTEGER;
	first_session_date DATE;
	last_session_date DATE;
	total_seating_capacity INTEGER;
	sessions SESSION_INFORMATION;
BEGIN
	SELECT session_date INTO first_session_date
	FROM unnest(session_info)
	ORDER BY session_date ASC
	LIMIT 1;
	
	SELECT session_date INTO last_session_date
	FROM unnest(session_info)
	ORDER BY session_date DESC
	LIMIT 1;
	
	SELECT sum(seating_capacity) into total_seating_capacity
	FROM unnest(session_info) join Rooms ON room_id = rid;
	
	IF  (SELECT(CAST(first_session_date AS DATE) - CAST(registration_deadline AS DATE))) < 10 THEN
		RAISE EXCEPTION 'OPERATION FAILED: First session start date must be 10 days more than registration_deadline';
	ELSIF total_seating_capacity < target_number_of_registration THEN
		RAISE EXCEPTION 'OPERATION FAILED: target number of registration larger than total number of seating capacity';
	END IF;
	
	FOREACH sessions in ARRAY session_info LOOP
		IF EXTRACT(isodow FROM (sessions).session_date) not in (1,2,3,4,5) THEN
			RAISE EXCEPTION 'OPERATION FAILED: Session must be from Monday to Friday';
		ELSIF (EXTRACT(hours FROM (sessions).session_start_time) < 9 OR EXTRACT(hours FROM (sessions).session_end_time) > 12) AND (EXTRACT(hours FROM (sessions).session_start_time) < 14 OR EXTRACT(hours FROM (sessions).session_end_time) > 18) THEN
			RAISE EXCEPTION 'OPERATION FAILED: Session time must be from 9am to 12pm or 2pm to 6pm';
		ELSIF (EXTRACT(hours FROM (sessions).session_end_time)) <= (EXTRACT(hours FROM (sessions).session_start_time)) THEN
			RAISE EXCEPTION 'OPERATION FAILED: Session start time must be before end time';
		END IF;
	END LOOP;
	
	INSERT INTO Offerings (course_id, launch_date, start_date, eid, end_date, registration_deadline, target_num_of_registrations, seating_capacity, fees) VALUES (course_id, launch_date, first_session_date, administrator_id, last_session_date, registration_deadline, target_number_of_registration, total_seating_capacity, course_fees);
	
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_available_course_offerings()
RETURNS TABLE(course_title TEXT, course_area TEXT, start_date DATE, end_date DATE, registration_deadline DATE,course_fees NUMERIC(12,2),num_of_remaining_seats INTEGER) AS $$
DECLARE
	curs CURSOR FOR (SELECT * FROM Offerings O join Courses C on O.course_id = C.course_id ORDER BY registration_deadline, title ASC);
	count_register INTEGER;
	count_redeem INTEGER;
	r RECORD;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		start_date := r.start_date;
		end_date := r.end_date;
		registration_deadline := r.registration_deadline;
		course_fees := r.fees;
		course_title := r.title;
		course_area := r.name;
			  
		SELECT count(*) INTO count_register
		FROM Registers T
		WHERE T.course_id = r.course_id and T.launch_date = r.launch_date;
			  
		SELECT count(*) INTO count_redeem
		FROM Redeems T
		WHERE T.course_id = r.course_id and T.launch_date = r.launch_date;
			  
		num_of_remaining_seats := r.target_number_registrations - count_register - count_redeem;
		RETURN NEXT;
	END LOOP;
	CLOSE curs;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pay_salary()
RETURNS TABLE(employee_id INTEGER, employee_name TEXT, status TEXT, num_work_days INTEGER, num_work_hours INTEGER, hourly_rate INTEGER, monthly_salary INTEGER, salary_amount_paid NUMERIC(5,2)) AS $$
DECLARE
	curs CURSOR FOR (SELECT * FROM employees natural join full_time_emp union SELECT * FROM employees natural join part_time_emp);
	start_of_month DATE;
	end_of_month DATE;
	days_in_month INTEGER;
	work_days INTEGER;
	work_hours INTEGER;
	r RECORD;
BEGIN
	start_of_month := (SELECT DATE_TRUNC('MONTH', CURRENT_DATE));
	end_of_month := (SELECT DATE_TRUNC('MONTH', CURRENT_DATE) + interval '1 month - 1 day');
	days_in_month := (SELECT count(*) FROM generate_series(start_of_month, end_of_month, interval  '1 day'));
	OPEN curs;
	LOOP
		FETCH curs INTO r;
		EXIT WHEN NOT FOUND;
		employee_id := r.eid;
		employee_name := r.name;
		IF (r.monthly_salary).rate = 'monthly' THEN
			status = 'full-time';
			num_work_hours := NULL;
			hourly_rate := NULL;
			monthly_salary := (r.monthly_salary).salary;
			IF r.join_date BETWEEN start_of_month AND CURRENT_DATE THEN
				start_of_month := r.join_date;
			ELSIF r.depart_date BETWEEN start_of_month AND CURRENT_DATE THEN
				end_of_month := r.depart_date;
			END IF;
			work_days := (SELECT count(*) FROM generate_series(start_of_month, end_of_month, interval  '1 day') the_day WHERE  extract('ISODOW' FROM the_day) < 6);
			num_work_days := COALESCE(work_days, 0);
			salary_amount_paid := COALESCE(ROUND(((r.monthly_salary).salary * (work_days::NUMERIC / days_in_month::NUMERIC)),2),0);
		ELSIF (r.monthly_salary).rate = 'hourly' THEN
			status = 'part-time';
			num_work_days := NULL;
			num_work_hours := (SELECT SUM(AGE(end_time, start_time)) FROM Sessions S WHERE S.eid = r.eid AND S.session_date BETWEEN start_of_month AND end_of_month);
			num_work_hours := COALESCE(num_work_hours, 0);
			hourly_rate := (r.monthly_salary).salary;
			salary_amount_paid := COALESCE((num_work_hours * (r.monthly_salary).salary),0);
		END IF;
		RETURN NEXT;
		INSERT INTO Pay_slips (eid, payment_date, amount, num_work_hours, num_work_days) VALUES (employee_id, CURRENT_DATE, salary_amount_paid, num_work_hours, num_work_days);
	END LOOP;
	CLOSE curs;
END;
$$ LANGUAGE plpgsql;