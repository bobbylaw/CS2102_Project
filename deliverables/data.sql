-- Employee Administrator (10 rows)
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
call add_employee ('Dione Alvis', '67754 Thackeray Plaza', '(636) 3855284', 'dalvisf@ihg.com', (1800, 'monthly'), '2020-12-28', 'administrator');

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
call add_employee ('Shelagh Glenwright', '83925 Ludington Center', '(630) 4688864', 'sglenwright7@ning.com', (1800,'monthly'), '2020-03-29', 'manager', null);

-- Employee Full-time-Instructor (7 rows)
call add_employee ('Carlin Binding', '40 Butternut Way', '(564) 2063343', 'cbindingw@marriott.com', (2000, 'monthly'), '2020-06-25', 'instructor', '{Computer Science}');
call add_employee ('Lettie Jewett', '00 Linden Parkway', '(572) 1491067', 'ljewettm@dropbox.com', (2100, 'monthly'), '2020-07-19', 'instructor', '{Business}');
call add_employee ('Alexina Philp', '48551 Dovetail Road', '(560) 4995603', 'aphilpo@about.me', (1800, 'monthly'), '2020-09-26', 'instructor', '{Biomedical Engineering}');
call add_employee ('Nona Cambell', '914 Dexter Way', '(647) 5171857', 'ncambelll@tripod.com', (1900, 'monthly'), '2020-09-26', 'instructor', '{Chemical Engineering}');
call add_employee ('Woodrow Heggadon', '9756 Debra Alley', '(918) 8122541', 'wheggadonn@qq.com', (1900, 'monthly'), '2020-10-23', 'instructor', '{Biomedical Engineering, Computer Engineering}');
call add_employee ('Hildegarde Le Leu', '554 Ludington Hill', '(658) 3260086', 'hlep@bloglines.com', (2000, 'monthly'), '2020-11-03', 'instructor', '{Business, Accountancy}');
call add_employee ('Axe Riggeard', '4 Stone Corner Junction', '(814) 4788895', 'ariggeardr@instagram.com', (2400, 'monthly'), '2020-12-30', 'instructor', '{Electrical Engineering, Medicine}');

-- Employee Part-time-Instructor (7 rows)
call add_employee ('Matias Glanfield', '094 Kipling Trail', '(385) 9637088', 'mglanfields@github.com', (15, 'hourly'), '2020-06-04', 'instructor', '{Computer Engineering}');
call add_employee ('Mirilla Hunnywell', '420 Texas Alley', '(737) 5263148', 'mhunnywellv@theglobeandmail.com', (17, 'hourly'), '2020-07-07', 'instructor', '{Accountancy}');
call add_employee ('Simone Caddens', '228 Elgar Park', '(575) 6226111', 'scaddensq@comsenz.com', (18, 'hourly'), '2020-09-26', 'instructor', '{Chemical Engineering}');
call add_employee ('Betty Probate', '49889 Oak Valley Drive', '(726) 3851701', 'bprobatet@washington.edu', (16, 'hourly'), '2020-09-29', 'instructor', '{Computer Science}');
call add_employee ('Caesar McCrainor', '77809 Vera Trail', '(352) 3390720', 'cmccrainorx@nsw.gov.au', (15, 'hourly'), '2020-12-27', 'instructor', '{Medicine, Food Science and Technology}');
call add_employee ('Elvira Pinckney', '3550 Pepper Wood Crossing', '(209) 5765041', 'epinckneyy@cnbc.com', (16, 'hourly'), '2020-12-29', 'instructor', '{Design and Environment, Music}');
call add_employee ('Cello Gregorowicz', '3945 Talmadge Park', '(122) 3027611', 'cgregorowiczu@npr.org', (18, 'hourly'), '2020-12-31', 'instructor', '{Law, Business}');

-- Courses (assuming time is in hours)
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

-- Rooms (Keep is simple with 2 floor and 2 rooms each, all can sit 30 person)
INSERT INTO Rooms VALUES (1, 'Floor 1 Room 1', 30);
INSERT INTO Rooms VALUES (2, 'Floor 1 Room 2', 30);
INSERT INTO Rooms VALUES (3, 'Floor 2 Room 1', 30);
INSERT INTO Rooms VALUES (4, 'Floor 2 Room 2', 30);

-- Course Offerings (There is 11 courses, 10 courses is offered every month, registration is a month before it start)
call add_course_offerings(7, 58.00, '2020-12-01', '2020-12-27', 60, 7,  '{"(2021-01-12, 9:00, 3)","(2021-01-14, 9:00, 3)","(2021-01-18, 9:00, 3)"}');
call add_course_offerings(8, 108.00, '2020-12-01', '2020-12-27', 50, 8,  '{"(2021-01-12, 16:00, 1)","(2021-01-14, 16:00, 1)","(2021-01-18, 16:00, 1)"}');
call add_course_offerings(9, 88.00, '2020-12-01', '2020-12-27', 70, 9,  '{"(2021-01-19, 9:00, 1)","(2021-01-20, 9:00, 1)","(2021-01-21, 9:00, 1)"}');
call add_course_offerings(10, 78.00, '2020-12-01', '2020-12-31', 80, 10,  '{"(2021-01-19, 14:00, 1)","(2021-01-20, 14:00, 1)","(2021-01-21, 14:00, 1)"}');
call add_course_offerings(1, 68.00, '2021-04-01', '2021-04-30', 70, 1,  '{"(2021-05-10, 9:00, 1)","(2021-05-12, 9:00, 1)","(2021-05-14, 9:00, 1)"}'); 
call add_course_offerings(2, 98.00, '2021-04-01', '2021-04-30', 50, 2,  '{"(2021-05-10, 14:00, 2)","(2021-05-12, 14:00, 2)","(2021-05-14, 14:00, 2)"}');
call add_course_offerings(3, 68.00, '2021-04-01', '2021-04-30', 80, 3,  '{"(2021-05-10, 9:00, 3)","(2021-05-12, 9:00, 3)","(2021-05-14, 9:00, 3)"}');
call add_course_offerings(4, 38.00, '2021-04-01', '2021-04-30', 80, 4,  '{"(2021-05-17, 14:00, 4)","(2021-05-19, 14:00, 4)","(2021-05-21, 14:00, 4)"}');
call add_course_offerings(5, 48.00, '2021-04-01', '2021-04-30', 40, 5,  '{"(2021-05-17, 9:00, 1)","(2021-05-19, 9:00, 1)","(2021-05-21, 9:00, 1)"}');
call add_course_offerings(6, 58.00, '2021-04-01', '2021-04-30', 60, 6,  '{"(2021-05-17, 14:00, 2)","(2021-05-19, 14:00, 2)","(2021-05-21, 14:00, 2)"}');

-- Customers
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
