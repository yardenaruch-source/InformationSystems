USE yardenaruch$FLYTAUdb;

DROP TABLE IF EXISTS Flight_attendants_in_flights;
DROP TABLE IF EXISTS Pilots_in_flights;
DROP TABLE IF EXISTS Flight_Class_Pricing;
DROP TABLE IF EXISTS Seat;
DROP TABLE IF EXISTS Cabin_class;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Flight_attendant;
DROP TABLE IF EXISTS Pilot;
DROP TABLE IF EXISTS Manager;
DROP TABLE IF EXISTS Registered_customer_phone;
DROP TABLE IF EXISTS Registered_customer;
DROP TABLE IF EXISTS Guest_phone;
DROP TABLE IF EXISTS Guest;
DROP TABLE IF EXISTS Flight_route;
DROP TABLE IF EXISTS Plane;

/* ===================== Plane ===================== */
CREATE TABLE Plane (
  plane_id VARCHAR(5) PRIMARY KEY,
  plane_size ENUM('Small','Large') NOT NULL,
  plane_manufacturer ENUM('Boeing','Airbus','Dassault') NOT NULL,
  purchase_date DATE NOT NULL
);

INSERT INTO Plane (plane_id, plane_size, plane_manufacturer, purchase_date)
VALUES
('P0001','Large','Boeing','2018-05-01'),
('P0002','Large','Airbus','2019-09-12'),
('P0003','Small','Dassault','2021-03-25'),
('P0004','Large','Dassault','2017-11-03'),
('P0005','Small','Airbus','2025-06-18'),
('P0006','Large','Airbus','2020-01-20');


/* ===================== Flight route ===================== */
CREATE TABLE Flight_route (
  route_id INT PRIMARY KEY,
  origin_airport VARCHAR(100) NOT NULL,
  destination_airport VARCHAR(100) NOT NULL,
  flight_duration INT NOT NULL,
  CONSTRAINT chk_route_duration CHECK (flight_duration > 0),
  CONSTRAINT chk_route_airports CHECK (origin_airport <> destination_airport)
);

INSERT INTO Flight_route
(route_id, origin_airport, destination_airport, flight_duration)
VALUES
-- Short flight
(101, 'TLV - Ben Gurion', 'ATH - Athens', 120),
(102, 'TLV - Ben Gurion', 'FCO - Rome', 180),
(103, 'TLV - Ben Gurion', 'DXB - Dubai', 190),
(104, 'ATH - Athens', 'FCO - Rome', 105),
(105, 'FCO - Rome', 'CDG - Paris', 110),
(106, 'CDG - Paris', 'BER - Berlin', 105),
(107, 'BER - Berlin', 'FCO - Rome', 120),
(114, 'FCO - Rome', 'TLV - Ben Gurion', 180),
-- Long flights
(108, 'BER - Berlin', 'JFK - New York', 510),
(109, 'JFK - New York', 'DXB - Dubai', 840),
(110, 'DXB - Dubai', 'SYD - Sydney', 1200),
(111, 'SYD - Sydney', 'AKL - Auckland', 190),
(112, 'AKL - Auckland', 'DXB - Dubai', 1020),
(113, 'DXB - Dubai', 'CDG - Paris', 420);


/* ===================== Guest ===================== */
CREATE TABLE Guest (
  customer_email VARCHAR(100) PRIMARY KEY,
  customer_first_name VARCHAR(60) NOT NULL,
  customer_last_name  VARCHAR(60) NOT NULL
);

INSERT INTO Guest (customer_email, customer_first_name, customer_last_name)
VALUES
('LiorB@gmail.com','Lior','Bar'),
('ShirP@gmail.com','Shir','Peretz'),
('EitanS@gmail.com','Eitan','Shalev'),
('noa.cohen@gmail.com','Noa','Cohen'),
('amit.levi@gmail.com','Amit','Levi'),
('daniel.mizrahi@gmail.com','Daniel','Mizrahi'),
('yael.peretz@gmail.com','Yael','Peretz'),
('itay.rosen@gmail.com','Itay','Rosen'),
('sharon.gold@gmail.com','Sharon','Gold'),
('omer.katz@gmail.com','Omer','Katz'),
('tal.friedman@gmail.com','Tal','Friedman'),
('lina.shahar@gmail.com','Lina','Shahar'),
('yonatan.benami@gmail.com','Yonatan','Ben-Ami'),
('maya.rubin@gmail.com','Maya','Rubin'),
('ron.eldar@gmail.com','Ron','Eldar'),
('gal.nadav@gmail.com','Gal','Nadav'),
('adi.weiss@gmail.com','Adi','Weiss'),
('neta.halevi@gmail.com','Neta','Halevi'),
('aviv.barkan@gmail.com','Aviv','Barkan'),
('shira.amir@gmail.com','Shira','Amir');


/* ===================== Guest phone ===================== */
CREATE TABLE Guest_phone (
  customer_email VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (customer_email, customer_phone),
  FOREIGN KEY (customer_email) REFERENCES Guest(customer_email)
);

INSERT INTO Guest_phone (customer_email, customer_phone)
VALUES
('LiorB@gmail.com','052-7350841'),
('LiorB@gmail.com','052-4358985'),
('ShirP@gmail.com','053-4901768'),
('ShirP@gmail.com','053-5201796'),
('EitanS@gmail.com','054-9826305'),
('EitanS@gmail.com','054-6885423'),
('noa.cohen@gmail.com','052-4817392'),
('amit.levi@gmail.com','054-6291834'),
('daniel.mizrahi@gmail.com','053-7482019'),
('yael.peretz@gmail.com','050-3918475'),
('yael.peretz@gmail.com','052-4014869'),
('itay.rosen@gmail.com','052-9051743'),
('sharon.gold@gmail.com','054-8126390'),
('omer.katz@gmail.com','053-4762981'),
('omer.katz@gmail.com','054-5063082'),
('tal.friedman@gmail.com','050-6289471'),
('lina.shahar@gmail.com','052-7391846'),
('yonatan.benami@gmail.com','054-3817502'),
('maya.rubin@gmail.com','053-9026481'),
('maya.rubin@gmail.com','052-1086671'),
('ron.eldar@gmail.com','050-7148392'),
('gal.nadav@gmail.com','052-8641937'),
('adi.weiss@gmail.com','054-2908471'),
('neta.halevi@gmail.com','053-6172849'),
('aviv.barkan@gmail.com','050-9384716'),
('aviv.barkan@gmail.com','055-4384572'),
('shira.amir@gmail.com','052-4716093');


/* ===================== Registered customer ===================== */
CREATE TABLE Registered_customer (
  customer_email VARCHAR(100) PRIMARY KEY,
  customer_first_name VARCHAR(60) NOT NULL,
  customer_last_name VARCHAR(60) NOT NULL,
  customer_password VARCHAR(8) NOT NULL,
  passport_id VARCHAR(9) NOT NULL UNIQUE,
  birth_date DATE NOT NULL,
  sign_up_date DATE NOT NULL
);


INSERT INTO Registered_customer
(customer_email, customer_first_name, customer_last_name, customer_password, passport_id, birth_date, sign_up_date)
VALUES
('roni.katz@gmail.com','Roni','Katz','Rc123456','A12345678','1996-04-12','2024-12-01'),
('yossi.dahan@gmail.com','Yossi','Dahan','Rc234567','B23456789','1990-09-03','2024-11-20'),
('maya.oren@gmail.com','Maya','Oren','Rc345678','C34567890','2001-02-18','2024-10-05'),
('noam.cohen@gmail.com','Noam','Cohen','Rc456789','D45678901','1992-01-18','2024-10-03'),
('yaara.levi@gmail.com','Yaara','Levi','Rc567890','E56789012','1998-07-22','2024-09-14'),
('idan.mizrahi@gmail.com','Idan','Mizrahi','Rc678901','F67890123','1989-03-05','2024-08-30'),
('shaked.peretz@gmail.com','Shaked','Peretz','Rc789012','G78901234','2000-11-12','2024-11-02'),
('lior.rosen@gmail.com','Lior','Rosen','Rc890123','H89012345','1995-06-27','2024-07-19'),
('tamar.gold@gmail.com','Tamar','Gold','Rc901234','I90123456','1991-02-09','2024-06-08'),
('omer.klein@gmail.com','Omer','Klein','Rc012345','J01234567','1997-09-03','2024-12-10'),
('yael.shahar@gmail.com','Yael','Shahar','Rc123890','K12389078','1994-04-16','2024-05-21'),
('niv.hazan@gmail.com','Niv','Hazan','Rc234901','L23490189','1988-12-28','2024-04-11'),
('maya.bitan@gmail.com','Maya','Bitan','Rc345012','M34501290','2002-01-31','2024-03-17'),
('eran.sela@gmail.com','Eran','Sela','Rc456123','N45612301','1990-08-14','2024-02-25'),
('shani.weiss@gmail.com','Shani','Weiss','Rc567234','O56723412','1999-10-06','2024-01-29'),
('aviv.doron@gmail.com','Aviv','Doron','Rc678345','P67834523','1993-05-20','2024-11-27'),
('liat.nadav@gmail.com','Liat','Nadav','Rc789456','Q78945634','1996-03-08','2024-10-16'),
('itamar.regev@gmail.com','Itamar','Regev','Rc890567','R89056745','1987-07-11','2024-09-05'),
('shir.amir@gmail.com','Shir','Amir','Rc901678','S90167856','2001-12-19','2024-08-01'),
('yonatan.bar@gmail.com','Yonatan','Bar','Rc012789','T01278967','1994-06-02','2024-06-30');

-- ('upsidedown@gmail.com','Will','Byers','iluvmike','H06111983','1971-03-22','2026-01-21')--
-- ('upsidedown1@gmail.com','Mike','Wheeler','loveel11','H07041971','1971-04-07','2026-01-21')--
-- ('upsidedown11@gmail.com','Jane','Hopper','11111111','H03121997','1997-12-03','2026-01-22')--
-- ('upsidedown12@gmail.com','Steve','Harrington','12121212','H12121212','1991-12-12','2026-01-22')--


/* ===================== Registered customer phone ===================== */
CREATE TABLE Registered_customer_phone (
  customer_email VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (customer_email, customer_phone),
  FOREIGN KEY (customer_email) REFERENCES Registered_customer(customer_email)
);

INSERT INTO Registered_customer_phone (customer_email, customer_phone)
VALUES
('roni.katz@gmail.com','054-6173928'),
('roni.katz@gmail.com','054-2133856'),
('yossi.dahan@gmail.com','055-9031846'),
('yossi.dahan@gmail.com','055-7238515'),
('maya.oren@gmail.com','058-2746195'),
('maya.oren@gmail.com','058-5696169'),
('noam.cohen@gmail.com','052-7349812'),
('yaara.levi@gmail.com','054-6183927'),
('idan.mizrahi@gmail.com','053-8291746'),
('shaked.peretz@gmail.com','050-4729183'),
('shaked.peretz@gmail.com','052-3228321'),
('lior.rosen@gmail.com','052-9053617'),
('tamar.gold@gmail.com','054-7812649'),
('omer.klein@gmail.com','053-6409182'),
('yael.shahar@gmail.com','050-8392716'),
('niv.hazan@gmail.com','052-4719083'),
('maya.bitan@gmail.com','054-9263817'),
('eran.sela@gmail.com','053-7102948'),
('eran.sela@gmail.com','053-8903056'),
('shani.weiss@gmail.com','050-6829147'),
('aviv.doron@gmail.com','052-3984716'),
('liat.nadav@gmail.com','054-5172938'),
('itamar.regev@gmail.com','053-8649201'),
('itamar.regev@gmail.com','053-8549754'),
('shir.amir@gmail.com','050-7391842'),
('yonatan.bar@gmail.com','052-9183647');

-- ('upsidedown@gmail.com','050-7348291')--
-- ('upsidedown1@gmail.com','052-3547219')--
-- ('upsidedown11@gmail.com','052-2319737')--
-- ('upsidedown11@gmail.com','054-9999952')--
-- ('upsidedown12@gmail.com','054-1212121')--


/* ===================== Manager ===================== */
CREATE TABLE Manager (
  employee_id VARCHAR(9) PRIMARY KEY,
  employee_first_name VARCHAR(60) NOT NULL,
  employee_last_name VARCHAR(60) NOT NULL,
  employee_phone VARCHAR(15) NOT NULL,
  employee_city VARCHAR(60) NOT NULL,
  employee_street VARCHAR(100) NOT NULL,
  employee_street_num INT NOT NULL,
  employment_date DATE NOT NULL,
  manager_password VARCHAR(8) NOT NULL
);

INSERT INTO Manager
(employee_id, employee_first_name, employee_last_name, employee_phone, employee_city, employee_street, employee_street_num, employment_date, manager_password)
VALUES
('248392176','דנה','לוי','050-7382914','Tel Aviv','Dizengoff',10,'2022-01-15','Mng12345'),
('203948517','אבי','כהן','052-4918603','Haifa','Herzl',25,'2021-06-01','Mng23456'),
('281460239','ערן','מזרחי','050-3333333','Jerusalem','Nelkin',7,'2023-03-20','Mng34567');


/* ===================== Pilot ===================== */
CREATE TABLE Pilot (
  employee_id VARCHAR(9) PRIMARY KEY,
  employee_first_name VARCHAR(60) NOT NULL,
  employee_last_name VARCHAR(60) NOT NULL,
  employee_phone VARCHAR(15) NOT NULL,
  employee_city VARCHAR(60) NOT NULL,
  employee_street VARCHAR(100) NOT NULL,
  employee_street_num INT NOT NULL,
  employment_date DATE NOT NULL,
  long_flight_training BOOLEAN NOT NULL DEFAULT 0
);

INSERT INTO Pilot
(employee_id, employee_first_name, employee_last_name, employee_phone, employee_city, employee_street, employee_street_num, employment_date, long_flight_training)
VALUES
('308457129','איתי','שרון','054-7364821','Tel Aviv','Begin',12,'2019-01-10',1),
('214963587','גיל','אברהם','052-9183746','Haifa','Hagana',5,'2018-05-21',1),
('396805742','עומר','נעים','050-6048279','Jerusalem','King George',33,'2020-09-14',0),
('287451936','טל','ביטן','053-4917268','Rishon LeZion','Rothschild',2,'2017-03-03',1),
('172604895','רמי','הלוי','058-2736491','Beer Sheva','Ben Gurion',18,'2021-07-08',0),
('459318260','ניב','ששון','055-8120947','Tel Aviv','Allenby',44,'2016-11-30',1),
('531794628','עידו','רגב','054-3659082','Netanya','Weizmann',9,'2015-02-19',1),
('648205173','שי','מור','052-7491836','Haifa','Carmel',77,'2022-04-25',1),
('704963581','יובל','פלד','050-9812364','Jerusalem','Hillel',6,'2014-08-12',1),
('893417256','ארז','קורן','053-6205749','Ashdod','HaAtzmaut',21,'2023-01-09',0);


/* ===================== Flight attendant ===================== */
CREATE TABLE Flight_attendant (
  employee_id VARCHAR(9) PRIMARY KEY,
  employee_first_name VARCHAR(60) NOT NULL,
  employee_last_name VARCHAR(60) NOT NULL,
  employee_phone VARCHAR(15) NOT NULL,
  employee_city VARCHAR(60) NOT NULL,
  employee_street VARCHAR(100) NOT NULL,
  employee_street_num INT NOT NULL,
  employment_date DATE NOT NULL,
  long_flight_training BOOLEAN NOT NULL DEFAULT 0
);

INSERT INTO Flight_attendant
(employee_id, employee_first_name, employee_last_name,
 employee_phone, employee_city, employee_street, employee_street_num,
 employment_date, long_flight_training)
VALUES
('143829506','יעל','כהן','055-2220001','Tel Aviv','Ibn Gabirol',10,'2020-02-01',1),
('275906314','שני','לוי','055-2220002','Haifa','Hatzionut',3,'2021-06-11',0),
('368541972','ניצן','בר','055-2220003','Jerusalem','Agron',8,'2019-10-09',1),
('419276805','גל','פרץ','055-2220004','Tel Aviv','Ben Yehuda',15,'2022-01-05',0),
('582013469','אור','שקד','055-2220005','Netanya','Herzl',19,'2018-07-22',1),
('697428351','עדי','נגר','055-2220006','Beer Sheva','Rager',4,'2017-03-17',1),
('724590168','תמר','דורון','055-2220007','Haifa','Moriah',55,'2023-05-01',0),
('831764290','ליאת','ממן','055-2220008','Ashdod','Menachem Begin',11,'2020-12-12',0),
('906215743','הילה','כץ','055-2220009','Rishon LeZion','HaPalmach',6,'2016-09-30',1),
('158374926','נועם','שחר','055-2220010','Tel Aviv','Kaplan',2,'2019-01-20',1),
('264805731','מיכל','אורן','055-2220011','Jerusalem','Emek Refaim',9,'2021-08-08',0),
('379162458','בר','סלע','055-2220012','Haifa','Allenby',14,'2015-04-14',1),
('481907236','רינה','חזן','055-2220013','Beer Sheva','HaNassi',1,'2018-11-11',0),
('590346817','עדן','אריאל','055-2220014','Tel Aviv','Arlozorov',30,'2017-06-06',1),
('618259704','שירה','נדב','055-2220015','Netanya','Sderot Chen',7,'2022-09-09',1),
('742816593','לנה','גולד','055-2220016','Haifa','Nordau',20,'2020-01-15',1),
('853490162','סיון','רוזן','055-2220017','Jerusalem','Jabotinsky',12,'2019-03-03',0),
('914627385','ירדן','ברג','055-2220018','Tel Aviv','Yigal Alon',18,'2016-02-02',1),
('236598174','אודליה','שטרן','055-2220019','Ashkelon','HaNassi',5,'2023-02-14',0),
('467120958','רותם','חורי','055-2220020','Rishon LeZion','Gordon',23,'2021-12-01',1);


/* ===================== Flight ===================== */
CREATE TABLE Flight (
  flight_id VARCHAR(5) PRIMARY KEY,
  route_id INT NOT NULL,
  plane_id VARCHAR(5) NOT NULL,
  manager_id VARCHAR(9) NOT NULL,
  takeoff_date DATE NOT NULL,
  takeoff_time TIME NOT NULL,
  flight_status ENUM('Scheduled','Full','Completed','Cancelled') NOT NULL,
  FOREIGN KEY (route_id) REFERENCES Flight_route(route_id),
  FOREIGN KEY (plane_id) REFERENCES Plane(plane_id),
  FOREIGN KEY (manager_id) REFERENCES Manager(employee_id)
);

INSERT INTO Flight
(flight_id, route_id, plane_id, manager_id, takeoff_date, takeoff_time, flight_status)
VALUES
/* ===================== P0003 (Small) ===================== */
('F1001', 102, 'P0003','203948517','2025-08-05','07:30:00', 'Completed'), -- TLV -> Rome
('F1002', 105, 'P0003','203948517','2025-08-06','12:00:00', 'Completed'), -- Rome -> Paris
('F1003', 106, 'P0003','203948517','2025-09-11','09:00:00', 'Full'), 	  -- Paris -> BER
('F1004', 107, 'P0003','203948517','2025-09-15','10:20:00', 'Completed'), -- BER -> Rome
('F1028', 114, 'P0003','203948517','2025-09-20','08:30:00', 'Completed'), -- Rome -> TLV
/* ===================== P0005 (Small) ===================== */
('F1005', 101, 'P0005','248392176', '2026-02-01','06:50:00', 'Scheduled'), -- TLV -> ATH
('F1006', 104, 'P0005','248392176', '2026-02-03','10:00:00', 'Scheduled'), -- ATH -> Rome (CANCELLED)
('F1007', 104, 'P0005','248392176', '2026-02-22','09:30:00', 'Scheduled'), -- ATH -> Rome
('F1008', 105, 'P0005','248392176', '2026-02-25','08:40:00', 'Scheduled'), -- Rome -> Paris
/* ===================== P0002 (Large) ===================== */
('F1009', 106, 'P0002','281460239', '2025-11-03','09:10:00', 'Completed'), -- Paris -> BER
('F1010', 108, 'P0002','281460239', '2025-11-04','11:45:00', 'Completed'), -- BER -> JFK
('F1011', 109, 'P0002','281460239', '2025-11-07','14:00:00', 'Full'), -- JFK -> DXB
('F1012', 113, 'P0002','281460239', '2025-11-10','09:00:00', 'Completed'),    -- DXB -> Paris
('F1013', 106, 'P0002','281460239', '2025-11-12','07:10:00', 'Completed'), -- Paris -> BER
('F1014', 108, 'P0002','281460239', '2025-11-14','15:20:00', 'Cancelled'), -- BER -> JFK (CANCELLED)
/* ===================== P0004 (Large) ===================== */
('F1015', 102, 'P0004','248392176', '2025-10-02','07:20:00', 'Completed'), -- TLV -> Rome
('F1016', 105, 'P0004','248392176', '2025-10-06','11:45:00', 'Completed'), -- Rome -> Paris
('F1017', 106, 'P0004','281460239', '2025-10-19','09:00:00', 'Full'), -- Paris -> BER
('F1018', 108, 'P0004','281460239', '2025-10-21','12:30:00', 'Completed'), -- BER -> JFK
('F1029', 109, 'P0004','248392176', '2025-10-23','07:50:00', 'Completed'), -- JFK -> DXB
('F1030', 113, 'P0004','248392176', '2025-10-25','16:45:00', 'Completed'), -- DXB -> Paris
/* ===================== P0001 (Large) ===================== */
('F1019', 106, 'P0001','203948517', '2026-03-08','09:10:00', 'Scheduled'), -- Paris -> BER
('F1020', 108, 'P0001','203948517', '2026-03-09','13:00:00', 'Scheduled'), -- BER -> JFK
('F1021', 109, 'P0001','203948517', '2026-03-12','15:20:00', 'Cancelled'), -- JFK -> DXB (CANCELLED)
('F1022', 109, 'P0001','203948517', '2026-03-15','08:50:00', 'Full'), -- JFK -> DXB
/* ===================== P0006 (Large) ===================== */
('F1023', 103, 'P0006','281460239', '2026-01-10','07:00:00', 'Completed'), -- TLV -> DXB
('F1024', 110, 'P0006','281460239', '2026-01-12','22:30:00', 'Completed'), -- DXB -> SYD
('F1025', 111, 'P0006','281460239', '2026-01-14','09:00:00', 'Full'), -- SYD -> AKL
('F1026', 112, 'P0006','281460239', '2026-01-17','11:40:00', 'Completed'),    -- AKL -> DXB
('F1027', 110, 'P0006','281460239', '2026-01-21','22:30:00', 'Completed'), -- DXB -> SYD
('F1031', 111, 'P0006','281460239', '2026-02-05','18:55:00', 'Scheduled'), -- SYD -> AKL
('F1032', 112, 'P0006','281460239', '2026-02-07','09:00:00', 'Scheduled'), -- AKL -> DXB
('F1033', 113, 'P0004','248392176', '2026-02-25','16:45:00', 'Scheduled'); -- DXB -> Paris


/* ===================== Order ===================== */
CREATE TABLE Orders (
  order_id VARCHAR(5) PRIMARY KEY,
  flight_id VARCHAR(5) NOT NULL,
  guest_email VARCHAR(100) NULL,
  reg_customer_email VARCHAR(100) NULL,
  date_of_purchase DATETIME NOT NULL,
  order_status ENUM('Pending','Active','Completed','Cancelled by customer','Cancelled by system') NOT NULL,
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (guest_email) REFERENCES Guest(customer_email),
  FOREIGN KEY (reg_customer_email) REFERENCES Registered_customer(customer_email),
  CONSTRAINT chk_order_one_customer CHECK (
    (guest_email IS NOT NULL AND reg_customer_email IS NULL)
    OR
    (guest_email IS NULL AND reg_customer_email IS NOT NULL)
  )
);


/* ===================== Cabin class ===================== */
CREATE TABLE Cabin_class (
  plane_id VARCHAR(5) NOT NULL,
  class_type ENUM('Business','Economy') NOT NULL,
  columns_num INT NOT NULL,
  rows_num INT NOT NULL,
  PRIMARY KEY (plane_id, class_type),
  FOREIGN KEY (plane_id) REFERENCES Plane(plane_id),
  CONSTRAINT chk_class_dim CHECK (columns_num > 0 AND rows_num > 0)
);

INSERT INTO Cabin_class
(plane_id, class_type, columns_num, rows_num)
VALUES
('P0001','Business',4,8),
('P0001','Economy',6,6),
('P0002','Business',4,5),
('P0002','Economy',6,7),
('P0003','Economy',4,10),
('P0004','Business',4,8),
('P0004','Economy',6,6),
('P0005','Economy',4,9),
('P0006','Business',5,4),
('P0006','Economy',6,8);


/* ===================== Seat ===================== */
CREATE TABLE Seat (
  flight_id VARCHAR(5) NOT NULL,
  s_row INT NOT NULL,
  s_column INT NOT NULL,
  plane_id VARCHAR(5) NOT NULL,
  class_type ENUM('Business','Economy') NOT NULL,
  order_id VARCHAR(5) NULL,
  PRIMARY KEY (flight_id, s_row, s_column),
-- Ensures that every seat belongs to an existing flight
  CONSTRAINT seat_fk_flight
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
-- Prevents assigning seats to invalid or non-existent cabin classes
  CONSTRAINT seat_fk_cabin
    FOREIGN KEY (plane_id, class_type) REFERENCES Cabin_class(plane_id, class_type),
-- A seat may reference an order only if the order exists
-- if an order is deleted, the seat becomes available
-- if an order ID changes, it is updated automatically in Seat
  CONSTRAINT seat_fk_order
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);


INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
WITH RECURSIVE
  cc2 AS (
    SELECT
      cc.plane_id,
      cc.class_type,
      cc.rows_num,
      cc.columns_num,
      1 + COALESCE(
            SUM(cc.rows_num) OVER (
              PARTITION BY cc.plane_id
              ORDER BY CASE cc.class_type WHEN 'Business' THEN 1 ELSE 2 END
              ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
          ) AS start_row
    FROM Cabin_class cc
  ),
  cc3 AS (
    SELECT
      plane_id,
      class_type,
      rows_num,
      columns_num,
      start_row,
      start_row + rows_num - 1 AS end_row
    FROM cc2
  ),
  max_rows AS (
    SELECT MAX(total_rows) AS mx
    FROM (
      SELECT plane_id, SUM(rows_num) AS total_rows
      FROM Cabin_class
      GROUP BY plane_id
    ) t
  ),
  r AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM r
    WHERE n < (SELECT mx FROM max_rows)
  ),
  c AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM c
    WHERE n < (SELECT MAX(columns_num) FROM Cabin_class)
  )
SELECT
  f.flight_id,
  r.n AS s_row,
  c.n AS s_column,
  f.plane_id,
  cc3.class_type,
  NULL AS order_id
FROM Flight f
JOIN cc3
  ON cc3.plane_id = f.plane_id
JOIN r
  ON r.n BETWEEN cc3.start_row AND cc3.end_row
JOIN c
  ON c.n <= cc3.columns_num
WHERE NOT EXISTS (
  SELECT 1
  FROM Seat s
  WHERE s.flight_id = f.flight_id
    AND s.s_row = r.n
    AND s.s_column = c.n
);

/* ===================== F1001 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5001','F1001','adi.weiss@gmail.com',NULL,'2025-07-05','Completed'),
('O5002','F1001','amit.levi@gmail.com',NULL,'2025-06-05','Completed'),
('O5003','F1001','aviv.barkan@gmail.com',NULL,'2025-05-05','Completed'),
('O5004','F1001',NULL,'aviv.doron@gmail.com','2025-04-05','Cancelled by customer'),
('O5005','F1001',NULL,'eran.sela@gmail.com','2025-03-05','Completed');

UPDATE Seat SET order_id = 'O5001'
WHERE flight_id = 'F1001' AND (s_row, s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5002'
WHERE flight_id = 'F1001' AND (s_row, s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5003'
WHERE flight_id = 'F1001' AND (s_row, s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5004'
-- WHERE flight_id = 'F1001' AND (s_row, s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5005'
WHERE flight_id = 'F1001' AND (s_row, s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;

/* ===================== F1002 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5006','F1002','daniel.mizrahi@gmail.com',NULL,'2025-07-01','Completed'),
('O5007','F1002','gal.nadav@gmail.com',NULL,'2025-06-01','Completed'),
('O5008','F1002','itay.rosen@gmail.com',NULL,'2025-05-01','Completed'),
('O5009','F1002',NULL,'idan.mizrahi@gmail.com','2025-05-01','Cancelled by customer'),
('O5010','F1002',NULL,'itamar.regev@gmail.com','2025-03-01','Completed');

UPDATE Seat SET order_id = 'O5006'
WHERE flight_id = 'F1002' AND (s_row, s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5007'
WHERE flight_id = 'F1002' AND (s_row, s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5008'
WHERE flight_id = 'F1002' AND (s_row, s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5009'
-- WHERE flight_id = 'F1002' AND (s_row, s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5010'
WHERE flight_id = 'F1002' AND (s_row, s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;

/* ===================== F1003 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5011','F1003','lina.shahar@gmail.com',NULL,'2025-08-01','Completed'),
('O5012','F1003','LiorB@gmail.com',NULL,'2025-08-02','Completed'),
('O5013','F1003','maya.rubin@gmail.com',NULL,'2025-08-03','Completed'),
('O5014','F1003','neta.halevi@gmail.com',NULL,'2025-08-04','Completed'),
('O5015','F1003','noa.cohen@gmail.com',NULL,'2025-08-05','Completed'),
('O5016','F1003','omer.katz@gmail.com',NULL,'2025-08-06','Completed'),
('O5017','F1003',NULL,'aviv.doron@gmail.com','2025-08-07','Completed'),
('O5018','F1003',NULL,'eran.sela@gmail.com','2025-08-08','Completed'),
('O5019','F1003',NULL,'liat.nadav@gmail.com','2025-08-09','Completed'),
('O5020','F1003',NULL,'omer.klein@gmail.com','2025-08-10','Completed');

UPDATE Seat SET order_id = 'O5011'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5012'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5013'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5014'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5015'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5016'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5017'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5018'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((8,1),(8,2),(8,3),(8,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5019'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((9,1),(9,2),(9,3),(9,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5020'
WHERE flight_id = 'F1003' AND (s_row, s_column) IN ((10,1),(10,2),(10,3),(10,4)) AND order_id IS NULL;

/* ===================== F1004 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5021','F1004','gal.nadav@gmail.com',NULL,'2025-06-01','Completed'),
('O5022','F1004','ron.eldar@gmail.com',NULL,'2025-06-02','Completed'),
('O5023','F1004','yonatan.benami@gmail.com',NULL,'2025-04-03','Completed'),
('O5024','F1004',NULL,'lior.rosen@gmail.com','2025-06-04','Cancelled by customer'),
('O5025','F1004',NULL,'shir.amir@gmail.com','2025-06-05','Completed');

UPDATE Seat SET order_id = 'O5021'
WHERE flight_id = 'F1004' AND (s_row, s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5022'
WHERE flight_id = 'F1004' AND (s_row, s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5023'
WHERE flight_id = 'F1004' AND (s_row, s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5024'
-- WHERE flight_id = 'F1004' AND (s_row, s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5025'
WHERE flight_id = 'F1004' AND (s_row, s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;

/* ===================== F1005 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5026','F1005','ShirP@gmail.com',NULL,'2025-06-10','Active'),
('O5027','F1005','shira.amir@gmail.com',NULL,'2025-06-11','Active'),
('O5028','F1005',NULL,'maya.bitan@gmail.com','2025-06-12','Cancelled by customer'),
('O5029','F1005',NULL,'shani.weiss@gmail.com','2025-06-13','Active');

UPDATE Seat SET order_id = 'O5026'
WHERE flight_id = 'F1005' AND (s_row, s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5027'
WHERE flight_id = 'F1005' AND (s_row, s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5028'
-- WHERE flight_id = 'F1005' AND (s_row, s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5029'
WHERE flight_id = 'F1005' AND (s_row, s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;

/* ===================== F1006 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5030','F1006','tal.friedman@gmail.com',NULL,'2025-04-15','Active'),
('O5031','F1006','sharon.gold@gmail.com',NULL,'2025-04-16','Active'),
('O5032','F1006',NULL,'shaked.peretz@gmail.com','2025-06-17','Active'),
('O5033','F1006',NULL,'yaara.levi@gmail.com','2025-06-18','Active');

UPDATE Seat SET order_id = 'O5030'
WHERE flight_id = 'F1006' AND (s_row, s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5031'
WHERE flight_id = 'F1006' AND (s_row, s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5032'
WHERE flight_id = 'F1006' AND (s_row, s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5033'
WHERE flight_id = 'F1006' AND (s_row, s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;

/* ===================== F1007 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5034','F1007','aviv.barkan@gmail.com',NULL,'2025-06-20','Active'),
('O5035','F1007','shira.amir@gmail.com',NULL,'2025-06-21','Active'),
('O5036','F1007',NULL,'roni.katz@gmail.com','2025-06-22','Active'),
('O5037','F1007',NULL,'maya.oren@gmail.com','2025-06-23','Active');

UPDATE Seat SET order_id = 'O5034'
WHERE flight_id = 'F1007' AND (s_row, s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5035'
WHERE flight_id = 'F1007' AND (s_row, s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5036'
WHERE flight_id = 'F1007' AND (s_row, s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5037'
WHERE flight_id = 'F1007' AND (s_row, s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;

/* ===================== F1008 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5038','F1008','daniel.mizrahi@gmail.com',NULL,'2025-06-25','Completed'),
('O5039','F1008','yael.peretz@gmail.com',NULL,'2025-06-26','Completed'),
('O5040','F1008',NULL,'yonatan.bar@gmail.com','2025-06-27','Cancelled by customer'),
('O5041','F1008',NULL,'aviv.doron@gmail.com','2025-06-28','Completed');

UPDATE Seat SET order_id = 'O5038'
WHERE flight_id = 'F1008' AND (s_row, s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5039'
WHERE flight_id = 'F1008' AND (s_row, s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5040'
-- WHERE flight_id = 'F1008' AND (s_row, s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5041'
WHERE flight_id = 'F1008' AND (s_row, s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;

/* ===================== F1009 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5042','F1009','maya.rubin@gmail.com',NULL,'2025-06-29','Completed'),
('O5043','F1009','tal.friedman@gmail.com',NULL,'2025-06-30','Completed'),
('O5044','F1009','itay.rosen@gmail.com',NULL,'2025-07-01','Completed'),
('O5045','F1009',NULL,'idan.mizrahi@gmail.com','2025-07-02','Completed'),
('O5046','F1009',NULL,'shir.amir@gmail.com','2025-07-03','Completed'),
('O5047','F1009','omer.katz@gmail.com',NULL,'2025-07-04','Completed'),
('O5048','F1009','gal.nadav@gmail.com',NULL,'2025-07-05','Completed'),
('O5049','F1009','neta.halevi@gmail.com',NULL,'2025-07-06','Completed');

UPDATE Seat SET order_id = 'O5042'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5043'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((6,1),(6,2),(6,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5044'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((7,1),(7,2),(7,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5045'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((8,1),(8,2),(8,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5046'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((9,1),(9,2),(9,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5047'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((10,1),(10,2),(10,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5048'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((11,1),(11,2),(11,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5049'
WHERE flight_id = 'F1009' AND (s_row, s_column) IN ((12,1),(12,2),(12,3)) AND order_id IS NULL;

/* ===================== F1010 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5050','F1010','EitanS@gmail.com',NULL,'2025-07-07','Completed'),
('O5051','F1010',NULL,'yossi.dahan@gmail.com','2025-07-08','Completed'),
('O5052','F1010','maya.rubin@gmail.com',NULL,'2025-07-09','Completed'),
('O5053','F1010',NULL,'tamar.gold@gmail.com','2025-07-10','Completed'),
('O5054','F1010','ron.eldar@gmail.com',NULL,'2025-07-11','Completed'),
('O5055','F1010',NULL,'yael.shahar@gmail.com','2025-07-12','Cancelled by customer'),
('O5056','F1010','lina.shahar@gmail.com',NULL,'2025-07-13','Completed'),
('O5057','F1010',NULL,'yonatan.bar@gmail.com','2025-07-14','Cancelled by customer');

UPDATE Seat SET order_id = 'O5050'
WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5051'
WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5052'
WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5053'
WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5054'
WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5055'
-- WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((6,1),(6,2),(6,3)) AND order_id IS NULL;
UPDATE Seat SET order_id = 'O5056'
WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((7,1),(7,2),(7,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id = 'O5057'
-- WHERE flight_id = 'F1010' AND (s_row, s_column) IN ((8,1),(8,2),(8,3)) AND order_id IS NULL;

/* ===================== F1011 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5058','F1011','adi.weiss@gmail.com',NULL,'2025-07-01','Completed'),
('O5059','F1011','ron.eldar@gmail.com',NULL,'2025-07-02','Completed'),
('O5060','F1011',NULL,'shaked.peretz@gmail.com','2025-07-03','Completed'),
('O5061','F1011','noa.cohen@gmail.com',NULL,'2025-07-04','Completed'),
('O5062','F1011',NULL,'maya.oren@gmail.com','2025-07-05','Completed'),
('O5063','F1011','lina.shahar@gmail.com',NULL,'2025-07-06','Completed'),
('O5064','F1011',NULL,'liat.nadav@gmail.com','2025-07-07','Completed'),
('O5065','F1011','sharon.gold@gmail.com',NULL,'2025-07-08','Completed'),
('O5066','F1011',NULL,'shani.weiss@gmail.com','2025-07-09','Completed'),
('O5067','F1011','amit.levi@gmail.com',NULL,'2025-07-10','Completed'),
('O5068','F1011',NULL,'yossi.dahan@gmail.com','2025-07-11','Completed'),
('O5069','F1011','neta.halevi@gmail.com',NULL,'2025-07-12','Completed');

UPDATE Seat SET order_id='O5058'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5059'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5060'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5061'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5062'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5063'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4),(6,5),(6,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5064'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4),(7,5),(7,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5065'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((8,1),(8,2),(8,3),(8,4),(8,5),(8,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5066'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((9,1),(9,2),(9,3),(9,4),(9,5),(9,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5067'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((10,1),(10,2),(10,3),(10,4),(10,5),(10,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5068'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((11,1),(11,2),(11,3),(11,4),(11,5),(11,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5069'
WHERE flight_id='F1011' AND (s_row,s_column) IN ((12,1),(12,2),(12,3),(12,4),(12,5),(12,6)) AND order_id IS NULL;

/* ===================== F1012 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5070','F1012','tal.friedman@gmail.com',NULL,'2025-07-15','Completed'),
('O5071','F1012','yonatan.benami@gmail.com',NULL,'2025-07-16','Completed'),
('O5072','F1012','omer.katz@gmail.com',NULL,'2025-07-17','Completed'),
('O5073','F1012',NULL,'lior.rosen@gmail.com','2025-07-18','Completed'),
('O5074','F1012','sharon.gold@gmail.com',NULL,'2025-07-19','Completed'),
('O5075','F1012',NULL,'itamar.regev@gmail.com','2025-07-20','Cancelled by customer'),
('O5076','F1012','gal.nadav@gmail.com',NULL,'2025-07-21','Completed'),
('O5077','F1012',NULL,'yael.shahar@gmail.com','2025-07-22','Completed');

UPDATE Seat SET order_id='O5070'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5071'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5072'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5073'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5074'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5075'
-- WHERE flight_id='F1012' AND (s_row,s_column) IN ((6,1),(6,2),(6,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5076'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((7,1),(7,2),(7,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5077'
WHERE flight_id='F1012' AND (s_row,s_column) IN ((8,1),(8,2),(8,3)) AND order_id IS NULL;

/* ===================== F1013 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5078','F1013','adi.weiss@gmail.com',NULL,'2025-07-23','Completed'),
('O5079','F1013','amit.levi@gmail.com',NULL,'2025-07-24','Completed'),
('O5080','F1013','aviv.barkan@gmail.com',NULL,'2025-07-25','Completed'),
('O5081','F1013',NULL,'idan.mizrahi@gmail.com','2025-07-26','Completed'),
('O5082','F1013','maya.rubin@gmail.com',NULL,'2025-07-27','Completed'),
('O5083','F1013',NULL,'itamar.regev@gmail.com','2025-07-28','Completed'),
('O5084','F1013','omer.katz@gmail.com',NULL,'2025-07-29','Completed'),
('O5085','F1013',NULL,'tamar.gold@gmail.com','2025-07-30','Completed');

UPDATE Seat SET order_id='O5078'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5079'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5080'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5081'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5082'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5083'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((6,1),(6,2),(6,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5084'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((7,1),(7,2),(7,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5085'
WHERE flight_id='F1013' AND (s_row,s_column) IN ((8,1),(8,2),(8,3)) AND order_id IS NULL;

/* ===================== F1014 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5086','F1014','tal.friedman@gmail.com',NULL,'2025-07-20','Cancelled by system'),
('O5087','F1014','yonatan.benami@gmail.com',NULL,'2025-07-21','Cancelled by system'),
('O5088','F1014',NULL,'idan.mizrahi@gmail.com','2025-07-22','Cancelled by system'),
('O5089','F1014','sharon.gold@gmail.com',NULL,'2025-07-23','Cancelled by system'),
('O5090','F1014',NULL,'roni.katz@gmail.com','2025-07-24','Cancelled by system');

-- UPDATE Seat SET order_id='O5086'
-- WHERE flight_id='F1014' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5087'
-- WHERE flight_id='F1014' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5088'
-- WHERE flight_id='F1014' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5089'
-- WHERE flight_id='F1014' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5090'
-- WHERE flight_id='F1014' AND (s_row,s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;

/* ===================== F1015 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5091','F1015','adi.weiss@gmail.com',NULL,'2025-07-01','Completed'),
('O5092','F1015','amit.levi@gmail.com',NULL,'2025-07-02','Completed'),
('O5093','F1015',NULL,'idan.mizrahi@gmail.com','2025-07-03','Completed'),
('O5094','F1015','LiorB@gmail.com',NULL,'2025-07-04','Completed'),
('O5095','F1015',NULL,'itamar.regev@gmail.com','2025-07-05','Cancelled by customer'),
('O5096','F1015','ron.eldar@gmail.com',NULL,'2025-07-06','Completed'),
('O5097','F1015',NULL,'roni.katz@gmail.com','2025-07-07','Cancelled by customer'),
('O5098','F1015','yonatan.benami@gmail.com',NULL,'2025-07-08','Completed');

UPDATE Seat SET order_id='O5091'
WHERE flight_id='F1015' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5092'
WHERE flight_id='F1015' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5093'
WHERE flight_id='F1015' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5094'
WHERE flight_id='F1015' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5095'
-- WHERE flight_id='F1015' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5096'
WHERE flight_id='F1015' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5097'
-- WHERE flight_id='F1015' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5098'
WHERE flight_id='F1015' AND (s_row,s_column) IN ((8,1),(8,2),(8,3),(8,4)) AND order_id IS NULL;

/* ===================== F1016 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5099','F1016','daniel.mizrahi@gmail.com',NULL,'2025-07-09','Completed'),
('O5100','F1016','EitanS@gmail.com',NULL,'2025-07-10','Completed'),
('O5101','F1016',NULL,'yael.shahar@gmail.com','2025-07-11','Completed'),
('O5102','F1016','tal.friedman@gmail.com',NULL,'2025-07-12','Completed'),
('O5103','F1016',NULL,'idan.mizrahi@gmail.com','2025-07-13','Completed'),
('O5104','F1016','ShirP@gmail.com',NULL,'2025-07-14','Completed'),
('O5105','F1016',NULL,'itamar.regev@gmail.com','2025-07-15','Completed'),
('O5106','F1016','ron.eldar@gmail.com',NULL,'2025-07-16','Completed');

UPDATE Seat SET order_id='O5099'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5100'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5101'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5102'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5103'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5104'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5105'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5106'
WHERE flight_id='F1016' AND (s_row,s_column) IN ((8,1),(8,2),(8,3),(8,4)) AND order_id IS NULL;

/* ===================== F1017 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5107','F1017','ron.eldar@gmail.com',NULL,'2025-07-01','Completed'),
('O5108','F1017','yael.peretz@gmail.com',NULL,'2025-07-02','Completed'),
('O5109','F1017',NULL,'eran.sela@gmail.com','2025-07-03','Completed'),
('O5110','F1017','sharon.gold@gmail.com',NULL,'2025-07-04','Completed'),
('O5111','F1017',NULL,'omer.klein@gmail.com','2025-07-05','Completed'),
('O5112','F1017','gal.nadav@gmail.com',NULL,'2025-07-06','Completed'),
('O5113','F1017',NULL,'itamar.regev@gmail.com','2025-07-07','Completed'),
('O5114','F1017','lina.shahar@gmail.com',NULL,'2025-07-08','Completed'),
('O5115','F1017','adi.weiss@gmail.com',NULL,'2025-07-09','Completed'),
('O5116','F1017',NULL,'idan.mizrahi@gmail.com','2025-07-10','Completed'),
('O5117','F1017','maya.rubin@gmail.com',NULL,'2025-07-11','Completed'),
('O5118','F1017',NULL,'yonatan.bar@gmail.com','2025-07-12','Completed'),
('O5119','F1017','tal.friedman@gmail.com',NULL,'2025-07-13','Completed'),
('O5120','F1017','yonatan.benami@gmail.com',NULL,'2025-07-14','Completed');

UPDATE Seat SET order_id='O5107'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5108'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5109'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5110'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5111'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5112'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5113'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5114'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((8,1),(8,2),(8,3),(8,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5115'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((9,1),(9,2),(9,3),(9,4),(9,5),(9,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5116'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((10,1),(10,2),(10,3),(10,4),(10,5),(10,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5117'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((11,1),(11,2),(11,3),(11,4),(11,5),(11,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5118'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((12,1),(12,2),(12,3),(12,4),(12,5),(12,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5119'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((13,1),(13,2),(13,3),(13,4),(13,5),(13,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5120'
WHERE flight_id='F1017' AND (s_row,s_column) IN ((14,1),(14,2),(14,3),(14,4),(14,5),(14,6)) AND order_id IS NULL;

/* ===================== F1018 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5121','F1018','tal.friedman@gmail.com',NULL,'2025-07-15','Completed'),
('O5122','F1018','yael.peretz@gmail.com',NULL,'2025-07-16','Completed'),
('O5123','F1018',NULL,'eran.sela@gmail.com','2025-07-17','Completed'),
('O5124','F1018','itay.rosen@gmail.com',NULL,'2025-07-18','Completed'),
('O5125','F1018',NULL,'omer.klein@gmail.com','2025-07-19','Completed'),
('O5126','F1018','ShirP@gmail.com',NULL,'2025-07-20','Completed'),
('O5127','F1018',NULL,'yonatan.bar@gmail.com','2025-07-21','Completed');

UPDATE Seat SET order_id='O5121'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5122'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5123'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5124'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5125'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5126'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5127'
WHERE flight_id='F1018' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;

/* ===================== F1019 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5128','F1019','itay.rosen@gmail.com',NULL,'2025-07-22','Active'),
('O5129','F1019','LiorB@gmail.com',NULL,'2025-07-23','Active'),
('O5130','F1019',NULL,'omer.klein@gmail.com','2025-07-24','Active'),
('O5131','F1019',NULL,'shani.weiss@gmail.com','2025-07-25','Active'),
('O5132','F1019',NULL,'niv.hazan@gmail.com','2025-07-26','Cancelled by customer'),
('O5133','F1019','gal.nadav@gmail.com',NULL,'2025-07-27','Active'),
('O5134','F1019',NULL,'yael.shahar@gmail.com','2025-07-28','Active');

UPDATE Seat SET order_id='O5128'
WHERE flight_id='F1019' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5129'
WHERE flight_id='F1019' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5130'
WHERE flight_id='F1019' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5131'
WHERE flight_id='F1019' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5132'
-- WHERE flight_id='F1019' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5133'
WHERE flight_id='F1019' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5134'
WHERE flight_id='F1019' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;

/* ===================== F1020 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5135','F1020','adi.weiss@gmail.com',NULL,'2025-07-29','Active'),
('O5136','F1020','omer.katz@gmail.com',NULL,'2025-07-30','Active'),
('O5137','F1020',NULL,'yossi.dahan@gmail.com','2025-07-31','Active'),
('O5138','F1020','shira.amir@gmail.com',NULL,'2025-08-01','Active'),
('O5139','F1020',NULL,'eran.sela@gmail.com','2025-08-02','Active'),
('O5140','F1020',NULL,'maya.oren@gmail.com','2025-08-03','Active'),
('O5141','F1020',NULL,'liat.nadav@gmail.com','2025-08-04','Active');

UPDATE Seat SET order_id='O5135'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5136'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5137'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5138'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5139'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5140'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5141'
WHERE flight_id='F1020' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;

/* ===================== F1021 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5142','F1021','tal.friedman@gmail.com',NULL,'2025-08-05','Cancelled by system'),
('O5143','F1021','neta.halevi@gmail.com',NULL,'2025-08-06','Cancelled by system'),
('O5144','F1021',NULL,'yossi.dahan@gmail.com','2025-08-07','Cancelled by system'),
('O5145','F1021','aviv.barkan@gmail.com',NULL,'2025-08-08','Cancelled by system'),
('O5146','F1021',NULL,'eran.sela@gmail.com','2025-08-09','Cancelled by system');

-- UPDATE Seat SET order_id='O5142'
-- WHERE flight_id='F1021' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5143'
-- WHERE flight_id='F1021' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5144'
-- WHERE flight_id='F1021' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5145'
-- WHERE flight_id='F1021' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5146'
-- WHERE flight_id='F1021' AND (s_row,s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;

/* ===================== F1022 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5147','F1022',NULL,'omer.klein@gmail.com','2025-08-01','Completed'),
('O5148','F1022','tal.friedman@gmail.com',NULL,'2025-08-02','Completed'),
('O5149','F1022',NULL,'itamar.regev@gmail.com','2025-08-03','Completed'),
('O5150','F1022','noa.cohen@gmail.com',NULL,'2025-08-04','Completed'),
('O5151','F1022',NULL,'idan.mizrahi@gmail.com','2025-08-05','Completed'),
('O5152','F1022','adi.weiss@gmail.com',NULL,'2025-08-06','Completed'),
('O5153','F1022',NULL,'eran.sela@gmail.com','2025-08-07','Completed'),
('O5154','F1022','ron.eldar@gmail.com',NULL,'2025-08-08','Completed'),
('O5155','F1022','yonatan.benami@gmail.com',NULL,'2025-08-09','Completed'),
('O5156','F1022',NULL,'yossi.dahan@gmail.com','2025-08-10','Completed'),
('O5157','F1022','maya.rubin@gmail.com',NULL,'2025-08-11','Completed'),
('O5158','F1022',NULL,'niv.hazan@gmail.com','2025-08-12','Completed'),
('O5159','F1022','yael.peretz@gmail.com',NULL,'2025-08-13','Completed'),
('O5160','F1022',NULL,'aviv.doron@gmail.com','2025-08-14','Completed');

UPDATE Seat SET order_id='O5147'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5148'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5149'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5150'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5151'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5152'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5153'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5154'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((8,1),(8,2),(8,3),(8,4)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5155'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((9,1),(9,2),(9,3),(9,4),(9,5),(9,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5156'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((10,1),(10,2),(10,3),(10,4),(10,5),(10,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5157'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((11,1),(11,2),(11,3),(11,4),(11,5),(11,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5158'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((12,1),(12,2),(12,3),(12,4),(12,5),(12,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5159'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((13,1),(13,2),(13,3),(13,4),(13,5),(13,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5160'
WHERE flight_id='F1022' AND (s_row,s_column) IN ((14,1),(14,2),(14,3),(14,4),(14,5),(14,6)) AND order_id IS NULL;

/* ===================== F1023 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5161','F1023','daniel.mizrahi@gmail.com',NULL,'2025-08-15','Completed'),
('O5162','F1023','shira.amir@gmail.com',NULL,'2025-08-16','Completed'),
('O5163','F1023',NULL,'shaked.peretz@gmail.com','2025-08-17','Completed'),
('O5164','F1023',NULL,'itamar.regev@gmail.com','2025-08-18','Completed');

UPDATE Seat SET order_id='O5161'
WHERE flight_id='F1023' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5162'
WHERE flight_id='F1023' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5163'
WHERE flight_id='F1023' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5164'
WHERE flight_id='F1023' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1024 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5165','F1024','LiorB@gmail.com',NULL,'2025-08-19','Completed'),
('O5166','F1024','noa.cohen@gmail.com',NULL,'2025-08-20','Completed'),
('O5167','F1024',NULL,'yaara.levi@gmail.com','2025-08-21','Cancelled by customer'),
('O5168','F1024',NULL,'yael.shahar@gmail.com','2025-08-22','Completed');

UPDATE Seat SET order_id='O5165'
WHERE flight_id='F1024' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5166'
WHERE flight_id='F1024' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5167'
-- WHERE flight_id='F1024' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5168'
WHERE flight_id='F1024' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1025 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5169','F1025','LiorB@gmail.com',NULL,'2025-08-23','Completed'),
('O5170','F1025','yael.peretz@gmail.com',NULL,'2025-08-24','Completed'),
('O5171','F1025',NULL,'noam.cohen@gmail.com','2025-08-25','Completed'),
('O5172','F1025','noa.cohen@gmail.com',NULL,'2025-08-26','Completed'),
('O5173','F1025',NULL,'shani.weiss@gmail.com','2025-08-27','Completed'),
('O5174','F1025','gal.nadav@gmail.com',NULL,'2025-08-28','Completed'),
('O5175','F1025',NULL,'roni.katz@gmail.com','2025-08-29','Completed'),
('O5176','F1025','amit.levi@gmail.com',NULL,'2025-08-30','Completed'),
('O5177','F1025','ron.eldar@gmail.com',NULL,'2025-08-31','Completed'),
('O5178','F1025',NULL,'yonatan.bar@gmail.com','2025-09-01','Completed'),
('O5179','F1025','shira.amir@gmail.com',NULL,'2025-09-02','Completed'),
('O5180','F1025',NULL,'liat.nadav@gmail.com','2025-09-03','Completed'),
('O5181','F1025','tal.friedman@gmail.com',NULL,'2025-09-04','Completed'),
('O5182','F1025',NULL,'yossi.dahan@gmail.com','2025-09-05','Completed');

UPDATE Seat SET order_id='O5169'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((1,1),(1,2),(1,3),(1,4),(1,5)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5170'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((2,1),(2,2),(2,3),(2,4),(2,5)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5171'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((3,1),(3,2),(3,3),(3,4),(3,5)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5172'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((4,1),(4,2),(4,3),(4,4),(4,5)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5173'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((5,1),(5,2),(5,3),(5,4),(5,5),(5,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5174'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((6,1),(6,2),(6,3),(6,4),(6,5),(6,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5175'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((7,1),(7,2),(7,3),(7,4),(7,5),(7,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5176'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((8,1),(8,2),(8,3),(8,4),(8,5),(8,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5177'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((9,1),(9,2),(9,3),(9,4),(9,5),(9,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5178'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((10,1),(10,2),(10,3),(10,4),(10,5),(10,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5179'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((11,1),(11,2),(11,3),(11,4),(11,5),(11,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5180'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((12,1),(12,2),(12,3),(12,4),(12,5),(12,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5181'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((13,1),(13,2),(13,3),(13,4),(13,5),(13,6)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5182'
WHERE flight_id='F1025' AND (s_row,s_column) IN ((14,1),(14,2),(14,3),(14,4),(14,5),(14,6)) AND order_id IS NULL;

/* ===================== F1026 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5183','F1026','omer.katz@gmail.com',NULL,'2025-09-06','Completed'),
('O5184','F1026',NULL,'eran.sela@gmail.com','2025-09-07','Completed'),
('O5185','F1026',NULL,'shir.amir@gmail.com','2025-09-08','Completed'),
('O5186','F1026','noa.cohen@gmail.com',NULL,'2025-09-09','Completed'),
('O5187','F1026',NULL,'maya.bitan@gmail.com','2025-09-10','Completed'),
('O5188','F1026','aviv.barkan@gmail.com',NULL,'2025-09-11','Completed'),
('O5189','F1026',NULL,'yossi.dahan@gmail.com','2025-09-12','Completed');

UPDATE Seat SET order_id='O5183'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5184'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5185'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5186'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5187'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5188'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((6,1),(6,2),(6,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5189'
WHERE flight_id='F1026' AND (s_row,s_column) IN ((7,1),(7,2),(7,3)) AND order_id IS NULL;

/* ===================== F1027 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5190','F1027','sharon.gold@gmail.com',NULL,'2025-09-13','Completed'),
('O5191','F1027','ron.eldar@gmail.com',NULL,'2025-09-14','Completed'),
('O5192','F1027',NULL,'yossi.dahan@gmail.com','2025-09-15','Completed'),
('O5193','F1027','shira.amir@gmail.com',NULL,'2025-09-16','Completed'),
('O5194','F1027',NULL,'maya.oren@gmail.com','2025-09-17','Completed'),
('O5195','F1027','EitanS@gmail.com',NULL,'2025-09-18','Completed'),
('O5196','F1027',NULL,'liat.nadav@gmail.com','2025-09-19','Completed');

UPDATE Seat SET order_id='O5190'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5191'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5192'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5193'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5194'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((5,1),(5,2),(5,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5195'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((6,1),(6,2),(6,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5196'
WHERE flight_id='F1027' AND (s_row,s_column) IN ((7,1),(7,2),(7,3)) AND order_id IS NULL;

/* ===================== F1028 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5197','F1028','daniel.mizrahi@gmail.com',NULL,'2025-09-20','Completed'),
('O5198','F1028','yael.peretz@gmail.com',NULL,'2025-09-21','Completed'),
('O5199','F1028',NULL,'lior.rosen@gmail.com','2025-09-22','Completed'),
('O5200','F1028',NULL,'shani.weiss@gmail.com','2025-09-23','Completed');

UPDATE Seat SET order_id='O5197'
WHERE flight_id='F1028' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5198'
WHERE flight_id='F1028' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5199'
WHERE flight_id='F1028' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5200'
WHERE flight_id='F1028' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1029 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5201','F1029','aviv.barkan@gmail.com',NULL,'2025-09-24','Completed'),
('O5202','F1029','ShirP@gmail.com',NULL,'2025-09-25','Completed'),
('O5203','F1029',NULL,'itamar.regev@gmail.com','2025-09-26','Completed'),
('O5204','F1029',NULL,'shani.weiss@gmail.com','2025-09-27','Completed');

UPDATE Seat SET order_id='O5201'
WHERE flight_id='F1029' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5202'
WHERE flight_id='F1029' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5203'
WHERE flight_id='F1029' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5204'
WHERE flight_id='F1029' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1030 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5205','F1030','adi.weiss@gmail.com',NULL,'2025-09-28','Completed'),
('O5206','F1030','yael.peretz@gmail.com',NULL,'2025-09-29','Completed'),
('O5207','F1030',NULL,'niv.hazan@gmail.com','2025-09-30','Completed'),
('O5208','F1030',NULL,'shir.amir@gmail.com','2025-10-01','Cancelled by customer');

UPDATE Seat SET order_id='O5205'
WHERE flight_id='F1030' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5206'
WHERE flight_id='F1030' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5207'
WHERE flight_id='F1030' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
-- UPDATE Seat SET order_id='O5208'
-- WHERE flight_id='F1030' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1031 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5209','F1031',NULL,'niv.hazan@gmail.com','2025-10-02','Active'),
('O5210','F1031','neta.halevi@gmail.com',NULL,'2025-10-03','Active'),
('O5211','F1031',NULL,'idan.mizrahi@gmail.com','2025-10-04','Active'),
('O5212','F1031',NULL,'yossi.dahan@gmail.com','2025-10-05','Active');

UPDATE Seat SET order_id='O5209'
WHERE flight_id='F1031' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5210'
WHERE flight_id='F1031' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5211'
WHERE flight_id='F1031' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5212'
WHERE flight_id='F1031' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1032 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5213','F1032','daniel.mizrahi@gmail.com',NULL,'2025-10-06','Active'),
('O5214','F1032','itay.rosen@gmail.com',NULL,'2025-10-07','Active'),
('O5215','F1032',NULL,'maya.oren@gmail.com','2025-10-08','Active'),
('O5216','F1032',NULL,'yael.shahar@gmail.com','2025-10-09','Active');

UPDATE Seat SET order_id='O5213'
WHERE flight_id='F1032' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5214'
WHERE flight_id='F1032' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5215'
WHERE flight_id='F1032' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5216'
WHERE flight_id='F1032' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;

/* ===================== F1033 ===================== */
INSERT INTO Orders (order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('O5217','F1033','LiorB@gmail.com',NULL,'2025-10-10','Active'),
('O5218','F1033','yonatan.benami@gmail.com',NULL,'2025-10-11','Active'),
('O5219','F1033',NULL,'itamar.regev@gmail.com','2025-10-12','Active'),
('O5220','F1033',NULL,'shani.weiss@gmail.com','2025-10-13','Active');

UPDATE Seat SET order_id='O5217'
WHERE flight_id='F1033' AND (s_row,s_column) IN ((1,1),(1,2),(1,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5218'
WHERE flight_id='F1033' AND (s_row,s_column) IN ((2,1),(2,2),(2,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5219'
WHERE flight_id='F1033' AND (s_row,s_column) IN ((3,1),(3,2),(3,3)) AND order_id IS NULL;
UPDATE Seat SET order_id='O5220'
WHERE flight_id='F1033' AND (s_row,s_column) IN ((4,1),(4,2),(4,3)) AND order_id IS NULL;


/* ===================== Flight Class Pricing ===================== */
CREATE TABLE Flight_Class_Pricing (
  flight_id   VARCHAR(5) NOT NULL,
  plane_id    VARCHAR(5) NOT NULL,
  class_type  ENUM('Business','Economy') NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (flight_id, plane_id, class_type),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (plane_id, class_type) REFERENCES Cabin_class(plane_id, class_type),
  CONSTRAINT chk_flight_class_price CHECK (price > 0)
);

INSERT INTO Flight_Class_Pricing
(flight_id, plane_id, class_type, price)
VALUES
/* ===================== P0003 (Small) ===================== */
('F1001', 'P0003', 'Economy', 450),
('F1002', 'P0003', 'Economy', 520),
('F1003', 'P0003', 'Economy', 480),
('F1004', 'P0003', 'Economy', 500),
('F1028', 'P0003', 'Economy', 520),
/* ===================== P0005 (Small) ===================== */
('F1005', 'P0005', 'Economy', 400),
('F1006', 'P0005', 'Economy', 420),
('F1007', 'P0005', 'Economy', 430),
('F1008', 'P0005', 'Economy', 510),
/* ===================== P0002 (Large) ===================== */
('F1009', 'P0002', 'Economy', 480),
('F1009', 'P0002', 'Business', 1200),
('F1010', 'P0002', 'Economy', 950),
('F1010', 'P0002', 'Business', 2200),
('F1011', 'P0002', 'Economy', 1100),
('F1011', 'P0002', 'Business', 2600),
('F1012', 'P0002', 'Economy', 600),
('F1012', 'P0002', 'Business', 1400),
('F1013', 'P0002', 'Economy', 500),
('F1013', 'P0002', 'Business', 1250),
('F1014', 'P0002', 'Economy', 980),
('F1014', 'P0002', 'Business', 2300),
/* ===================== P0004 (Large) ===================== */
('F1015', 'P0004', 'Economy', 460),
('F1015', 'P0004', 'Business', 1150),
('F1016', 'P0004', 'Economy', 520),
('F1016', 'P0004', 'Business', 1350),
('F1017', 'P0004', 'Economy', 500),
('F1017', 'P0004', 'Business', 1250),
('F1018', 'P0004', 'Economy', 990),
('F1018', 'P0004', 'Business', 2400),
('F1029', 'P0004', 'Economy', 1150),
('F1029', 'P0004', 'Business', 2700),
('F1033', 'P0004', 'Economy', 1000),
('F1033', 'P0004', 'Business', 2450),
/* ===================== P0001 (Large) ===================== */
('F1019', 'P0001', 'Economy', 520),
('F1019', 'P0001', 'Business', 1300),
('F1020', 'P0001', 'Economy', 980),
('F1020', 'P0001', 'Business', 2300),
('F1021', 'P0001', 'Economy', 1050),
('F1021', 'P0001', 'Business', 2500),
('F1022', 'P0001', 'Economy', 1100),
('F1022', 'P0001', 'Business', 2700),
/* ===================== P0006 (Large) ===================== */
('F1023', 'P0006', 'Economy', 600),
('F1023', 'P0006', 'Business', 1500),
('F1024', 'P0006', 'Economy', 1200),
('F1024', 'P0006', 'Business', 2900),
('F1025', 'P0006', 'Economy', 700),
('F1025', 'P0006', 'Business', 1800),
('F1026', 'P0006', 'Economy', 1000),
('F1026', 'P0006', 'Business', 2400),
('F1027', 'P0006', 'Economy', 1250),
('F1027', 'P0006', 'Business', 3000),
('F1031', 'P0006', 'Economy', 700),
('F1031', 'P0006', 'Business', 1750),
('F1032', 'P0006', 'Economy', 1250),
('F1032', 'P0006', 'Business', 3000);


/* ===================== Pilots in flights ===================== */
CREATE TABLE Pilots_in_flights (
  flight_id VARCHAR(5) NOT NULL,
  employee_id VARCHAR(9) NOT NULL,
  PRIMARY KEY (flight_id, employee_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (employee_id) REFERENCES Pilot(employee_id)
);

INSERT INTO Pilots_in_flights (flight_id, employee_id)
VALUES
/* ===================== P0003 (Small) ===================== */
('F1001', '172604895'), ('F1001', '893417256'),
('F1002', '172604895'), ('F1002', '893417256'),
('F1003', '172604895'), ('F1003', '893417256'),
('F1004', '172604895'), ('F1004', '893417256'),
/* ===================== P0005 (Small) ===================== */
('F1005', '172604895'), ('F1005', '893417256'),
('F1006', '172604895'), ('F1006', '893417256'),
('F1007', '172604895'), ('F1007', '893417256'),
('F1008', '172604895'), ('F1008', '893417256'),
/* ===================== P0002 (Large) ===================== */
('F1009', '459318260'), ('F1009', '531794628'), ('F1009', '648205173'),
('F1010', '459318260'), ('F1010', '531794628'), ('F1010', '648205173'),
('F1011', '459318260'), ('F1011', '531794628'), ('F1011', '648205173'),
('F1012', '459318260'), ('F1012', '531794628'), ('F1012', '648205173'),
('F1013', '459318260'), ('F1013', '531794628'), ('F1013', '648205173'),
('F1014', '459318260'), ('F1014', '531794628'), ('F1014', '648205173'),
/* ===================== P0004 (Large) ===================== */
('F1015', '459318260'), ('F1015', '531794628'), ('F1015', '648205173'),
('F1016', '459318260'), ('F1016', '531794628'), ('F1016', '648205173'),
('F1017', '459318260'), ('F1017', '531794628'), ('F1017', '648205173'),
('F1018', '459318260'), ('F1018', '531794628'), ('F1018', '648205173'),
/* ===================== P0001 (Large) ===================== */
('F1019', '704963581'), ('F1019', '214963587'), ('F1019', '287451936'),
('F1020', '704963581'), ('F1020', '214963587'), ('F1020', '287451936'),
('F1021', '704963581'), ('F1021', '214963587'), ('F1021', '287451936'),
('F1022', '704963581'), ('F1022', '214963587'), ('F1022', '287451936'),
/* ===================== P0006 (Large) ===================== */
('F1023', '704963581'), ('F1023', '214963587'), ('F1023', '287451936'),
('F1024', '704963581'), ('F1024', '214963587'), ('F1024', '287451936'),
('F1025', '704963581'), ('F1025', '214963587'), ('F1025', '287451936'),
('F1026', '704963581'), ('F1026', '214963587'), ('F1026', '287451936'),
('F1027', '704963581'), ('F1027', '214963587'), ('F1027', '287451936');

INSERT INTO Pilots_in_flights (flight_id, employee_id)
VALUES
/* ===================== P0003 (Small) ===================== */
('F1028', '172604895'), ('F1028', '893417256'),
/* ===================== P0004 (Large) ===================== */
('F1029', '459318260'), ('F1029', '531794628'), ('F1029', '648205173'),
('F1030', '459318260'), ('F1030', '531794628'), ('F1030', '648205173'),
/* ===================== P0006 (Large) ===================== */
('F1031', '704963581'), ('F1031', '214963587'), ('F1031', '287451936'),
('F1032', '704963581'), ('F1032', '214963587'), ('F1032', '287451936'),
('F1033', '704963581'), ('F1033', '214963587'), ('F1033', '287451936');


/* ===================== Flight attendants in flights  ===================== */
CREATE TABLE Flight_attendants_in_flights (
  flight_id VARCHAR(5) NOT NULL,
  employee_id VARCHAR(9) NOT NULL,
  PRIMARY KEY (flight_id, employee_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (employee_id) REFERENCES Flight_attendant(employee_id)
);

INSERT INTO Flight_attendants_in_flights (flight_id, employee_id)
VALUES
/* ===================== P0003 (Small) ===================== */
('F1001', '236598174'), ('F1001', '264805731'),('F1001', '275906314'),
('F1002', '236598174'), ('F1002', '264805731'),('F1002', '275906314'),
('F1003', '236598174'), ('F1003', '264805731'),('F1003', '275906314'),
('F1004', '236598174'), ('F1004', '264805731'),('F1004', '275906314'),
/* ===================== P0005 (Small) ===================== */
('F1005', '236598174'), ('F1005', '264805731'),('F1005', '275906314'),
('F1006', '236598174'), ('F1006', '264805731'),('F1006', '275906314'),
('F1007', '236598174'), ('F1007', '264805731'),('F1007', '275906314'),
('F1008', '236598174'), ('F1008', '264805731'),('F1008', '275906314'),
/* ===================== P0002 (Large) ===================== */
('F1009', '143829506'), ('F1009', '158374926'), ('F1009', '368541972'),('F1009', '379162458'), ('F1009', '467120958'), ('F1009', '582013469'),
('F1010', '143829506'), ('F1010', '158374926'), ('F1010', '368541972'),('F1010', '379162458'), ('F1010', '467120958'), ('F1010', '582013469'),
('F1011', '143829506'), ('F1011', '158374926'), ('F1011', '368541972'),('F1011', '379162458'), ('F1011', '467120958'), ('F1011', '582013469'),
('F1012', '143829506'), ('F1012', '158374926'), ('F1012', '368541972'),('F1012', '379162458'), ('F1012', '467120958'), ('F1012', '582013469'),
('F1013', '143829506'), ('F1013', '158374926'), ('F1013', '368541972'),('F1013', '379162458'), ('F1013', '467120958'), ('F1013', '582013469'),
('F1014', '143829506'), ('F1014', '158374926'), ('F1014', '368541972'),('F1014', '379162458'), ('F1014', '467120958'), ('F1014', '582013469'),
/* ===================== P0004 (Large) ===================== */
('F1015', '143829506'), ('F1015', '158374926'), ('F1015', '368541972'),('F1015', '379162458'), ('F1015', '467120958'), ('F1015', '582013469'),
('F1016', '143829506'), ('F1016', '158374926'), ('F1016', '368541972'),('F1016', '379162458'), ('F1016', '467120958'), ('F1016', '582013469'),
('F1017', '143829506'), ('F1017', '158374926'), ('F1017', '368541972'),('F1017', '379162458'), ('F1017', '467120958'), ('F1017', '582013469'),
('F1018', '143829506'), ('F1018', '158374926'), ('F1018', '368541972'),('F1018', '379162458'), ('F1018', '467120958'), ('F1018', '582013469'),
/* ===================== P0001 (Large) ===================== */
('F1019', '590346817'), ('F1019', '618259704'), ('F1019', '697428351'),('F1019', '742816593'), ('F1019', '906215743'), ('F1019', '914627385'),
('F1020', '590346817'), ('F1020', '618259704'), ('F1020', '697428351'),('F1020', '742816593'), ('F1020', '906215743'), ('F1020', '914627385'),
('F1021', '590346817'), ('F1021', '618259704'), ('F1021', '697428351'),('F1021', '742816593'), ('F1021', '906215743'), ('F1021', '914627385'),
('F1022', '590346817'), ('F1022', '618259704'), ('F1022', '697428351'),('F1022', '742816593'), ('F1022', '906215743'), ('F1022', '914627385'),
/* ===================== P0006 (Large) ===================== */
('F1023', '590346817'), ('F1023', '618259704'), ('F1023', '697428351'),('F1023', '742816593'), ('F1023', '906215743'), ('F1023', '914627385'),
('F1024', '590346817'), ('F1024', '618259704'), ('F1024', '697428351'),('F1024', '742816593'), ('F1024', '906215743'), ('F1024', '914627385'),
('F1025', '590346817'), ('F1025', '618259704'), ('F1025', '697428351'),('F1025', '742816593'), ('F1025', '906215743'), ('F1025', '914627385'),
('F1026', '590346817'), ('F1026', '618259704'), ('F1026', '697428351'),('F1026', '742816593'), ('F1026', '906215743'), ('F1026', '914627385'),
('F1027', '590346817'), ('F1027', '618259704'), ('F1027', '697428351'),('F1027', '742816593'), ('F1027', '906215743'), ('F1027', '914627385');

INSERT INTO Flight_attendants_in_flights (flight_id, employee_id)
VALUES
/* ===================== P0003 (Small) ===================== */
('F1028', '236598174'), ('F1028', '264805731'),('F1028', '275906314'),
/* ===================== P0004 (Large) ===================== */
('F1029', '143829506'), ('F1029', '158374926'), ('F1029', '368541972'),('F1029', '379162458'), ('F1029', '467120958'), ('F1029', '582013469'),
('F1030', '143829506'), ('F1030', '158374926'), ('F1030', '368541972'),('F1030', '379162458'), ('F1030', '467120958'), ('F1030', '582013469'),
/* ===================== P0006 (Large) ===================== */
('F1031', '590346817'), ('F1031', '618259704'), ('F1031', '697428351'),('F1031', '742816593'), ('F1031', '906215743'), ('F1031', '914627385'),
('F1032', '590346817'), ('F1032', '618259704'), ('F1032', '697428351'),('F1032', '742816593'), ('F1032', '906215743'), ('F1032', '914627385'),
('F1033', '590346817'), ('F1033', '618259704'), ('F1033', '697428351'),('F1033', '742816593'), ('F1033', '906215743'), ('F1033', '914627385');


/* ================================= Query 1 ================================== */
SELECT ROUND(AVG(seat_occupancy_pct), 2) AS avg_seat_occupancy_pct
FROM (
  SELECT f.flight_id,
         100 * AVG(o.order_id IS NOT NULL
                   AND o.order_status NOT IN ('Cancelled by system','Cancelled by customer'))
           AS seat_occupancy_pct
  FROM Flight f
  JOIN Seat s ON s.flight_id = f.flight_id
  LEFT JOIN Orders o ON o.order_id = s.order_id
  WHERE f.flight_status = 'Completed'
  GROUP BY f.flight_id
) fso;

/* ================================= Query 2 ================================== */
SELECT
  p.plane_size,
  p.plane_manufacturer,
  x.class_type,
  ROUND(SUM(
    CASE
      WHEN o.order_status NOT IN ('Cancelled by system', 'Cancelled by customer')
        THEN x.seat_cnt * fcp.price
      WHEN o.order_status = 'Cancelled by customer'
        THEN x.seat_cnt * fcp.price * 0.05
      ELSE 0
    END
  ), 2) AS total_revenue
FROM (
  SELECT
    s.order_id,
    s.flight_id,
    s.class_type,
    COUNT(*) AS seat_cnt
  FROM Seat s
  WHERE s.order_id IS NOT NULL
  GROUP BY s.order_id, s.flight_id, s.class_type
) x
JOIN Orders o ON o.order_id = x.order_id
JOIN Flight f ON f.flight_id = x.flight_id
JOIN Plane p  ON p.plane_id = f.plane_id
JOIN Flight_Class_Pricing fcp
  ON fcp.flight_id  = f.flight_id
 AND fcp.plane_id   = f.plane_id
 AND fcp.class_type = x.class_type
WHERE f.flight_status IN ('Scheduled', 'Completed', 'Full')
GROUP BY
  p.plane_size,
  p.plane_manufacturer,
  x.class_type;

/* ================================= Query 3 ================================== */
WITH employee_flights AS (
  SELECT
    p.employee_id,
    fr.flight_duration
  FROM Pilot p
  LEFT JOIN Pilots_in_flights pf
    ON pf.employee_id = p.employee_id
  LEFT JOIN Flight f
    ON f.flight_id = pf.flight_id
   AND f.flight_status = 'Completed'
  LEFT JOIN Flight_route fr
    ON fr.route_id = f.route_id

  UNION ALL

  SELECT
    fa.employee_id,
    fr.flight_duration
  FROM Flight_attendant fa
  LEFT JOIN Flight_attendants_in_flights faf
    ON faf.employee_id = fa.employee_id
  LEFT JOIN Flight f
    ON f.flight_id = faf.flight_id
   AND f.flight_status = 'Completed'
  LEFT JOIN Flight_route fr
    ON fr.route_id = f.route_id
)
SELECT
  employee_id,
  ROUND(SUM(CASE WHEN flight_duration > 360 THEN flight_duration ELSE 0 END) / 60, 2) AS long_flight_hours,
  ROUND(SUM(CASE WHEN flight_duration <=  360 THEN flight_duration ELSE 0 END) / 60, 2) AS short_flight_hours
FROM employee_flights
GROUP BY employee_id
ORDER BY employee_id;

/* ================================= Query 4 ================================== */
SELECT
  DATE_FORMAT(date_of_purchase, '%Y-%m') AS purchase_month,
  ROUND(
    100 * SUM(CASE
                WHEN order_status = 'Cancelled by customer'
                THEN 1 ELSE 0
              END) / COUNT(*), 2
  ) AS customer_cancellation_rate
FROM Orders
GROUP BY DATE_FORMAT(date_of_purchase, '%Y-%m')
ORDER BY purchase_month;

/* ================================= Query 5 ================================== */
WITH base_flights AS (
  SELECT
    f.flight_id,
    f.plane_id,
    f.route_id,
    f.flight_status,
    f.takeoff_date,
    DATE_FORMAT(f.takeoff_date, '%Y-%m') AS month_ym
  FROM Flight f
  WHERE TIMESTAMP(f.takeoff_date, f.takeoff_time) < NOW()
),

flight_occupancy AS (
  SELECT
    s.flight_id,
    100 * AVG(
      s.order_id IS NOT NULL
      AND o.order_status NOT IN ('Cancelled by system', 'Cancelled by customer')
    ) AS occ_pct
  FROM Seat s
  LEFT JOIN Orders o ON o.order_id = s.order_id
  GROUP BY s.flight_id
),

monthly AS (
  SELECT
    plane_id,
    month_ym,
    SUM(flight_status IN ('Completed','Full')) AS completed_flights,
    SUM(flight_status = 'Cancelled') AS cancelled_flights,
    COUNT(DISTINCT IF(flight_status IN ('Completed','Full'), takeoff_date, NULL)) AS flown_days
  FROM base_flights
  GROUP BY plane_id, month_ym
),

dominant_route AS (
  SELECT
    bf.plane_id,
    bf.month_ym,
    fr.origin_airport,
    fr.destination_airport,
    ROW_NUMBER() OVER (
      PARTITION BY bf.plane_id, bf.month_ym
      ORDER BY
        COUNT(*) DESC,
        MAX(fo.occ_pct) DESC,
        fr.origin_airport,
        fr.destination_airport
    ) AS rn
  FROM base_flights bf
  JOIN Flight_route fr ON fr.route_id = bf.route_id
  LEFT JOIN flight_occupancy fo ON fo.flight_id = bf.flight_id
  WHERE bf.flight_status IN ('Completed','Full')
  GROUP BY bf.plane_id, bf.month_ym, fr.origin_airport, fr.destination_airport
)

SELECT
  m.plane_id,
  m.month_ym AS month,
  m.completed_flights,
  m.cancelled_flights,
  ROUND(100 * m.flown_days / 30, 2) AS utilization_pct,
  CONCAT_WS(' -> ', dr.origin_airport, dr.destination_airport)
    AS dominant_origin_destination
FROM monthly m
LEFT JOIN dominant_route dr
  ON dr.plane_id = m.plane_id
 AND dr.month_ym  = m.month_ym
 AND dr.rn = 1
WHERE m.completed_flights > 0
ORDER BY m.plane_id, month;


/* ================================= Graphs for the dashboard ================================== */
/* ===================== Flights completed per month  ===================== */
SELECT
  DATE_FORMAT(f.takeoff_date, '%Y-%m') AS month,
  COUNT(*) AS flights_completed
FROM Flight f
WHERE f.flight_status = 'Completed'
  AND TIMESTAMP(f.takeoff_date, f.takeoff_time) < NOW()
GROUP BY DATE_FORMAT(f.takeoff_date, '%Y-%m')
ORDER BY month;
/* ===================== Flight routes - Top 5  ===================== */
SELECT
  CONCAT(fr.origin_airport, ' → ', fr.destination_airport) AS route,
  COUNT(*) AS flights_completed
FROM Flight f
JOIN Flight_route fr
  ON fr.route_id = f.route_id
WHERE f.flight_status = 'Completed'
  AND TIMESTAMP(f.takeoff_date, f.takeoff_time) < NOW()
GROUP BY fr.origin_airport, fr.destination_airport
ORDER BY flights_completed DESC
LIMIT 5;
/* ===================== Flights by the time of day  ===================== */
SELECT
  HOUR(f.takeoff_time) AS takeoff_hour,
  COUNT(*) AS flights_count
FROM Flight f
WHERE
  TIMESTAMP(f.takeoff_date, f.takeoff_time) < NOW()
  AND f.flight_status IN ('Completed','Full')
GROUP BY HOUR(f.takeoff_time)
ORDER BY takeoff_hour;


/* ================================= Tests ================================== */
SELECT * FROM Plane;
SELECT * FROM Flight_route;
SELECT * FROM Guest;
SELECT * FROM Guest_phone;
SELECT * FROM Registered_customer;
SELECT * FROM Registered_customer_phone;
SELECT * FROM Manager;
SELECT * FROM Pilot;
SELECT * FROM Flight_attendant;
SELECT * FROM Flight;
SELECT * FROM Orders;
SELECT * FROM Cabin_class;
SELECT * FROM Seat;
SELECT * FROM Flight_Class_Pricing;
SELECT * FROM Pilots_in_flights;
SELECT * FROM Flight_attendants_in_flights;

/* ===================== IS_NULLABLE ===================== */
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'yardenaruch$FLYTAUdb'
  AND IS_NULLABLE = 'YES'
ORDER BY TABLE_NAME, COLUMN_NAME;

/* ===================== Seats created ===================== */
SELECT
  f.flight_id   AS flight_number,
  f.plane_id    AS plane_number,
  COUNT(s.flight_id) AS seats_created
FROM Flight f
LEFT JOIN Seat s
  ON s.flight_id = f.flight_id
GROUP BY f.flight_id, f.plane_id
ORDER BY f.flight_id;

/* ===================== Seats taken ===================== */
SELECT
  flight_id,
  COUNT(*) AS total,
  SUM(order_id IS NOT NULL) AS occupied,
  ROUND(100 * SUM(order_id IS NOT NULL) / COUNT(*), 1) AS occ_percent
FROM Seat
GROUP BY flight_id
ORDER BY flight_id;

/* ===================== Data types ===================== */
SELECT
  TABLE_NAME,
  COLUMN_NAME,
  DATA_TYPE,
  COLUMN_TYPE,
  IS_NULLABLE,
  COLUMN_KEY,
  COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'yardenaruch$FLYTAUdb'
ORDER BY
  TABLE_NAME,
  ORDINAL_POSITION;


