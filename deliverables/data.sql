--Restart seq number
ALTER SEQUENCE course_packages_package_id_seq RESTART;
ALTER SEQUENCE courses_course_id_seq RESTART;
ALTER SEQUENCE customers_cust_id_seq RESTART;
ALTER SEQUENCE employees_eid_seq RESTART;
ALTER SEQUENCE sessions_sid_seq RESTART;

-- Employee Administrator (10 rows)
-- SYNTAX: add_employee(name TEXT, home_address TEXT, contact_number TEXT, email_address TEXT, salary_information SALARY_INFORMATION, join_date DATE, catagory TEXT, course_areas TEXT[] DEFAULT NULL)
call add_employee ('Bevan Douglass', '8875 Dawn Street', '(844) 9752140', 'bdouglassj@wired.com', (2200, 'monthly'), '2020-06-10', 'administrator');
call add_employee ('Jessalin Wimpeney', '50 Westridge Place', '(535) 5671239', 'jwimpeneyh@delicious.com', (2300, 'monthly'), '2020-06-16', 'administrator');
call add_employee ('Zola Bugge', '27 Green Ridge Avenue', '(557) 6403274', 'zbugged@tinypic.com', (2500, 'monthly'), '2020-07-04', 'administrator');
call add_employee ('Aurelie Robilliard', '875 Morning Avenue', '(339) 4696952', 'arobilliardi@tamu.edu', (1900, 'monthly'), '2020-08-10', 'administrator');
call add_employee ('Irita Whitter', '1271 Canary Plaza', '(424) 5407778', 'iwhittera@fema.gov', (2200, 'monthly'), '2020-08-31', 'administrator');
call add_employee ('Otho Bloxland', '7197 Gale Place', '(999) 7739490', 'obloxlandc@home.pl', (1800, 'monthly'), '2020-09-23', 'administrator');
call add_employee ('Elbertine Orth', '6902 Bunting Hill', '(941) 6019839', 'eorthk@globo.com', (2000, 'monthly'), '2020-09-26', 'administrator');
call add_employee ('Ashlen Muslim', '47 Dapin Point', '(985) 9995566', 'amuslimb@icq.com', (2300, 'monthly'), '2020-10-05', 'administrator');
call add_employee ('Karney Southers', '90661 Pennsylvania Circle', '(818) 1870846', 'ksouthersg@google.de', (2100, 'monthly'), '2020-10-16', 'administrator');
call add_employee ('Matty Bimson', '29 Meadow Ridge Crossing', '(525) 8143351', 'mbimsone@nasa.gov', (2000, 'monthly'), '2020-12-21', 'administrator');

-- Employee Manager (10 rows)
call add_employee ('Blake Rose', '5 Dexter Point', '(423) 9275303', 'brose5@bloglines.com', (2600,'monthly'), '2020-04-18', 'manager', '{Computer Science, Computer Engineering}');
call add_employee ('Fernande McGuane', '4 Grover Lane', '(859) 2294082', 'fmcguane8@cbc.ca', (2700,'monthly'), '2020-06-25', 'manager', '{Business, Accountancy}');
call add_employee ('Jerald Satterlee', '31031 Jackson Point', '(870) 9507416', 'jsatterlee2@epa.gov', (2400,'monthly'), '2020-08-31', 'manager', '{Chemical Engineering, Biomedical Engineering}');
call add_employee ('Baxie Tupp', '708 Becker Way', '(595) 3406580', 'btupp4@chron.com', (2500,'monthly'), '2020-11-08', 'manager', '{Electrical Engineering}');
call add_employee ('Dillon Anderer', '394 Novick Plaza', '(962) 6235486', 'danderer3@networkadvertising.org', (2300,'monthly'), '2020-11-29', 'manager', '{Medicine}');
call add_employee ('Garner Alfonso', '6 Morrow Circle', '(637) 4068164', 'galfonso0@soundcloud.com', (2100,'monthly'), '2020-12-06', 'manager', '{Food Science and Technology}');
call add_employee ('Maddie Torbett', '92842 Dennis Place', '(699) 6491511', 'mtorbett1@utexas.edu', (2200,'monthly'), '2020-12-24', 'manager', '{Design and Environment}');
call add_employee ('Omero Churchyard', '42636 Nobel Hill', '(240) 7094122', 'ochurchyard6@howstuffworks.com', (2200,'monthly'), '2020-12-25', 'manager', '{Music}');
call add_employee ('Lebbie Goulter', '5634 Upham Center', '(967) 3520624', 'lgoulter9@parallels.com', (1900,'monthly'), '2020-12-27', 'manager', '{Law}');
call add_employee ('Shelagh Glenwright', '83925 Ludington Center', '(630) 4688864', 'sglenwright7@ning.com', (1800,'monthly'), '2021-04-02', 'manager', null);

-- Employee Full-time-Instructor (10 rows)
call add_employee ('Carlin Binding', '40 Butternut Way', '(564) 2063343', 'cbindingw@marriott.com', (2000, 'monthly'), '2020-06-25', 'instructor', '{Computer Science}');
call add_employee ('Lettie Jewett', '00 Linden Parkway', '(572) 1491067', 'ljewettm@dropbox.com', (2100, 'monthly'), '2020-07-19', 'instructor', '{Business}');
call add_employee ('Alexina Philp', '48551 Dovetail Road', '(560) 4995603', 'aphilpo@about.me', (1800, 'monthly'), '2020-09-26', 'instructor', '{Biomedical Engineering}');
call add_employee ('Nona Cambell', '914 Dexter Way', '(647) 5171857', 'ncambelll@tripod.com', (1900, 'monthly'), '2020-09-26', 'instructor', '{Chemical Engineering}');
call add_employee ('Woodrow Heggadon', '9756 Debra Alley', '(918) 8122541', 'wheggadonn@qq.com', (1900, 'monthly'), '2020-10-23', 'instructor', '{Biomedical Engineering, Computer Engineering}');
call add_employee ('Hildegarde Le Leu', '554 Ludington Hill', '(658) 3260086', 'hlep@bloglines.com', (2000, 'monthly'), '2020-11-03', 'instructor', '{Business, Accountancy}');
call add_employee ('Axe Riggeard', '4 Stone Corner Junction', '(814) 4788895', 'ariggeardr@instagram.com', (2400, 'monthly'), '2020-12-30', 'instructor', '{Electrical Engineering, Medicine}');
call add_employee ('Malorie Jansson', '2 Waxwing Point', '(346) 9042158', 'mjansson7@archive.org', (2400, 'monthly'), '2021-01-09', 'instructor', '{Music}');
call add_employee ('Christiana Myford', '70 Sheridan Center', '(224) 2820253', 'cmyford8@wsj.com', (2300, 'monthly'), '2020-01-05', 'instructor', '{Food Science and Technology}');
call add_employee ('Genny Townson', '7 Reindahl Avenue', '(554) 4651911', 'gtownson9@sogou.com', (1900, 'monthly'), '2020-04-16', 'instructor', '{Design and Environment}');


-- Employee Part-time-Instructor (10 rows)
call add_employee ('Matias Glanfield', '094 Kipling Trail', '(385) 9637088', 'mglanfields@github.com', (15, 'hourly'), '2020-06-04', 'instructor', '{Computer Engineering}');
call add_employee ('Mirilla Hunnywell', '420 Texas Alley', '(737) 5263148', 'mhunnywellv@theglobeandmail.com', (17, 'hourly'), '2020-07-07', 'instructor', '{Accountancy}');
call add_employee ('Simone Caddens', '228 Elgar Park', '(575) 6226111', 'scaddensq@comsenz.com', (18, 'hourly'), '2020-09-26', 'instructor', '{Chemical Engineering}');
call add_employee ('Betty Probate', '49889 Oak Valley Drive', '(726) 3851701', 'bprobatet@washington.edu', (16, 'hourly'), '2020-09-29', 'instructor', '{Computer Science}');
call add_employee ('Caesar McCrainor', '77809 Vera Trail', '(352) 3390720', 'cmccrainorx@nsw.gov.au', (15, 'hourly'), '2020-12-27', 'instructor', '{Medicine, Food Science and Technology}');
call add_employee ('Elvira Pinckney', '3550 Pepper Wood Crossing', '(209) 5765041', 'epinckneyy@cnbc.com', (16, 'hourly'), '2020-12-29', 'instructor', '{Design and Environment, Music}');
call add_employee ('Cello Gregorowicz', '3945 Talmadge Park', '(122) 3027611', 'cgregorowiczu@npr.org', (18, 'hourly'), '2020-12-31', 'instructor', '{Law, Business}');
call add_employee ('Pebrook Shillum', '794 Fieldstone Center', '(395) 8949423', 'pshillum4@businessweek.com', (14, 'hourly'), '2020-07-29', 'instructor', '{Electrical Engineering}');
call add_employee ('Adrianna Divis', '688 Carioca Trail', '(140) 9471960', 'adivis5@facebook.com', (12, 'hourly'), '2020-01-07', 'instructor', '{Music}');
call add_employee ('Bree Wolfinger', '86 Red Cloud Park', '(878) 2967928', 'bwolfinger6@prlog.org', (17, 'hourly'), '2020-10-16', 'instructor', '{Accountancy}');


-- Simulate employee left company
call remove_employee('sglenwright7@ning.com', '2021-04-08');

-- Courses (assuming time is in hours)
-- SYNTAX: add_course(IN course_title TEXT, IN course_description TEXT, IN course_area TEXT, IN course_duration INTERVAL)
call add_course ('Programming Methodology', 'This course introduces the concepts of programming and computational problem solving, and is the first and foremost introductory course to computing.', 'Computer Science',  INTERVAL '2 hour');
call add_course ('Legal Environment of Business', 'This course will equip business students with basic legal knowledge relating to commercial transactions so that they will be more aware of potential legal problems', 'Business', INTERVAL '4 hour');
call add_course ('Computer Organization', 'This course teaches students computer organization concepts and how to write efficient microprocessor programs using assembly language.', 'Computer Engineering', INTERVAL '3 hour');
call add_course ('Science of Music', 'This course aims to establish clear relationships between the basic elements of music found in virtually all musical cultures and their underlying scientific and mathematical principles.', 'Music', INTERVAL '1 hour');
call add_course ('Signals and Systems', 'This is a fundamental course in signals and systems. Signals in electrical engineering play an important role in carrying information.', 'Electrical Engineering', INTERVAL '3 hour');
call add_course ('Singapore Employment Law', 'The course introduces students to the development of industrial relations and labour laws in Singapore.', 'Law', INTERVAL '2 hour');
call add_course ('Financial Accounting', 'The course provides an introduction to financial accounting.', 'Accountancy', INTERVAL '2 hour');
call add_course ('General Biology', 'The course will introduce the chemistry of life and the unit of life.', 'Biomedical Engineering', INTERVAL '2 hour');
call add_course ('Modern Technology in Medicine and Health', 'The course provides an insight into the scientific principles underlying these new and powerful technologies.', 'Medicine', INTERVAL '2 hour');
call add_course ('Ideas and Approaches in Design', 'This course provides and introduction to some of the basic concepts in and approaches to architecture as a practice and as an academic discipline.', 'Design and Environment', INTERVAL '4 hour');
call add_course ('Chemical Engineering Principles', 'The core of the course covers the details of steady state material and energy balance, including recycle, purge, phase change and chemical reaction.', 'Chemical Engineering', INTERVAL '2 hour');

-- Rooms
INSERT INTO Rooms VALUES (1, 'Floor 1 Room 1', 30);
INSERT INTO Rooms VALUES (2, 'Floor 1 Room 2', 30);
INSERT INTO Rooms VALUES (3, 'Floor 1 Room 3', 30);
INSERT INTO Rooms VALUES (4, 'Floor 1 Room 4', 30);
INSERT INTO Rooms VALUES (5, 'Floor 1 Room 5', 30);
INSERT INTO Rooms VALUES (6, 'Floor 2 Room 1', 30);
INSERT INTO Rooms VALUES (7, 'Floor 2 Room 2', 30);
INSERT INTO Rooms VALUES (8, 'Floor 2 Room 3', 30);
INSERT INTO Rooms VALUES (9, 'Floor 2 Room 4', 30);
INSERT INTO Rooms VALUES (10, 'Floor 2 Room 5', 30);

-- Course Offerings (There is 11 courses, 10 courses is offered, registration is almost a month before it start)
-- SYNTAX: add_course_offerings (IN course_title TEXT, IN course_fees NUMERIC(12,2), IN launch_date DATE, IN registration_deadline DATE, IN target_number_of_registration INTEGER, IN administrator_email TEXT, IN session_info SESSION_INFORMATION[])
call add_course_offerings('Programming Methodology', 68.00, '2021-04-01', '2021-04-29', 70, 'bdouglassj@wired.com',  '{"(2021-05-10, 9:00, 1)","(2021-05-12, 9:00, 1)","(2021-05-14, 9:00, 1)"}');
call add_course_offerings('Programming Methodology', 68.00, '2021-04-05', '2021-04-28', 70, 'bdouglassj@wired.com',  '{"(2021-05-11, 9:00, 2)","(2021-05-13, 9:00, 2)","(2021-05-17, 9:00, 2)"}'); 
call add_course_offerings('Legal Environment of Business', 98.00, '2021-04-01', '2021-04-30', 50, 'jwimpeneyh@delicious.com',  '{"(2021-05-10, 14:00, 2)","(2021-05-12, 14:00, 2)","(2021-05-14, 14:00, 2)"}');
call add_course_offerings('Legal Environment of Business', 98.00, '2021-04-05', '2021-04-28', 50, 'jwimpeneyh@delicious.com',  '{"(2021-05-11, 14:00, 2)","(2021-05-13, 14:00, 2)","(2021-05-17, 14:00, 2)"}');
call add_course_offerings('Computer Organization', 68.00, '2021-04-01', '2021-04-29', 80, 'zbugged@tinypic.com',  '{"(2021-05-10, 9:00, 3)","(2021-05-12, 9:00, 3)","(2021-05-14, 9:00, 3)"}');
call add_course_offerings('Science of Music', 38.00, '2021-04-01', '2021-04-29', 80, 'arobilliardi@tamu.edu',  '{"(2021-05-17, 14:00, 4)","(2021-05-19, 14:00, 4)","(2021-05-21, 14:00, 4)"}');
call add_course_offerings('Signals and Systems', 48.00, '2021-04-01', '2021-04-30', 40, 'iwhittera@fema.gov',  '{"(2021-05-17, 9:00, 5)","(2021-05-19, 9:00, 5)","(2021-05-21, 9:00, 5)"}');
call add_course_offerings('Singapore Employment Law', 58.00, '2021-04-01', '2021-04-30', 60, 'obloxlandc@home.pl',  '{"(2021-05-17, 14:00, 6)","(2021-05-19, 14:00, 6)","(2021-05-21, 14:00, 6)"}');
call add_course_offerings('Financial Accounting', 58.00, '2020-12-01', '2020-12-27', 60, 'eorthk@globo.com',  '{"(2021-01-12, 9:00, 7)","(2021-01-14, 9:00, 7)","(2021-01-18, 9:00, 7)"}');
call add_course_offerings('General Biology', 108.00, '2020-12-01', '2020-12-27', 50, 'amuslimb@icq.com',  '{"(2021-01-12, 16:00, 8)","(2021-01-14, 16:00, 8)","(2021-01-18, 16:00, 8)"}');
call add_course_offerings('Modern Technology in Medicine and Health', 88.00, '2020-12-01', '2020-12-27', 70, 'ksouthersg@google.de',  '{"(2021-01-19, 9:00, 9)","(2021-01-20, 9:00, 9)","(2021-01-21, 9:00, 9)"}');
call add_course_offerings('Chemical Engineering Principles', 78.00, '2020-12-01', '2020-12-31', 80, 'mbimsone@nasa.gov',  '{"(2021-01-19, 14:00, 10)","(2021-01-20, 14:00, 10)","(2021-01-21, 14:00, 10)"}');

-- Customers
-- SYNTAX: add_customer(IN input_cust_name TEXT, IN input_address TEXT, IN input_phone TEXT, IN input_email TEXT, IN input_card_number TEXT, IN input_expiry_date DATE, IN input_CVV INTEGER)
CALL add_customer('Suzy Standrin', '61 Oriole Crossing', '(513) 9443136', 'sstandrin0@i2i.jp', '4041374696425943', '2023-01-15', 911);
CALL add_customer('Farrand Agastina', '644 Independence Plaza', '(754) 2932401', 'fagastina1@guardian.co.uk', '4017950493001035', '2022-12-03', 911);
CALL add_customer('Martynne Dabbs', '9 Moose Crossing', '(408) 3827563', 'mdabbs2@wp.com', '4041374159205451', '2023-03-23', 234);
CALL add_customer('Ingrim Ottewell', '6 Mccormick Avenue', '(949) 5334791', 'iottewell3@moonfruit.com', '4041372734814', '2023-03-10', 811);
CALL add_customer('Antonietta Truscott', '7 6th Circle', '(253) 6618273', 'atruscott4@forbes.com', '4041373626338879', '2022-06-04', 884);
CALL add_customer('Allix Chapman', '430 Division Alley', '(559) 1892244', 'achapman5@yelp.com', '4017950608566187', '2023-02-07', 495);
CALL add_customer('Mada Sooper', '97 Esker Plaza', '(948) 3590358', 'msooper6@smugmug.com', '4017951761396594', '2022-08-12', 477);
CALL add_customer('Darby Riddington', '9674 Arizona Way', '(986) 8008194', 'driddington7@spotify.com', '4041379536444', '2022-09-19', 172);
CALL add_customer('Flory Alwell', '07 Ridge Oak Way', '(174) 1033142', 'falwell8@dell.com', '4017950159210', '2023-03-13', 213);
CALL add_customer('Ax de Mendoza', '4421 Melvin Avenue', '(538) 9763902', 'ade9@cyberchimps.com', '4017952580157', '2022-11-15', 976);

-- Sessions 
-- SYNTAX: add_session(IN input_course_title TEXT, IN input_launch_date DATE, IN input_sid INTEGER, IN input_session_day DATE, IN input_session_start_hour TIME, IN input_instructor_email TEXT, IN input_rid INTEGER)
call add_session('Programming Methodology', '2021-04-01', 4, '2021-05-18', '09:00:00', 'cbindingw@marriott.com', 1);
call add_session('Legal Environment of Business', '2021-04-01', 4, '2021-05-18', '14:00:00', 'ljewettm@dropbox.com', 2);
call add_session('Computer Organization', '2021-04-01', 4, '2021-05-18', '15:00:00', 'mglanfields@github.com', 3);
call add_session('Science of Music', '2021-04-01', 4, '2021-05-20', '17:00:00', 'epinckneyy@cnbc.com', 4);
call add_session('Signals and Systems', '2021-04-01', 4, '2021-05-20', '09:00:00', 'ariggeardr@instagram.com', 5);
call add_session('Singapore Employment Law', '2021-04-01', 4, '2021-05-20', '10:00:00', 'cgregorowiczu@npr.org', 6);
call add_session('Financial Accounting', '2020-12-01', 4, '2021-01-13', '10:00:00', 'hlep@bloglines.com', 7);
call add_session('General Biology', '2020-12-01', 4, '2021-01-13', '14:00:00', 'aphilpo@about.me', 8);
call add_session('Modern Technology in Medicine and Health', '2020-12-01', 4, '2021-01-22', '14:00:00', 'cmccrainorx@nsw.gov.au', 9);
call add_session('Chemical Engineering Principles', '2020-12-01', 4, '2021-01-22', '14:00:00', 'ncambelll@tripod.com', 10);

-- Registers
-- SYNTAX: register_sessions(IN customer_email TEXT, IN course_title TEXT, IN offering_launch_date DATE, IN session_id INTEGER, payment_method TEXT)
call register_sessions('sstandrin0@i2i.jp', 'Programming Methodology', '2021-04-05', 1, 'credit card');
call register_sessions('fagastina1@guardian.co.uk', 'Legal Environment of Business', '2021-04-05', 1, 'credit card');
call register_sessions('mdabbs2@wp.com', 'Computer Organization', '2021-04-01', 1, 'credit card');
call register_sessions('iottewell3@moonfruit.com', 'Science of Music', '2021-04-01', 1, 'credit card');
call register_sessions('atruscott4@forbes.com', 'Signals and Systems', '2021-04-01', 1, 'credit card');
call register_sessions('achapman5@yelp.com', 'Singapore Employment Law', '2021-04-01', 1, 'credit card');
-- these onwards are repeats
call register_sessions('msooper6@smugmug.com', 'Programming Methodology', '2021-04-05', 1, 'credit card');
call register_sessions('driddington7@spotify.com', 'Legal Environment of Business', '2021-04-05', 1, 'credit card');
call register_sessions('falwell8@dell.com', 'Computer Organization', '2021-04-01', 1, 'credit card');
call register_sessions('ade9@cyberchimps.com', 'Science of Music', '2021-04-01', 1, 'credit card');

--Course packages
--SYNTAX: add_course_package(IN input_package_name TEXT, IN input_num_free_registration INTEGER, IN input_sales_start_date DATE, IN input_sales_end_date DATE, IN input_price NUMERIC(12,2))
call add_course_package('pkg-01', 5, '2021-04-01', '2021-04-17', 25.00);
call add_course_package('pkg-02', 5, '2021-04-07', '2021-04-15', 20.00);
call add_course_package('pkg-03', 10, '2021-04-05', '2021-05-05', 40.00);
call add_course_package('pkg-04', 8, '2021-04-07', '2021-04-30', 30.00);
call add_course_package('pkg-05', 15, '2021-04-05', '2021-04-20', 60.00);
call add_course_package('pkg-06', 20, '2021-04-01', '2021-04-30', 75.00);
call add_course_package('pkg-07', 20, '2021-04-05', '2021-05-30', 75.00);

--Buys
--SYNTAX:buy_course_package(IN input_customer_email TEXT, IN input_package_name TEXT)
call buy_course_package('sstandrin0@i2i.jp', 'pkg-01');
call buy_course_package('fagastina1@guardian.co.uk', 'pkg-01');
call buy_course_package('mdabbs2@wp.com', 'pkg-02');
call buy_course_package('iottewell3@moonfruit.com', 'pkg-03');
call buy_course_package('falwell8@dell.com', 'pkg-01');
call buy_course_package('atruscott4@forbes.com', 'pkg-05');
call buy_course_package('ade9@cyberchimps.com', 'pkg-04');
call buy_course_package('driddington7@spotify.com', 'pkg-06');
call buy_course_package('msooper6@smugmug.com', 'pkg-07');
call buy_course_package('achapman5@yelp.com', 'pkg-03');

--Redeems
--SYNTAX: register_sessions(IN customer_email TEXT, IN course_title TEXT, IN offering_launch_date DATE, IN session_id INTEGER, payment_method TEXT)
call register_sessions('sstandrin0@i2i.jp', 'Computer Organization', '2021-04-01', 2, 'redemption');
call register_sessions('sstandrin0@i2i.jp', 'Legal Environment of Business', '2021-04-01', 2, 'redemption');
call register_sessions('sstandrin0@i2i.jp', 'Science of Music', '2021-04-01', 1, 'redemption');
call register_sessions('fagastina1@guardian.co.uk', 'Programming Methodology', '2021-04-01', 2, 'redemption');
call register_sessions('fagastina1@guardian.co.uk', 'Computer Organization', '2021-04-01', 1, 'redemption');
call register_sessions('fagastina1@guardian.co.uk', 'Science of Music', '2021-04-01', 1, 'redemption');
call register_sessions('mdabbs2@wp.com', 'Programming Methodology', '2021-04-01', 3, 'redemption');
call register_sessions('mdabbs2@wp.com', 'Legal Environment of Business', '2021-04-01', 1, 'redemption');
call register_sessions('mdabbs2@wp.com', 'Science of Music', '2021-04-01', 1, 'redemption');
call register_sessions('iottewell3@moonfruit.com', 'Programming Methodology', '2021-04-01', 2, 'redemption');
call register_sessions('iottewell3@moonfruit.com', 'Computer Organization', '2021-04-01', 2, 'redemption');
call register_sessions('iottewell3@moonfruit.com', 'Legal Environment of Business', '2021-04-01', 1, 'redemption');

--Cancels
--SYNTAX: cancel_registration(IN customer_email TEXT, IN course_title TEXT, IN offering_launch_date DATE)
call cancel_registration('sstandrin0@i2i.jp', 'Computer Organization', '2021-04-01');
call register_sessions('sstandrin0@i2i.jp', 'Computer Organization', '2021-04-01', 2, 'redemption'); -- Add back to redeem
call cancel_registration('sstandrin0@i2i.jp', 'Legal Environment of Business', '2021-04-01');
call register_sessions('sstandrin0@i2i.jp', 'Legal Environment of Business', '2021-04-01', 2, 'redemption');
call cancel_registration('sstandrin0@i2i.jp', 'Science of Music', '2021-04-01');
call register_sessions('sstandrin0@i2i.jp', 'Science of Music', '2021-04-01', 1, 'redemption');
call cancel_registration('fagastina1@guardian.co.uk', 'Programming Methodology', '2021-04-01');
call register_sessions('fagastina1@guardian.co.uk', 'Programming Methodology', '2021-04-01', 2, 'redemption');
call cancel_registration('fagastina1@guardian.co.uk', 'Computer Organization', '2021-04-01');
call register_sessions('fagastina1@guardian.co.uk', 'Computer Organization', '2021-04-01', 1, 'redemption');
call cancel_registration('fagastina1@guardian.co.uk', 'Science of Music', '2021-04-01');
call register_sessions('fagastina1@guardian.co.uk', 'Science of Music', '2021-04-01', 1, 'redemption');

call cancel_registration('sstandrin0@i2i.jp', 'Programming Methodology', '2021-04-05');
call register_sessions('sstandrin0@i2i.jp', 'Programming Methodology', '2021-04-05', 1, 'credit card'); -- Add back register
call cancel_registration('fagastina1@guardian.co.uk', 'Legal Environment of Business', '2021-04-05');
call register_sessions('fagastina1@guardian.co.uk', 'Legal Environment of Business', '2021-04-05', 1, 'credit card');
call cancel_registration('mdabbs2@wp.com', 'Computer Organization', '2021-04-01');
call register_sessions('mdabbs2@wp.com', 'Computer Organization', '2021-04-01', 1, 'credit card');
call cancel_registration('iottewell3@moonfruit.com', 'Science of Music', '2021-04-01');
call register_sessions('iottewell3@moonfruit.com', 'Science of Music', '2021-04-01', 1, 'credit card');
call cancel_registration('atruscott4@forbes.com', 'Signals and Systems', '2021-04-01');
call register_sessions('atruscott4@forbes.com', 'Signals and Systems', '2021-04-01', 1, 'credit card');
call cancel_registration('achapman5@yelp.com', 'Singapore Employment Law', '2021-04-01');
call register_sessions('achapman5@yelp.com', 'Singapore Employment Law', '2021-04-01', 1, 'credit card');

call cancel_registration('msooper6@smugmug.com', 'Programming Methodology', '2021-04-05'); -- cancels register
call register_sessions('msooper6@smugmug.com', 'Programming Methodology', '2021-04-05', 1, 'redemption'); -- redeem same course offering
call cancel_registration('msooper6@smugmug.com', 'Programming Methodology', '2021-04-05'); -- cancel the course offering which just redeem
call register_sessions('msooper6@smugmug.com', 'Programming Methodology', '2021-04-05', 1, 'credit card'); -- add back register.
-- Both refund_amt and package_credit is credited under same record.


--pay salary
select pay_salary()