USE yardenaruch$FLYTAUdb;

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
('P0004','Large','Boeing','2017-11-03'),
('P0005','Small','Dassault','2025-06-18'),
('P0006','Large','Airbus','2020-01-20');

CREATE TABLE Flight_route (
  route_id INT PRIMARY KEY,
  origin_airport VARCHAR(100) NOT NULL,
  destination_airport VARCHAR(100) NOT NULL,
  flight_duration INT NOT NULL,
  CONSTRAINT chk_route_duration CHECK (flight_duration > 0),
  CONSTRAINT chk_route_airports CHECK (origin_airport <> destination_airport)
);

INSERT INTO Flight_route (route_id, origin_airport, destination_airport, flight_duration)
VALUES
(101,'TLV - Ben Gurion','LCA - Larnaca',60),
(102,'TLV - Ben Gurion','ATH - Athens',120),
(103,'TLV - Ben Gurion','FCO - Rome',180),
(104,'TLV - Ben Gurion','CDG - Paris',300),
(105,'TLV - Ben Gurion','DXB - Dubai',190);

INSERT INTO Flight_route (route_id, origin_airport, destination_airport, flight_duration)
VALUES
(106,'BER - Berlin','JFK - New York',510),
(107,'JFK - New York','SYD - Sydney',1200),
(108,'SYD - Sydney','AKL - Auckland',190),
(109,'AKL - Auckland','DXB - Dubai',1020),
(110,'JFK - New York','CDG - Paris',465);



CREATE TABLE Guest (
  customer_email VARCHAR(100) PRIMARY KEY,
  customer_first_name VARCHAR(60) NOT NULL,
  customer_last_name  VARCHAR(60) NOT NULL
);

INSERT INTO Guest (customer_email, customer_first_name, customer_last_name) VALUES
('LiorB@gmail.com','Lior','Bar'),
('ShirP@gmail.com','Shir','Peretz'),
('EitanS@gmail.com','Eitan','Shalev');

CREATE TABLE Guest_phone (
  customer_email VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (customer_email, customer_phone),
  FOREIGN KEY (customer_email) REFERENCES Guest(customer_email)
);

INSERT INTO Guest_phone (customer_email, customer_phone) VALUES
('LiorB@gmail.com','052-7350841'),
('LiorB@gmail.com','052-4358985'),
('ShirP@gmail.com','053-4901768'),
('ShirP@gmail.com','053-5201796'),
('EitanS@gmail.com','054-9826305'),
('EitanS@gmail.com','054-6885423');

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
('roni.katz@gmail.com','Roni','Katz','Rc123456','A12345678','1996-04-12','2025-12-01'),
('yossi.dahan@gmail.com','Yossi','Dahan','Rc234567','B23456789','1990-09-03','2025-11-20'),
('maya.oren@gmail.com','Maya','Oren','Rc345678','C34567890','2001-02-18','2025-10-05');


CREATE TABLE Registered_customer_phone (
  customer_email VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (customer_email, customer_phone),
  FOREIGN KEY (customer_email) REFERENCES Registered_customer(customer_email)
);

INSERT INTO Registered_customer_phone (customer_email, customer_phone) VALUES
('roni.katz@gmail.com','054-6173928'),
('roni.katz@gmail.com','054-2133856'),
('yossi.dahan@gmail.com','055-9031846'),
('yossi.dahan@gmail.com','055-7238515'),
('maya.oren@gmail.com','058-2746195'),
('maya.oren@gmail.com','058-5696169');

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
('308457129','Itay','Sharon','054-7364821','Tel Aviv','Begin',12,'2019-01-10',1),
('214963587','Gil','Avraham','052-9183746','Haifa','Hagana',5,'2018-05-21',1),
('396805742','Omer','Naim','050-6048279','Jerusalem','King George',33,'2020-09-14',0),
('287451936','Tal','Bitan','053-4917268','Rishon LeZion','Rothschild',2,'2017-03-03',1),
('172604895','Rami','Halevi','058-2736491','Beer Sheva','Ben Gurion',18,'2021-07-08',0),
('459318260','Niv','Sason','055-8120947','Tel Aviv','Allenby',44,'2016-11-30',1),
('531794628','Ido','Regev','054-3659082','Netanya','Weizmann',9,'2015-02-19',1),
('648205173','Shai','Mor','052-7491836','Haifa','Carmel',77,'2022-04-25',1),
('704963581','Yuval','Peled','050-9812364','Jerusalem','Hillel',6,'2014-08-12',1),
('893417256','Erez','Koren','053-6205749','Ashdod','HaAtzmaut',21,'2023-01-09',0);

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
(employee_id, employee_first_name, employee_last_name, employee_phone, employee_city, employee_street, employee_street_num, employment_date, long_flight_training)
VALUES
('143829506','Yael','Cohen','055-2220001','Tel Aviv','Ibn Gabirol',10,'2020-02-01',1),
('275906314','Shani','Levi','055-2220002','Haifa','Hatzionut',3,'2021-06-11',0),
('368541972','Nitzan','Bar','055-2220003','Jerusalem','Agron',8,'2019-10-09',1),
('419276805','Gal','Peretz','055-2220004','Tel Aviv','Ben Yehuda',15,'2022-01-05',0),
('582013469','Or','Shaked','055-2220005','Netanya','Herzl',19,'2018-07-22',1),
('697428351','Adi','Nagar','055-2220006','Beer Sheva','Rager',4,'2017-03-17',1),
('724590168','Tamar','Doron','055-2220007','Haifa','Moriah',55,'2023-05-01',0),
('831764290','Liat','Maman','055-2220008','Ashdod','Menachem Begin',11,'2020-12-12',0),
('906215743','Hila','Katz','055-2220009','Rishon LeZion','HaPalmach',6,'2016-09-30',1),
('158374926','Noam','Shahar','055-2220010','Tel Aviv','Kaplan',2,'2019-01-20',1),
('264805731','Michal','Oren','055-2220011','Jerusalem','Emek Refaim',9,'2021-08-08',0),
('379162458','Bar','Sela','055-2220012','Haifa','Allenby',14,'2015-04-14',1),
('481907236','Rina','Hazan','055-2220013','Beer Sheva','HaNassi',1,'2018-11-11',0),
('590346817','Eden','Ariel','055-2220014','Tel Aviv','Arlozorov',30,'2017-06-06',1),
('618259704','Shira','Nadav','055-2220015','Netanya','Sderot Chen',7,'2022-09-09',1),
('742816593','Lena','Gold','055-2220016','Haifa','Nordau',20,'2020-01-15',1),
('853490162','Sivan','Rosen','055-2220017','Jerusalem','Jabotinsky',12,'2019-03-03',0),
('914627385','Yarden','Berg','055-2220018','Tel Aviv','Yigal Alon',18,'2016-02-02',1),
('236598174','Odelia','Stern','055-2220019','Ashkelon','HaNassi',5,'2023-02-14',0),
('467120958','Rotem','Huri','055-2220020','Rishon LeZion','Gordon',23,'2021-12-01',1);

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
('LY482',101,'P0001','248392176','2026-01-20','08:30:00','Scheduled'),
('BA917',102,'P0002','203948517','2024-11-14','12:15:00','Cancelled'),
('EK305',103,'P0003','281460239','2026-01-22','06:45:00','Full'),
('AF628',104,'P0004','248392176','2025-03-23','17:10:00','Completed'),
('LH749',105,'P0005','203948517','2026-02-24','09:05:00','Scheduled');


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


INSERT INTO Orders
(order_id, flight_id, guest_email, reg_customer_email, date_of_purchase, order_status)
VALUES
('48392','LY482',NULL,'roni.katz@gmail.com','2026-01-10 10:05:00','Active'),
('75016','BA917','LiorB@gmail.com',NULL,'2024-08-15 10:20:00','Cancelled by system'),
('29487','EK305',NULL,'yossi.dahan@gmail.com','2026-01-11 12:45:00','Active'),
('86104','AF628','ShirP@gmail.com',NULL,'2025-01-12 09:30:00','Completed'),
('53928','LH749','EitanS@gmail.com',NULL,'2026-01-12 18:10:00','Cancelled by customer');


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
('P0001','Economy',6,22),
('P0002','Business',4,10),
('P0002','Economy',6,20),
('P0003','Economy',4,15),
('P0004','Business',4,12),
('P0004','Economy',6,24),
('P0005','Economy',4,17);

CREATE TABLE Seat (
  flight_id VARCHAR(5) NOT NULL,
  s_row INT NOT NULL,
  s_column INT NOT NULL,
  plane_id VARCHAR(5) NOT NULL,
  class_type ENUM('Business','Economy') NOT NULL,
  order_id VARCHAR(5) NULL,
  PRIMARY KEY (flight_id, s_row, s_column),
  CONSTRAINT fk_seat_flight
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_seat_cabin_class
    FOREIGN KEY (plane_id, class_type) REFERENCES Cabin_class (plane_id, class_type)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_seat_order
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('LY482',1,1,'P0001','Business',NULL), ('LY482',1,2,'P0001','Business',NULL), ('LY482',1,3,'P0001','Business',NULL), ('LY482',1,4,'P0001','Business',NULL),
('LY482',2,1,'P0001','Business',NULL), ('LY482',2,2,'P0001','Business',NULL), ('LY482',2,3,'P0001','Business',NULL), ('LY482',2,4,'P0001','Business',NULL),
('LY482',3,1,'P0001','Business',NULL), ('LY482',3,2,'P0001','Business',NULL), ('LY482',3,3,'P0001','Business',NULL), ('LY482',3,4,'P0001','Business',NULL),
('LY482',4,1,'P0001','Business',NULL), ('LY482',4,2,'P0001','Business',NULL), ('LY482',4,3,'P0001','Business',NULL), ('LY482',4,4,'P0001','Business',NULL),
('LY482',5,1,'P0001','Business',NULL), ('LY482',5,2,'P0001','Business',NULL), ('LY482',5,3,'P0001','Business',NULL), ('LY482',5,4,'P0001','Business',NULL),
('LY482',6,1,'P0001','Business',NULL), ('LY482',6,2,'P0001','Business',NULL), ('LY482',6,3,'P0001','Business',NULL), ('LY482',6,4,'P0001','Business',NULL),
('LY482',7,1,'P0001','Business',NULL), ('LY482',7,2,'P0001','Business',NULL), ('LY482',7,3,'P0001','Business',NULL), ('LY482',7,4,'P0001','Business',NULL),
('LY482',8,1,'P0001','Business',NULL), ('LY482',8,2,'P0001','Business',NULL), ('LY482',8,3,'P0001','Business',NULL), ('LY482',8,4,'P0001','Business',NULL);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('LY482',9,1,'P0001','Economy',NULL), ('LY482',9,2,'P0001','Economy',NULL), ('LY482',9,3,'P0001','Economy',NULL), ('LY482',9,4,'P0001','Economy','48392'), ('LY482',9,5,'P0001','Economy','48392'), ('LY482',9,6,'P0001','Economy',NULL),
('LY482',10,1,'P0001','Economy',NULL), ('LY482',10,2,'P0001','Economy',NULL), ('LY482',10,3,'P0001','Economy',NULL), ('LY482',10,4,'P0001','Economy',NULL), ('LY482',10,5,'P0001','Economy',NULL), ('LY482',10,6,'P0001','Economy',NULL),
('LY482',11,1,'P0001','Economy',NULL), ('LY482',11,2,'P0001','Economy',NULL), ('LY482',11,3,'P0001','Economy',NULL), ('LY482',11,4,'P0001','Economy',NULL), ('LY482',11,5,'P0001','Economy',NULL), ('LY482',11,6,'P0001','Economy',NULL),
('LY482',12,1,'P0001','Economy',NULL), ('LY482',12,2,'P0001','Economy',NULL), ('LY482',12,3,'P0001','Economy',NULL), ('LY482',12,4,'P0001','Economy',NULL), ('LY482',12,5,'P0001','Economy',NULL), ('LY482',12,6,'P0001','Economy',NULL),
('LY482',13,1,'P0001','Economy',NULL), ('LY482',13,2,'P0001','Economy',NULL), ('LY482',13,3,'P0001','Economy',NULL), ('LY482',13,4,'P0001','Economy',NULL), ('LY482',13,5,'P0001','Economy',NULL), ('LY482',13,6,'P0001','Economy',NULL),
('LY482',14,1,'P0001','Economy',NULL), ('LY482',14,2,'P0001','Economy',NULL), ('LY482',14,3,'P0001','Economy',NULL), ('LY482',14,4,'P0001','Economy',NULL), ('LY482',14,5,'P0001','Economy',NULL), ('LY482',14,6,'P0001','Economy',NULL),
('LY482',15,1,'P0001','Economy',NULL), ('LY482',15,2,'P0001','Economy',NULL), ('LY482',15,3,'P0001','Economy',NULL), ('LY482',15,4,'P0001','Economy',NULL), ('LY482',15,5,'P0001','Economy',NULL), ('LY482',15,6,'P0001','Economy',NULL),
('LY482',16,1,'P0001','Economy',NULL), ('LY482',16,2,'P0001','Economy',NULL), ('LY482',16,3,'P0001','Economy',NULL), ('LY482',16,4,'P0001','Economy',NULL), ('LY482',16,5,'P0001','Economy',NULL), ('LY482',16,6,'P0001','Economy',NULL),
('LY482',17,1,'P0001','Economy',NULL), ('LY482',17,2,'P0001','Economy',NULL), ('LY482',17,3,'P0001','Economy',NULL), ('LY482',17,4,'P0001','Economy',NULL), ('LY482',17,5,'P0001','Economy',NULL), ('LY482',17,6,'P0001','Economy',NULL),
('LY482',18,1,'P0001','Economy',NULL), ('LY482',18,2,'P0001','Economy',NULL), ('LY482',18,3,'P0001','Economy',NULL), ('LY482',18,4,'P0001','Economy',NULL), ('LY482',18,5,'P0001','Economy',NULL), ('LY482',18,6,'P0001','Economy',NULL),
('LY482',19,1,'P0001','Economy',NULL), ('LY482',19,2,'P0001','Economy',NULL), ('LY482',19,3,'P0001','Economy',NULL), ('LY482',19,4,'P0001','Economy',NULL), ('LY482',19,5,'P0001','Economy',NULL), ('LY482',19,6,'P0001','Economy',NULL),
('LY482',20,1,'P0001','Economy',NULL), ('LY482',20,2,'P0001','Economy',NULL), ('LY482',20,3,'P0001','Economy',NULL), ('LY482',20,4,'P0001','Economy',NULL), ('LY482',20,5,'P0001','Economy',NULL), ('LY482',20,6,'P0001','Economy',NULL),
('LY482',21,1,'P0001','Economy',NULL), ('LY482',21,2,'P0001','Economy',NULL), ('LY482',21,3,'P0001','Economy',NULL), ('LY482',21,4,'P0001','Economy',NULL), ('LY482',21,5,'P0001','Economy',NULL), ('LY482',21,6,'P0001','Economy',NULL),
('LY482',22,1,'P0001','Economy',NULL), ('LY482',22,2,'P0001','Economy',NULL), ('LY482',22,3,'P0001','Economy',NULL), ('LY482',22,4,'P0001','Economy',NULL), ('LY482',22,5,'P0001','Economy',NULL), ('LY482',22,6,'P0001','Economy',NULL),
('LY482',23,1,'P0001','Economy',NULL), ('LY482',23,2,'P0001','Economy',NULL), ('LY482',23,3,'P0001','Economy',NULL), ('LY482',23,4,'P0001','Economy',NULL), ('LY482',23,5,'P0001','Economy',NULL), ('LY482',23,6,'P0001','Economy',NULL),
('LY482',24,1,'P0001','Economy',NULL), ('LY482',24,2,'P0001','Economy',NULL), ('LY482',24,3,'P0001','Economy',NULL), ('LY482',24,4,'P0001','Economy',NULL), ('LY482',24,5,'P0001','Economy',NULL), ('LY482',24,6,'P0001','Economy',NULL),
('LY482',25,1,'P0001','Economy',NULL), ('LY482',25,2,'P0001','Economy',NULL), ('LY482',25,3,'P0001','Economy',NULL), ('LY482',25,4,'P0001','Economy',NULL), ('LY482',25,5,'P0001','Economy',NULL), ('LY482',25,6,'P0001','Economy',NULL),
('LY482',26,1,'P0001','Economy',NULL), ('LY482',26,2,'P0001','Economy',NULL), ('LY482',26,3,'P0001','Economy',NULL), ('LY482',26,4,'P0001','Economy',NULL), ('LY482',26,5,'P0001','Economy',NULL), ('LY482',26,6,'P0001','Economy',NULL),
('LY482',27,1,'P0001','Economy',NULL), ('LY482',27,2,'P0001','Economy',NULL), ('LY482',27,3,'P0001','Economy',NULL), ('LY482',27,4,'P0001','Economy',NULL), ('LY482',27,5,'P0001','Economy',NULL), ('LY482',27,6,'P0001','Economy',NULL),
('LY482',28,1,'P0001','Economy',NULL), ('LY482',28,2,'P0001','Economy',NULL), ('LY482',28,3,'P0001','Economy',NULL), ('LY482',28,4,'P0001','Economy',NULL), ('LY482',28,5,'P0001','Economy',NULL), ('LY482',28,6,'P0001','Economy',NULL),
('LY482',29,1,'P0001','Economy',NULL), ('LY482',29,2,'P0001','Economy',NULL), ('LY482',29,3,'P0001','Economy',NULL), ('LY482',29,4,'P0001','Economy',NULL), ('LY482',29,5,'P0001','Economy',NULL), ('LY482',29,6,'P0001','Economy',NULL),
('LY482',30,1,'P0001','Economy',NULL), ('LY482',30,2,'P0001','Economy',NULL), ('LY482',30,3,'P0001','Economy',NULL), ('LY482',30,4,'P0001','Economy',NULL), ('LY482',30,5,'P0001','Economy',NULL), ('LY482',30,6,'P0001','Economy',NULL);


INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('BA917',1,1,'P0002','Business',NULL), ('BA917',1,2,'P0002','Business',NULL), ('BA917',1,3,'P0002','Business',NULL), ('BA917',1,4,'P0002','Business',NULL),
('BA917',2,1,'P0002','Business',NULL), ('BA917',2,2,'P0002','Business',NULL), ('BA917',2,3,'P0002','Business',NULL), ('BA917',2,4,'P0002','Business',NULL),
('BA917',3,1,'P0002','Business',NULL), ('BA917',3,2,'P0002','Business',NULL), ('BA917',3,3,'P0002','Business',NULL), ('BA917',3,4,'P0002','Business',NULL),
('BA917',4,1,'P0002','Business',NULL), ('BA917',4,2,'P0002','Business',NULL), ('BA917',4,3,'P0002','Business',NULL), ('BA917',4,4,'P0002','Business',NULL),
('BA917',5,1,'P0002','Business',NULL), ('BA917',5,2,'P0002','Business',NULL), ('BA917',5,3,'P0002','Business',NULL), ('BA917',5,4,'P0002','Business',NULL),
('BA917',6,1,'P0002','Business',NULL), ('BA917',6,2,'P0002','Business',NULL), ('BA917',6,3,'P0002','Business',NULL), ('BA917',6,4,'P0002','Business',NULL),
('BA917',7,1,'P0002','Business',NULL), ('BA917',7,2,'P0002','Business',NULL), ('BA917',7,3,'P0002','Business',NULL), ('BA917',7,4,'P0002','Business',NULL),
('BA917',8,1,'P0002','Business',NULL), ('BA917',8,2,'P0002','Business',NULL), ('BA917',8,3,'P0002','Business',NULL), ('BA917',8,4,'P0002','Business',NULL),
('BA917',9,1,'P0002','Business',NULL), ('BA917',9,2,'P0002','Business',NULL), ('BA917',9,3,'P0002','Business',NULL), ('BA917',9,4,'P0002','Business',NULL),
('BA917',10,1,'P0002','Business',NULL), ('BA917',10,2,'P0002','Business',NULL), ('BA917',10,3,'P0002','Business',NULL), ('BA917',10,4,'P0002','Business',NULL);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('BA917',11,1,'P0002','Economy',NULL), ('BA917',11,2,'P0002','Economy',NULL), ('BA917',11,3,'P0002','Economy',NULL), ('BA917',11,4,'P0002','Economy',NULL), ('BA917',11,5,'P0002','Economy',NULL), ('BA917',11,6,'P0002','Economy',NULL),
('BA917',12,1,'P0002','Economy',NULL), ('BA917',12,2,'P0002','Economy',NULL), ('BA917',12,3,'P0002','Economy',NULL), ('BA917',12,4,'P0002','Economy',NULL), ('BA917',12,5,'P0002','Economy',NULL), ('BA917',12,6,'P0002','Economy',NULL),
('BA917',13,1,'P0002','Economy',NULL), ('BA917',13,2,'P0002','Economy',NULL), ('BA917',13,3,'P0002','Economy',NULL), ('BA917',13,4,'P0002','Economy',NULL), ('BA917',13,5,'P0002','Economy',NULL), ('BA917',13,6,'P0002','Economy',NULL),
('BA917',14,1,'P0002','Economy',NULL), ('BA917',14,2,'P0002','Economy',NULL), ('BA917',14,3,'P0002','Economy',NULL), ('BA917',14,4,'P0002','Economy',NULL), ('BA917',14,5,'P0002','Economy',NULL), ('BA917',14,6,'P0002','Economy',NULL),
('BA917',15,1,'P0002','Economy',NULL), ('BA917',15,2,'P0002','Economy',NULL), ('BA917',15,3,'P0002','Economy',NULL), ('BA917',15,4,'P0002','Economy',NULL), ('BA917',15,5,'P0002','Economy',NULL), ('BA917',15,6,'P0002','Economy',NULL),
('BA917',16,1,'P0002','Economy',NULL), ('BA917',16,2,'P0002','Economy',NULL), ('BA917',16,3,'P0002','Economy',NULL), ('BA917',16,4,'P0002','Economy',NULL), ('BA917',16,5,'P0002','Economy',NULL), ('BA917',16,6,'P0002','Economy',NULL),
('BA917',17,1,'P0002','Economy',NULL), ('BA917',17,2,'P0002','Economy',NULL), ('BA917',17,3,'P0002','Economy',NULL), ('BA917',17,4,'P0002','Economy',NULL), ('BA917',17,5,'P0002','Economy',NULL), ('BA917',17,6,'P0002','Economy',NULL),
('BA917',18,1,'P0002','Economy',NULL), ('BA917',18,2,'P0002','Economy',NULL), ('BA917',18,3,'P0002','Economy',NULL), ('BA917',18,4,'P0002','Economy',NULL), ('BA917',18,5,'P0002','Economy',NULL), ('BA917',18,6,'P0002','Economy',NULL),
('BA917',19,1,'P0002','Economy',NULL), ('BA917',19,2,'P0002','Economy',NULL), ('BA917',19,3,'P0002','Economy',NULL), ('BA917',19,4,'P0002','Economy',NULL), ('BA917',19,5,'P0002','Economy',NULL), ('BA917',19,6,'P0002','Economy',NULL),
('BA917',20,1,'P0002','Economy',NULL), ('BA917',20,2,'P0002','Economy',NULL), ('BA917',20,3,'P0002','Economy',NULL), ('BA917',20,4,'P0002','Economy',NULL), ('BA917',20,5,'P0002','Economy',NULL), ('BA917',20,6,'P0002','Economy',NULL),
('BA917',21,1,'P0002','Economy',NULL), ('BA917',21,2,'P0002','Economy',NULL), ('BA917',21,3,'P0002','Economy',NULL), ('BA917',21,4,'P0002','Economy',NULL), ('BA917',21,5,'P0002','Economy',NULL), ('BA917',21,6,'P0002','Economy',NULL),
('BA917',22,1,'P0002','Economy',NULL), ('BA917',22,2,'P0002','Economy',NULL), ('BA917',22,3,'P0002','Economy',NULL), ('BA917',22,4,'P0002','Economy',NULL), ('BA917',22,5,'P0002','Economy',NULL), ('BA917',22,6,'P0002','Economy',NULL),
('BA917',23,1,'P0002','Economy',NULL), ('BA917',23,2,'P0002','Economy',NULL), ('BA917',23,3,'P0002','Economy',NULL), ('BA917',23,4,'P0002','Economy',NULL), ('BA917',23,5,'P0002','Economy',NULL), ('BA917',23,6,'P0002','Economy',NULL),
('BA917',24,1,'P0002','Economy',NULL), ('BA917',24,2,'P0002','Economy',NULL), ('BA917',24,3,'P0002','Economy',NULL), ('BA917',24,4,'P0002','Economy',NULL), ('BA917',24,5,'P0002','Economy',NULL), ('BA917',24,6,'P0002','Economy',NULL),
('BA917',25,1,'P0002','Economy',NULL), ('BA917',25,2,'P0002','Economy',NULL), ('BA917',25,3,'P0002','Economy',NULL), ('BA917',25,4,'P0002','Economy',NULL), ('BA917',25,5,'P0002','Economy',NULL), ('BA917',25,6,'P0002','Economy',NULL),
('BA917',26,1,'P0002','Economy',NULL), ('BA917',26,2,'P0002','Economy',NULL), ('BA917',26,3,'P0002','Economy',NULL), ('BA917',26,4,'P0002','Economy',NULL), ('BA917',26,5,'P0002','Economy',NULL), ('BA917',26,6,'P0002','Economy',NULL),
('BA917',27,1,'P0002','Economy',NULL), ('BA917',27,2,'P0002','Economy',NULL), ('BA917',27,3,'P0002','Economy',NULL), ('BA917',27,4,'P0002','Economy',NULL), ('BA917',27,5,'P0002','Economy',NULL), ('BA917',27,6,'P0002','Economy',NULL),
('BA917',28,1,'P0002','Economy',NULL), ('BA917',28,2,'P0002','Economy',NULL), ('BA917',28,3,'P0002','Economy',NULL), ('BA917',28,4,'P0002','Economy',NULL), ('BA917',28,5,'P0002','Economy',NULL), ('BA917',28,6,'P0002','Economy',NULL),
('BA917',29,1,'P0002','Economy',NULL), ('BA917',29,2,'P0002','Economy',NULL), ('BA917',29,3,'P0002','Economy',NULL), ('BA917',29,4,'P0002','Economy',NULL), ('BA917',29,5,'P0002','Economy',NULL), ('BA917',29,6,'P0002','Economy',NULL),
('BA917',30,1,'P0002','Economy',NULL), ('BA917',30,2,'P0002','Economy',NULL), ('BA917',30,3,'P0002','Economy',NULL), ('BA917',30,4,'P0002','Economy',NULL), ('BA917',30,5,'P0002','Economy',NULL), ('BA917',30,6,'P0002','Economy',NULL);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('EK305',1,1,'P0003','Economy',NULL), ('EK305',1,2,'P0003','Economy',NULL), ('EK305',1,3,'P0003','Economy',NULL), ('EK305',1,4,'P0003','Economy',NULL),
('EK305',2,1,'P0003','Economy',NULL), ('EK305',2,2,'P0003','Economy',NULL), ('EK305',2,3,'P0003','Economy',NULL), ('EK305',2,4,'P0003','Economy',NULL),
('EK305',3,1,'P0003','Economy',NULL), ('EK305',3,2,'P0003','Economy',NULL), ('EK305',3,3,'P0003','Economy',NULL), ('EK305',3,4,'P0003','Economy',NULL),
('EK305',4,1,'P0003','Economy',NULL), ('EK305',4,2,'P0003','Economy',NULL), ('EK305',4,3,'P0003','Economy',NULL), ('EK305',4,4,'P0003','Economy',NULL),
('EK305',5,1,'P0003','Economy',NULL), ('EK305',5,2,'P0003','Economy',NULL), ('EK305',5,3,'P0003','Economy',NULL), ('EK305',5,4,'P0003','Economy',NULL),
('EK305',6,1,'P0003','Economy',NULL), ('EK305',6,2,'P0003','Economy',NULL), ('EK305',6,3,'P0003','Economy',NULL), ('EK305',6,4,'P0003','Economy',NULL),
('EK305',7,1,'P0003','Economy','29487'), ('EK305',7,2,'P0003','Economy','29487'), ('EK305',7,3,'P0003','Economy','29487'), ('EK305',7,4,'P0003','Economy','29487'),
('EK305',8,1,'P0003','Economy',NULL), ('EK305',8,2,'P0003','Economy',NULL), ('EK305',8,3,'P0003','Economy',NULL), ('EK305',8,4,'P0003','Economy',NULL),
('EK305',9,1,'P0003','Economy',NULL), ('EK305',9,2,'P0003','Economy',NULL), ('EK305',9,3,'P0003','Economy',NULL), ('EK305',9,4,'P0003','Economy',NULL),
('EK305',10,1,'P0003','Economy',NULL), ('EK305',10,2,'P0003','Economy',NULL), ('EK305',10,3,'P0003','Economy',NULL), ('EK305',10,4,'P0003','Economy',NULL),
('EK305',11,1,'P0003','Economy',NULL), ('EK305',11,2,'P0003','Economy',NULL), ('EK305',11,3,'P0003','Economy',NULL), ('EK305',11,4,'P0003','Economy',NULL),
('EK305',12,1,'P0003','Economy',NULL), ('EK305',12,2,'P0003','Economy',NULL), ('EK305',12,3,'P0003','Economy',NULL), ('EK305',12,4,'P0003','Economy',NULL),
('EK305',13,1,'P0003','Economy',NULL), ('EK305',13,2,'P0003','Economy',NULL), ('EK305',13,3,'P0003','Economy',NULL), ('EK305',13,4,'P0003','Economy',NULL),
('EK305',14,1,'P0003','Economy',NULL), ('EK305',14,2,'P0003','Economy',NULL), ('EK305',14,3,'P0003','Economy',NULL), ('EK305',14,4,'P0003','Economy',NULL),
('EK305',15,1,'P0003','Economy',NULL), ('EK305',15,2,'P0003','Economy',NULL), ('EK305',15,3,'P0003','Economy',NULL), ('EK305',15,4,'P0003','Economy',NULL);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('AF628',1,1,'P0004','Business',NULL), ('AF628',1,2,'P0004','Business',NULL), ('AF628',1,3,'P0004','Business',NULL), ('AF628',1,4,'P0004','Business',NULL),
('AF628',2,1,'P0004','Business',NULL), ('AF628',2,2,'P0004','Business',NULL), ('AF628',2,3,'P0004','Business',NULL), ('AF628',2,4,'P0004','Business',NULL),
('AF628',3,1,'P0004','Business',NULL), ('AF628',3,2,'P0004','Business',NULL), ('AF628',3,3,'P0004','Business',NULL), ('AF628',3,4,'P0004','Business',NULL),
('AF628',4,1,'P0004','Business',NULL), ('AF628',4,2,'P0004','Business',NULL), ('AF628',4,3,'P0004','Business',NULL), ('AF628',4,4,'P0004','Business',NULL),
('AF628',5,1,'P0004','Business',NULL), ('AF628',5,2,'P0004','Business',NULL), ('AF628',5,3,'P0004','Business',NULL), ('AF628',5,4,'P0004','Business',NULL),
('AF628',6,1,'P0004','Business',NULL), ('AF628',6,2,'P0004','Business',NULL), ('AF628',6,3,'P0004','Business',NULL), ('AF628',6,4,'P0004','Business',NULL),
('AF628',7,1,'P0004','Business',NULL), ('AF628',7,2,'P0004','Business',NULL), ('AF628',7,3,'P0004','Business',NULL), ('AF628',7,4,'P0004','Business',NULL),
('AF628',8,1,'P0004','Business',NULL), ('AF628',8,2,'P0004','Business',NULL), ('AF628',8,3,'P0004','Business',NULL), ('AF628',8,4,'P0004','Business',NULL),
('AF628',9,1,'P0004','Business',NULL), ('AF628',9,2,'P0004','Business',NULL), ('AF628',9,3,'P0004','Business',NULL), ('AF628',9,4,'P0004','Business',NULL),
('AF628',10,1,'P0004','Business',NULL), ('AF628',10,2,'P0004','Business',NULL), ('AF628',10,3,'P0004','Business',NULL), ('AF628',10,4,'P0004','Business',NULL),
('AF628',11,1,'P0004','Business',NULL), ('AF628',11,2,'P0004','Business',NULL), ('AF628',11,3,'P0004','Business',NULL), ('AF628',11,4,'P0004','Business',NULL),
('AF628',12,1,'P0004','Business',NULL), ('AF628',12,2,'P0004','Business',NULL), ('AF628',12,3,'P0004','Business',NULL), ('AF628',12,4,'P0004','Business',NULL);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('AF628',13,1,'P0004','Economy',NULL), ('AF628',13,2,'P0004','Economy',NULL), ('AF628',13,3,'P0004','Economy',NULL), ('AF628',13,4,'P0004','Economy',NULL), ('AF628',13,5,'P0004','Economy',NULL), ('AF628',13,6,'P0004','Economy',NULL),
('AF628',14,1,'P0004','Economy',NULL), ('AF628',14,2,'P0004','Economy',NULL), ('AF628',14,3,'P0004','Economy',NULL), ('AF628',14,4,'P0004','Economy',NULL), ('AF628',14,5,'P0004','Economy',NULL), ('AF628',14,6,'P0004','Economy',NULL),
('AF628',15,1,'P0004','Economy',NULL), ('AF628',15,2,'P0004','Economy',NULL), ('AF628',15,3,'P0004','Economy',NULL), ('AF628',15,4,'P0004','Economy',NULL), ('AF628',15,5,'P0004','Economy',NULL), ('AF628',15,6,'P0004','Economy',NULL),
('AF628',16,1,'P0004','Economy',NULL), ('AF628',16,2,'P0004','Economy',NULL), ('AF628',16,3,'P0004','Economy',NULL), ('AF628',16,4,'P0004','Economy',NULL), ('AF628',16,5,'P0004','Economy',NULL), ('AF628',16,6,'P0004','Economy',NULL),
('AF628',17,1,'P0004','Economy',NULL), ('AF628',17,2,'P0004','Economy',NULL), ('AF628',17,3,'P0004','Economy',NULL), ('AF628',17,4,'P0004','Economy',NULL), ('AF628',17,5,'P0004','Economy',NULL), ('AF628',17,6,'P0004','Economy',NULL),
('AF628',18,1,'P0004','Economy',NULL), ('AF628',18,2,'P0004','Economy','86104'), ('AF628',18,3,'P0004','Economy',NULL), ('AF628',18,4,'P0004','Economy',NULL), ('AF628',18,5,'P0004','Economy',NULL), ('AF628',18,6,'P0004','Economy',NULL),
('AF628',19,1,'P0004','Economy',NULL), ('AF628',19,2,'P0004','Economy',NULL), ('AF628',19,3,'P0004','Economy',NULL), ('AF628',19,4,'P0004','Economy',NULL), ('AF628',19,5,'P0004','Economy',NULL), ('AF628',19,6,'P0004','Economy',NULL),
('AF628',20,1,'P0004','Economy',NULL), ('AF628',20,2,'P0004','Economy',NULL), ('AF628',20,3,'P0004','Economy',NULL), ('AF628',20,4,'P0004','Economy',NULL), ('AF628',20,5,'P0004','Economy',NULL), ('AF628',20,6,'P0004','Economy',NULL),
('AF628',21,1,'P0004','Economy',NULL), ('AF628',21,2,'P0004','Economy',NULL), ('AF628',21,3,'P0004','Economy',NULL), ('AF628',21,4,'P0004','Economy',NULL), ('AF628',21,5,'P0004','Economy',NULL), ('AF628',21,6,'P0004','Economy',NULL),
('AF628',22,1,'P0004','Economy',NULL), ('AF628',22,2,'P0004','Economy',NULL), ('AF628',22,3,'P0004','Economy',NULL), ('AF628',22,4,'P0004','Economy',NULL), ('AF628',22,5,'P0004','Economy',NULL), ('AF628',22,6,'P0004','Economy',NULL),
('AF628',23,1,'P0004','Economy',NULL), ('AF628',23,2,'P0004','Economy',NULL), ('AF628',23,3,'P0004','Economy',NULL), ('AF628',23,4,'P0004','Economy',NULL), ('AF628',23,5,'P0004','Economy',NULL), ('AF628',23,6,'P0004','Economy',NULL),
('AF628',24,1,'P0004','Economy',NULL), ('AF628',24,2,'P0004','Economy',NULL), ('AF628',24,3,'P0004','Economy',NULL), ('AF628',24,4,'P0004','Economy',NULL), ('AF628',24,5,'P0004','Economy',NULL), ('AF628',24,6,'P0004','Economy',NULL),
('AF628',25,1,'P0004','Economy',NULL), ('AF628',25,2,'P0004','Economy',NULL), ('AF628',25,3,'P0004','Economy',NULL), ('AF628',25,4,'P0004','Economy',NULL), ('AF628',25,5,'P0004','Economy',NULL), ('AF628',25,6,'P0004','Economy',NULL),
('AF628',26,1,'P0004','Economy',NULL), ('AF628',26,2,'P0004','Economy',NULL), ('AF628',26,3,'P0004','Economy',NULL), ('AF628',26,4,'P0004','Economy',NULL), ('AF628',26,5,'P0004','Economy',NULL), ('AF628',26,6,'P0004','Economy',NULL),
('AF628',27,1,'P0004','Economy',NULL), ('AF628',27,2,'P0004','Economy',NULL), ('AF628',27,3,'P0004','Economy',NULL), ('AF628',27,4,'P0004','Economy',NULL), ('AF628',27,5,'P0004','Economy',NULL), ('AF628',27,6,'P0004','Economy',NULL),
('AF628',28,1,'P0004','Economy',NULL), ('AF628',28,2,'P0004','Economy',NULL), ('AF628',28,3,'P0004','Economy',NULL), ('AF628',28,4,'P0004','Economy',NULL), ('AF628',28,5,'P0004','Economy',NULL), ('AF628',28,6,'P0004','Economy',NULL),
('AF628',29,1,'P0004','Economy',NULL), ('AF628',29,2,'P0004','Economy',NULL), ('AF628',29,3,'P0004','Economy',NULL), ('AF628',29,4,'P0004','Economy',NULL), ('AF628',29,5,'P0004','Economy',NULL), ('AF628',29,6,'P0004','Economy',NULL),
('AF628',30,1,'P0004','Economy',NULL), ('AF628',30,2,'P0004','Economy',NULL), ('AF628',30,3,'P0004','Economy',NULL), ('AF628',30,4,'P0004','Economy',NULL), ('AF628',30,5,'P0004','Economy',NULL), ('AF628',30,6,'P0004','Economy',NULL),
('AF628',31,1,'P0004','Economy',NULL), ('AF628',31,2,'P0004','Economy',NULL), ('AF628',31,3,'P0004','Economy',NULL), ('AF628',31,4,'P0004','Economy',NULL), ('AF628',31,5,'P0004','Economy',NULL), ('AF628',31,6,'P0004','Economy',NULL),
('AF628',32,1,'P0004','Economy',NULL), ('AF628',32,2,'P0004','Economy',NULL), ('AF628',32,3,'P0004','Economy',NULL), ('AF628',32,4,'P0004','Economy',NULL), ('AF628',32,5,'P0004','Economy',NULL), ('AF628',32,6,'P0004','Economy',NULL),
('AF628',33,1,'P0004','Economy',NULL), ('AF628',33,2,'P0004','Economy',NULL), ('AF628',33,3,'P0004','Economy',NULL), ('AF628',33,4,'P0004','Economy',NULL), ('AF628',33,5,'P0004','Economy',NULL), ('AF628',33,6,'P0004','Economy',NULL),
('AF628',34,1,'P0004','Economy',NULL), ('AF628',34,2,'P0004','Economy',NULL), ('AF628',34,3,'P0004','Economy',NULL), ('AF628',34,4,'P0004','Economy',NULL), ('AF628',34,5,'P0004','Economy',NULL), ('AF628',34,6,'P0004','Economy',NULL),
('AF628',35,1,'P0004','Economy',NULL), ('AF628',35,2,'P0004','Economy',NULL), ('AF628',35,3,'P0004','Economy',NULL), ('AF628',35,4,'P0004','Economy',NULL), ('AF628',35,5,'P0004','Economy',NULL), ('AF628',35,6,'P0004','Economy',NULL),
('AF628',36,1,'P0004','Economy',NULL), ('AF628',36,2,'P0004','Economy',NULL), ('AF628',36,3,'P0004','Economy',NULL), ('AF628',36,4,'P0004','Economy',NULL), ('AF628',36,5,'P0004','Economy',NULL), ('AF628',36,6,'P0004','Economy',NULL);

INSERT INTO Seat (flight_id, s_row, s_column, plane_id, class_type, order_id)
VALUES
('LH749',1,1,'P0005','Economy',NULL), ('LH749',1,2,'P0005','Economy',NULL), ('LH749',1,3,'P0005','Economy',NULL), ('LH749',1,4,'P0005','Economy',NULL),
('LH749',2,1,'P0005','Economy',NULL), ('LH749',2,2,'P0005','Economy',NULL), ('LH749',2,3,'P0005','Economy',NULL), ('LH749',2,4,'P0005','Economy',NULL),
('LH749',3,1,'P0005','Economy',NULL), ('LH749',3,2,'P0005','Economy',NULL), ('LH749',3,3,'P0005','Economy',NULL), ('LH749',3,4,'P0005','Economy',NULL),
('LH749',4,1,'P0005','Economy',NULL), ('LH749',4,2,'P0005','Economy',NULL), ('LH749',4,3,'P0005','Economy',NULL), ('LH749',4,4,'P0005','Economy',NULL),
('LH749',5,1,'P0005','Economy',NULL), ('LH749',5,2,'P0005','Economy',NULL), ('LH749',5,3,'P0005','Economy',NULL), ('LH749',5,4,'P0005','Economy',NULL),
('LH749',6,1,'P0005','Economy',NULL), ('LH749',6,2,'P0005','Economy',NULL), ('LH749',6,3,'P0005','Economy',NULL), ('LH749',6,4,'P0005','Economy',NULL),
('LH749',7,1,'P0005','Economy',NULL), ('LH749',7,2,'P0005','Economy',NULL), ('LH749',7,3,'P0005','Economy',NULL), ('LH749',7,4,'P0005','Economy',NULL),
('LH749',8,1,'P0005','Economy',NULL), ('LH749',8,2,'P0005','Economy',NULL), ('LH749',8,3,'P0005','Economy',NULL), ('LH749',8,4,'P0005','Economy',NULL),
('LH749',9,1,'P0005','Economy',NULL), ('LH749',9,2,'P0005','Economy',NULL), ('LH749',9,3,'P0005','Economy',NULL), ('LH749',9,4,'P0005','Economy',NULL),
('LH749',10,1,'P0005','Economy',NULL), ('LH749',10,2,'P0005','Economy',NULL), ('LH749',10,3,'P0005','Economy',NULL), ('LH749',10,4,'P0005','Economy',NULL),
('LH749',11,1,'P0005','Economy',NULL), ('LH749',11,2,'P0005','Economy',NULL), ('LH749',11,3,'P0005','Economy',NULL), ('LH749',11,4,'P0005','Economy',NULL),
('LH749',12,1,'P0005','Economy',NULL), ('LH749',12,2,'P0005','Economy',NULL), ('LH749',12,3,'P0005','Economy',NULL), ('LH749',12,4,'P0005','Economy',NULL),
('LH749',13,1,'P0005','Economy',NULL), ('LH749',13,2,'P0005','Economy',NULL), ('LH749',13,3,'P0005','Economy',NULL), ('LH749',13,4,'P0005','Economy',NULL),
('LH749',14,1,'P0005','Economy',NULL), ('LH749',14,2,'P0005','Economy',NULL), ('LH749',14,3,'P0005','Economy',NULL), ('LH749',14,4,'P0005','Economy',NULL),
('LH749',15,1,'P0005','Economy',NULL), ('LH749',15,2,'P0005','Economy',NULL), ('LH749',15,3,'P0005','Economy',NULL), ('LH749',15,4,'P0005','Economy',NULL),
('LH749',16,1,'P0005','Economy',NULL), ('LH749',16,2,'P0005','Economy',NULL), ('LH749',16,3,'P0005','Economy',NULL), ('LH749',16,4,'P0005','Economy',NULL),
('LH749',17,1,'P0005','Economy',NULL), ('LH749',17,2,'P0005','Economy',NULL), ('LH749',17,3,'P0005','Economy',NULL), ('LH749',17,4,'P0005','Economy',NULL);


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
('LY482','P0001','Business',1200.00),
('LY482','P0001','Economy',450.00),
('BA917','P0002','Business',1100.00),
('BA917','P0002','Economy',420.00),
('EK305','P0003','Economy',350.00),
('AF628','P0004','Business',1300.00),
('AF628','P0004','Economy',480.00),
('LH749','P0005','Economy',320.00);

CREATE TABLE Pilots_in_flights (
  flight_id VARCHAR(5) NOT NULL,
  employee_id VARCHAR(9) NOT NULL,
  PRIMARY KEY (flight_id, employee_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (employee_id) REFERENCES Pilot(employee_id)
);

INSERT INTO Pilots_in_flights (flight_id, employee_id)
VALUES
-- P0004 (Large) -> 3 pilots
('AF628','214963587'),
('AF628','287451936'),
('AF628','308457129'),
-- P0002 (Large) -> 3 pilots
('BA917','214963587'),
('BA917','287451936'),
('BA917','308457129'),
-- P0003 (Small) -> 2 pilots
('EK305','172604895'),
('EK305','396805742'),
-- P0005 (Small) -> 2 pilots
('LH749','704963581'),
('LH749','893417256'),
-- P0001 (Large) -> 3 pilots
('LY482','459318260'),
('LY482','531794628'),
('LY482','648205173');

CREATE TABLE Flight_attendants_in_flights (
  flight_id VARCHAR(5) NOT NULL,
  employee_id VARCHAR(9) NOT NULL,
  PRIMARY KEY (flight_id, employee_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (employee_id) REFERENCES Flight_attendant(employee_id)
);

INSERT INTO Flight_attendants_in_flights (flight_id, employee_id)
VALUES
-- P0004 (Large) -> 6 attendants
('AF628','143829506'),
('AF628','158374926'),
('AF628','368541972'),
('AF628','379162458'),
('AF628','467120958'),
('AF628','582013469'),
-- P0002 (Large) -> 6 attendants
('BA917','143829506'),
('BA917','158374926'),
('BA917','368541972'),
('BA917','379162458'),
('BA917','467120958'),
('BA917','582013469'),
-- P0003 (Small) -> 3 attendants
('EK305','236598174'),
('EK305','264805731'),
('EK305','275906314'),
-- P0005 (Small) -> 3 attendants
('LH749','419276805'),
('LH749','481907236'),
('LH749','724590168'),
-- P0001 (Large) -> 6 attendants
('LY482','590346817'),
('LY482','618259704'),
('LY482','697428351'),
('LY482','742816593'),
('LY482','906215743'),
('LY482','914627385');

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
