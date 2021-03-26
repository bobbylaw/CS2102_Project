DROP TABLE IF EXISTS Employees, Rooms, Customers, Packages, Salary, Full_Time_Employees, Part_Time_Employees, Administrators, Managers, Course_Areas, Instructors,
Courses, Course_Offerings, Sessions, Owns_Credit_Cards, Purchases, Registers, Redeems, Cancels CASCADE;

CREATE TABLE Employees(
	eid INTEGER PRIMARY KEY,
	name TEXT,
	home_address TEXT,
	contact_number TEXT,
	email TEXT,
	join_date TIMESTAMP,
	depart_date TIMESTAMP
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
	num_session INTEGER,
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
	eid INTEGER PRIMARY KEY,
	course_name TEXT NOT NULL,
	FOREIGN KEY(eid) REFERENCES Full_Time_Employees(eid) ON DELETE CASCADE,
	FOREIGN KEY(eid) REFERENCES Part_Time_Employees(eid) ON DELETE CASCADE,
	FOREIGN KEY(course_name) REFERENCES Course_Areas(name)
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
	status TEXT,
	fees numeric(12,2),
	end_date DATE,
	start_date DATE,
	capacity INTEGER,
	csc_id INTEGER,
	eid INTEGER NOT NULL,  
	PRIMARY KEY(csc_id, launch_date),
	FOREIGN KEY(csc_id) REFERENCES courses(csc_id) ON DELETE CASCADE,
	FOREIGN KEY(eid) REFERENCES Administrators(eid)
	CHECK (
		(select CAST(registration_deadline AS DATE) - CAST(start_date AS DATE)) >= 10
	)
);

CREATE TABLE Sessions(
	sid SERIAL,
	end_time TIMESTAMP,
	date DATE,
	start_time TIMESTAMP,
	csc_id INTEGER,
	launch_date DATE,
	eid INTEGER NOT NULL,
	PRIMARY KEY(sid, csc_id, launch_date),
	FOREIGN KEY(csc_id, launch_date) REFERENCES Course_Offerings(csc_id, launch_date) ON DELETE CASCADE,
	FOREIGN KEY(eid) REFERENCES Instructors(eid),
	CHECK (
		select EXTRACT(isodow FROM date) in (1,2,3,4,5)
	),
	CHECK (
		((select EXTRACT(hours FROM start_time) in (9,10,11)) and
		(select EXTRACT(hours FROM end_time) in (10,11,12))) 
		or
		((select EXTRACT(hours FROM start_time) in (14,15,16,17)) and
		(select EXTRACT(hours FROM end_time) in (15,16,17,18)))
	)
	CHECK (
		(select EXTRACT(hours FROM end_time)) > (select EXTRACT(hours FROM start_time))
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
	PRIMARY KEY (cust_id, sid, cancel_date, launch_date, csc_id),
	FOREIGN KEY (cust_id) REFERENCES Customers(cust_id),
	FOREIGN KEY (sid, launch_date, csc_id) REFERENCES Sessions(sid, launch_date,csc_id)
);




