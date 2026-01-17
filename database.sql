USE yardenaruch$FLYTAUdb;

CREATE TABLE Plane (
  plane_id VARCHAR(5) PRIMARY KEY,
  plane_size ENUM('Small','Large') NOT NULL,
  plane_manufacturer ENUM('Boeing','Airbus','Dassault') NOT NULL,
  purchase_date DATE NOT NULL
);

CREATE TABLE Flight_route (
  route_id INT PRIMARY KEY,
  origin_airport VARCHAR(100) NOT NULL,
  destination_airport VARCHAR(100) NOT NULL,
  flight_duration INT NOT NULL,
  CONSTRAINT chk_route_duration CHECK (flight_duration > 0),
  CONSTRAINT chk_route_airports CHECK (origin_airport <> destination_airport)
);

CREATE TABLE Guest (
  customer_email VARCHAR(100) PRIMARY KEY,
  customer_first_name VARCHAR(60) NOT NULL,
  customer_last_name  VARCHAR(60) NOT NULL
);

CREATE TABLE Guest_phone (
  customer_email VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (customer_email, customer_phone),
  FOREIGN KEY (customer_email) REFERENCES Guest(customer_email)
);

CREATE TABLE Registered_customer (
  customer_email VARCHAR(100) PRIMARY KEY,
  customer_first_name VARCHAR(60) NOT NULL,
  customer_last_name VARCHAR(60) NOT NULL,
  customer_password VARCHAR(8) NOT NULL,
  passport_id VARCHAR(9) NOT NULL UNIQUE,
  birth_date DATE NOT NULL,
  sign_up_date DATE NOT NULL
);

CREATE TABLE Registered_customer_phone (
  customer_email VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(15) NOT NULL,
  PRIMARY KEY (customer_email, customer_phone),
  FOREIGN KEY (customer_email) REFERENCES Registered_customer(customer_email)
);

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

CREATE TABLE Orders (
  order_id VARCHAR(5) PRIMARY KEY,
  flight_id VARCHAR(5) NOT NULL,
  guest_email VARCHAR(100) NULL,
  reg_customer_email VARCHAR(100) NULL,
  date_of_purchase DATETIME NOT NULL,
  order_status ENUM('Active','Completed','Cancelled by customer','Cancelled by system') NOT NULL,
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (guest_email) REFERENCES Guest(customer_email),
  FOREIGN KEY (reg_customer_email) REFERENCES Registered_customer(customer_email),
  CONSTRAINT chk_order_one_customer CHECK (
    (guest_email IS NOT NULL AND reg_customer_email IS NULL)
    OR
    (guest_email IS NULL AND reg_customer_email IS NOT NULL)
  )
);

CREATE TABLE Cabin_class (
  plane_id VARCHAR(5) NOT NULL,
  class_type ENUM('Business','Economy') NOT NULL,
  flight_id VARCHAR(5) NOT NULL,
  columns_num INT NOT NULL,
  rows_num INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (plane_id, class_type),
  FOREIGN KEY (plane_id) REFERENCES Plane(plane_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  CONSTRAINT chk_class_dim CHECK (columns_num > 0 AND rows_num > 0),
  CONSTRAINT chk_class_price CHECK (price > 0)
);

CREATE TABLE Seat (
  flight_id VARCHAR(5) NOT NULL,
  s_row INT NOT NULL,
  s_column INT NOT NULL,
  plane_id VARCHAR(5),
  class_type ENUM('Business','Economy') NOT NULL,
  order_id VARCHAR(5) NULL,
  PRIMARY KEY (flight_id, s_row, s_column),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (plane_id, class_type) REFERENCES cabin_class (plane_id, class_type),
  FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Pilots_in_flights (
  flight_id VARCHAR(5) NOT NULL,
  employee_id VARCHAR(9) NOT NULL,
  PRIMARY KEY (flight_id, employee_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (employee_id) REFERENCES Pilot(employee_id)
);

CREATE TABLE Flight_attendants_in_flights (
  flight_id VARCHAR(5) NOT NULL,
  employee_id VARCHAR(9) NOT NULL,
  PRIMARY KEY (flight_id, employee_id),
  FOREIGN KEY (flight_id) REFERENCES Flight(flight_id),
  FOREIGN KEY (employee_id) REFERENCES Flight_attendant(employee_id)
);

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
SELECT * FROM Pilots_in_flights;
SELECT * FROM Flight_attendants_in_flights;