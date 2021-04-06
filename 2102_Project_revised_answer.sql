DROP TABLE IF EXISTS Employees, Pay_slips, Part_time_Emp, Full_time_Emp, Instructors, Managers, Administrators, Part_time_instructors, 
Full_time_instructors, Course_areas, Courses, Offerings, Rooms , Sessions, Customers, Cancels, Owns_credit_cards, 
Registers, Course_packages, Buys, Redeems CASCADE;

DROP TYPE IF EXISTS salary_information CASCADE;
DROP TYPE IF EXISTS session_information CASCADE;

CREATE TYPE salary_information AS (
	salary INTEGER,
	rate TEXT
);

CREATE TYPE session_information AS (
	session_date DATE,
	session_start_time TIME,
	room_id INTEGER
);

-- BLUE INK FIRST
CREATE TABLE Employees (
    eid SERIAL PRIMARY KEY,
    name TEXT,
    address TEXT,
    email TEXT UNIQUE NOT NULL,
    depart_date DATE,
    join_date DATE,
    phone TEXT
);

CREATE TABLE Pay_slips (
    eid INTEGER,
    payment_date DATE,
    amount INTEGER,
    num_work_hours INTEGER,
    num_work_days INTEGER,
    PRIMARY KEY(eid, payment_date), -- Weak entity set
    FOREIGN KEY (eid) REFERENCES Employees(eid) ON DELETE CASCADE -- Weak entity set
);

CREATE TABLE Part_time_Emp (
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE, -- IS-A Relationship
    hourly_rate salary_information
);

CREATE TABLE Full_time_Emp(
    eid INTEGER PRIMARY KEY REFERENCES Employees ON DELETE CASCADE, -- IS-A Relationship
    monthly_salary salary_information
);

CREATE TABLE Administrators (
    eid INTEGER PRIMARY KEY REFERENCES Full_time_Emp ON DELETE CASCADE -- IS-A Relationship
);

CREATE TABLE Managers (
    eid INTEGER PRIMARY KEY REFERENCES Full_time_Emp ON DELETE CASCADE-- IS-A Relationship
);

CREATE TABLE Course_areas (
    name TEXT PRIMARY KEY,
    eid INTEGER NOT NULL, -- KEY AND TOTAL PARTICIPATION of the manages relationship
    FOREIGN KEY (eid) REFERENCES Managers(eid) -- Course_areas managed by a manager.
);

CREATE TABLE Instructors (
    eid INTEGER REFERENCES Employees(eid) ON DELETE CASCADE, -- IS-A Relationship
	course_area TEXT REFERENCES course_areas(name),
	PRIMARY KEY(eid, course_area)
);

CREATE TABLE Part_time_instructors (
    eid INTEGER,  -- 2 IS-A Relationship
	course_area TEXT,
	PRIMARY KEY (eid, course_area),
	FOREIGN KEY (eid) REFERENCES Part_time_Emp(eid) ON DELETE CASCADE,
	FOREIGN KEY (eid, course_area) REFERENCES Instructors(eid, course_area) ON DELETE CASCADE -- 2 IS-A Relationship
);

CREATE TABLE Full_time_instructors (
    eid INTEGER,
	course_area TEXT,
	PRIMARY KEY (eid, course_area),
	FOREIGN KEY (eid) REFERENCES Full_time_Emp(eid) ON DELETE CASCADE,
	FOREIGN KEY (eid, course_area) REFERENCES Instructors(eid, course_area) ON DELETE CASCADE -- 2 IS-A Relationship
);

-- RED INK
CREATE TABLE Courses (
    course_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL, -- KEY AND TOTAL PARTICIPATION of In relationship
    title TEXT UNIQUE, -- UNIQUE course_title
    duration INTERVAL, -- Integer in mins? 
    description TEXT,
    FOREIGN KEY (name) REFERENCES Course_areas(name) -- Courses is IN relationship with course_areas
);

CREATE TABLE Offerings (
    course_id INTEGER, -- Weak entity set to Courses
    launch_date DATE,
    start_date DATE,
    eid INTEGER NOT NULL, -- course offerings handles by administrator.
    end_date DATE,
    registration_deadline DATE,
    target_number_registrations INTEGER,
    seating_capacity INTEGER,
    fees NUMERIC(12,2),
    PRIMARY KEY(course_id, launch_date), -- Weak entity set to courses
    FOREIGN KEY(eid) REFERENCES Administrators,
    FOREIGN KEY(course_id) REFERENCES Courses(course_id) ON DELETE CASCADE, -- Weak entity set to Courses
    CHECK (
		(CAST(start_date AS DATE) - CAST(registration_deadline AS DATE)) >= 10
	) -- Registration deadline must be 10 days before start date
);

CREATE TABLE Rooms (
    rid INTEGER PRIMARY KEY,
    location TEXT, -- Can change to floor, room_num also.
    seating_capacity INTEGER
);

CREATE TABLE Sessions (
    course_id INTEGER, -- weak entity set to offerings
    launch_date DATE, -- weak entity set to offerings
	course_area TEXT, -- Sessions is in conducts relationship with Instructor. KEY AND TOTAL PARTICIPATION
    rid INTEGER NOT NULL, -- Sessions is in conducts relationship with rooms. KEY AND TOTAL PARTICIPATION
    eid INTEGER NOT NULL, -- Sessions is in conducts relationship with Instructor. KEY AND TOTAL PARTICIPATION
    sid SERIAL,
    session_date DATE,
    start_time TIME,
    end_time TIME,
    PRIMARY KEY (course_id, launch_date, sid), -- weak entity set to offerings
    FOREIGN KEY (course_id, launch_date) REFERENCES Offerings(course_id, launch_date) ON DELETE CASCADE, -- weak entity set to offerings
    FOREIGN KEY (rid) REFERENCES Rooms(rid),
    FOREIGN KEY (eid, course_area) REFERENCES Instructors,
    CHECK (
		EXTRACT(isodow FROM session_date) in (1,2,3,4,5)
	),
	CHECK (
		((EXTRACT(hours FROM start_time) >= 9) and
		(EXTRACT(hours FROM end_time) <= 12)) 
		or
		((EXTRACT(hours FROM start_time) >= 14) and
		(EXTRACT(hours FROM end_time) <= 18))
	),
	CHECK (
		(EXTRACT(hours FROM end_time)) > (EXTRACT(hours FROM start_time))
	) -- Morning and Afternoon Sessions
);

-- CYAN INK
CREATE TABLE Customers (
    cust_id SERIAL PRIMARY KEY,
    address TEXT,
    phone TEXT,
    name TEXT,
    email TEXT UNIQUE NOT NULL
);

CREATE TABLE Cancels (
    cust_id INTEGER, -- Cancels connects to Customers
    course_id INTEGER, -- Cancels connect to Sessions
    launch_date DATE, -- Cancels connect to Sessions
    sid INTEGER, -- Cancels connect to Sessions
    cancellation_date DATE, -- Date is a keyword hence i change to cancellation_date
    refund_amt NUMERIC(12,2),
    package_credit INTEGER,
    PRIMARY KEY (cust_id, course_id, launch_date, sid, cancellation_date), -- date is also a component of primary key
    FOREIGN KEY (cust_id) REFERENCES Customers, -- Cancels connects to Customers
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions(course_id, launch_date, sid) -- Cancels connect to Sessions
);

CREATE TABLE Owns_credit_cards (
    card_number TEXT PRIMARY KEY,
    cust_id INTEGER NOT NULL, -- KEY AND TOTAL PARTICIPATION to customers
    CVV INTEGER,
    from_date DATE,
    expiry_date DATE,
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id)
);


CREATE TABLE Registers (
    card_number TEXT, -- Registers connect to Owns_credit_cards
    course_id INTEGER, -- Registers connect to Sessions
    launch_date DATE, -- Registers connect to Sessions
    sid INTEGER, -- Registers connect to Sessions
    registration_date DATE, -- date is a reserved keyword hence i change to registration_date
    PRIMARY KEY (card_number, course_id, launch_date, sid, registration_date), -- Date is a component of primary key
    FOREIGN KEY (card_number) REFERENCES Owns_credit_cards (card_number),
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions (course_id, launch_date, sid)
);

CREATE TABLE Course_packages (
    package_id SERIAL PRIMARY KEY,
    sales_start_date DATE NOT NULL,
    sales_end_date DATE NOT NULL,
    num_free_registrations INTEGER NOT NULL, 
    name TEXT NOT NULL,
    price NUMERIC(12,2)
    CHECK(sales_end_date - sales_start_date >= 0)-- Sales_end_date should be after sales_start_date
);

CREATE TABLE Buys (
    card_number TEXT, -- Buys connects to Owns_credit_cards
    package_id INTEGER, -- Buys connect to course_packages
    purchase_date DATE, -- Date is a reserved keyword hence i change to purchase_date
    num_of_redemption INTEGER,
    PRIMARY KEY(card_number, package_id, purchase_date),
    FOREIGN KEY (card_number) REFERENCES Owns_credit_cards(card_number), -- Buys connects to Owns_credit_cards
    FOREIGN KEY (package_id) REFERENCES Course_packages(package_id), -- Buys connect to course_packages
    CHECK (num_of_redemption >= 0) -- can't possibly let redemption goes negative
);

CREATE TABLE Redeems (
    card_number TEXT, -- Redeems is an aggregation to buys
    package_id INTEGER, -- Redeems is an aggregation to buy
    purchase_date DATE, -- Redeems is an aggregation to buy
    course_id INTEGER, -- Redeems connect to Sessions
    launch_date DATE, -- Redeems connect to Sessions
    sid INTEGER, -- Redeems connect to Sessions
    redemption_date DATE, -- Date is a reserved keyword hence i change to redemption_date
    PRIMARY KEY (card_number, package_id, purchase_date, course_id, launch_date, sid, redemption_date),
    FOREIGN KEY (card_number, package_id, purchase_date) REFERENCES Buys (card_number, package_id, purchase_date), -- Redeems is an aggregation to buy
    FOREIGN KEY (course_id, launch_date, sid) REFERENCES Sessions (course_id, launch_date, sid) -- Redeems connect to Sessions
);
