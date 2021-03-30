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
$$ LANGUAGE plpgsql