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
