DROP TABLE IF EXISTS Employees, Rooms, Customers, Packages, Salary, Full_Time_Employees, Part_Time_Employees, Administrators, Managers, Course_Areas, Instructors,
Courses, Course_Offerings, Sessions, Owns_Credit_Cards, Purchases, Registers, Redeems, Cancels CASCADE;

CREATE TABLE Employees(
	eid INTEGER PRIMARY KEY,
	name TEXT,
	home_address TEXT,
	contact_number TEXT,
	email TEXT,
	join_date DATE,
	depart_date DATE
);

CREATE TABLE Rooms (
	rid INTEGER PRIMARY KEY,
	floor INTEGER,
	room_num INTEGER,
	capacity INTEGER,
	UNIQUE(floor, room_num)
);

CREATE TABLE Customers(
	cust_id SERIAL PRIMARY KEY,
	cname TEXT,
	home_address  TEXT,
	email TEXT,
	contact_number TEXT
);

CREATE TABLE Packages (
	pid INTEGER PRIMARY KEY,
	pname  TEXT,
	num_of_free_session INTEGER,
	price   INTEGER,
	start_date DATE,
	end_date DATE
);

CREATE TABLE Salary(
	sid INTEGER,
	eid INTEGER,
	date_of_transaction DATE,
	salary_amount NUMERIC(12, 2),
	PRIMARY KEY(eid, sid),
	FOREIGN KEY(eid) REFERENCES Employees(eid) ON DELETE CASCADE
);

CREATE TABLE Full_Time_Employees(
	eid INTEGER PRIMARY KEY,
	num_work_days INTEGER,
	monthly_salary NUMERIC(12, 2),
	FOREIGN KEY(eid) REFERENCES Employees(eid) ON DELETE CASCADE
);

CREATE TABLE Part_Time_Employees(
	eid INTEGER PRIMARY KEY,
	hours_worked INTEGER,
	hourly_rate NUMERIC(12, 2),
	FOREIGN KEY(eid) REFERENCES Employees(eid) ON DELETE CASCADE
);

CREATE TABLE Administrators(
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY(eid) REFERENCES Full_Time_Employees(eid) ON DELETE CASCADE
);

CREATE TABLE Managers(
	eid INTEGER PRIMARY KEY,
	FOREIGN KEY(eid) REFERENCES Full_Time_Employees(eid) ON DELETE CASCADE
);

/* eid is manager’s eid */
CREATE TABLE Course_Areas(
	name TEXT PRIMARY KEY,
	eid INTEGER NOT NULL,
	FOREIGN KEY(eid) REFERENCES Managers(eid)	
);

/* course_name refers to instructor’s specialization area */
CREATE TABLE Instructors(
	eid SERIAL PRIMARY KEY,
	eid_FT INTEGER UNIQUE,
	eid_PT INTEGER UNIQUE,
	course_name TEXT NOT NULL,
	FOREIGN KEY(eid_FT) REFERENCES Full_Time_Employees(eid) ON DELETE CASCADE,
	FOREIGN KEY(eid_PT) REFERENCES Part_Time_Employees(eid) ON DELETE CASCADE,
	FOREIGN KEY(course_name) REFERENCES Course_Areas(name),
	CHECK(eid_FT IS NOT NULL OR eid_PT IS NOT NULL)
);

CREATE TABLE Courses(
	csc_id INTEGER PRIMARY KEY,
	ctitle TEXT UNIQUE,
	description TEXT,
	name TEXT NOT NULL,
	hours INTEGER,
	FOREIGN KEY (name) REFERENCES Course_Areas(name) 
);

CREATE TABLE Course_Offerings(
	launch_date DATE,
	target_num_of_reg INTEGER,
	registration_deadline DATE,
	is_available BOOLEAN,
	fees numeric(12,2),
	end_date DATE,
	start_date DATE,
	capacity INTEGER,
	csc_id INTEGER,
	eid INTEGER NOT NULL,  
	PRIMARY KEY(csc_id, launch_date),
	FOREIGN KEY(csc_id) REFERENCES courses(csc_id) ON DELETE CASCADE,
	FOREIGN KEY(eid) REFERENCES Administrators(eid),
	CHECK (
		(CAST(registration_deadline AS DATE) - CAST(start_date AS DATE)) >= 10
	)
);

CREATE TABLE Sessions(
	sid SERIAL,
	start_time TIME,
	end_time TIME,
	date DATE,
	csc_id INTEGER,
	launch_date DATE,
	rid INTEGER NOT NULL,
	eid INTEGER NOT NULL,
	PRIMARY KEY(sid, csc_id, launch_date),
	FOREIGN KEY(csc_id, launch_date) REFERENCES Course_Offerings(csc_id, launch_date) ON DELETE CASCADE,
	FOREIGN KEY(eid) REFERENCES Instructors(eid),
	FOREIGN KEY(rid) REFERENCES Rooms(rid),
	CONSTRAINT test1 CHECK (
		(EXTRACT(isodow FROM date) in (1,2,3,4,5))
	),
	CONSTRAINT test2 CHECK (
		((EXTRACT(hours FROM start_time) >= 9) and
		(EXTRACT(hours FROM end_time) <= 12)) 
		or
		((EXTRACT(hours FROM start_time) >= 14) and
		(EXTRACT(hours FROM end_time) <= 18))
	),
	CONSTRAINT test3 CHECK (
		(EXTRACT(hours FROM end_time)) > (EXTRACT(hours FROM start_time))
	)
);
	

CREATE TABLE Owns_Credit_Cards (
	cust_id SERIAL NOT NULL,
	card_number TEXT PRIMARY KEY,
	exipiry_date DATE,
	cvv_code NUMERIC(3),
	from_date DATE,
	FOREIGN KEY (cust_id) REFERENCES Customers
);


CREATE TABLE Purchases (
	pid INTEGER,
	date DATE,
	card_number TEXT,
	num_remaining_redemption INTEGER,
	PRIMARY KEY (pid, date, card_number),
	FOREIGN KEY(pid) REFERENCES Packages,
	FOREIGN KEY(card_number) REFERENCES Owns_Credit_Cards(card_number)
);

CREATE TABLE Registers (
	card_number TEXT,
	sid INTEGER,
	date DATE,
	launch_date DATE,
	csc_id INTEGER,
	PRIMARY KEY (card_number, sid, date),
	FOREIGN KEY (card_number) REFERENCES Owns_Credit_Cards(card_number),
	FOREIGN KEY (sid, launch_date, csc_id) REFERENCES Sessions(sid, launch_date,csc_id)
);

CREATE TABLE Redeems (
	pid INTEGER,
	card_number TEXT,
	purchase_date DATE,
	redeem_date DATE,
	sid INTEGER,
	launch_date DATE,
	csc_id INTEGER,
	PRIMARY KEY (pid, sid, card_number, purchase_date, redeem_date, csc_id, launch_date),
	FOREIGN KEY (card_number, pid, purchase_date) REFERENCES Purchases(card_number, pid, date),
	FOREIGN KEY (sid, launch_date, csc_id) REFERENCES Sessions(sid, launch_date,csc_id)
);

CREATE TABLE Cancels (
	cust_id INTEGER,
	sid INTEGER,
	cancel_date DATE,
	launch_date DATE,
	csc_id INTEGER,
	refund_amount NUMERIC(12,2),
	PRIMARY KEY (cust_id, sid, cancel_date, launch_date, csc_id),
	FOREIGN KEY (cust_id) REFERENCES Customers(cust_id),
	FOREIGN KEY (sid, launch_date, csc_id) REFERENCES Sessions(sid, launch_date,csc_id)
);




