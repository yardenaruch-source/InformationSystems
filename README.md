# InformationSystems
# FlyTau – Flight Management System

## Project Overview
FlyTau is a flight management system that simulates the processes of an airline company.  
The project includes a relational database built in MySQL, advanced SQL queries for management analysis, and integration with a Python-based web application for data presentation.
The system manages flights, planes, routes, customers (registered and guests), orders, seating, and crew members, and enables data-driven insights for decision making.

## Project Goals
- Design and implement a relational database for an airline management system.
- Manage flights, orders, seating, customers, and crew members.
- Apply business logic rules such as cancellation policies and flight execution status.
- Develop complex SQL queries for management reports.
- Integrate the database with a development environment for real-time data usage.

## Technologies and Tools
- **MySQL Workbench** – Relational database management system  
- **Python** – Backend logic and data processing  
- **PyCharm** – Development environment  
- **Flask** – Web framework  
- **HTML and CSS** – Frontend  
- **GitHub** – Version control
- **Python anywhere** - Deployemnt platform

## Business Logic
- **Seating**:
  - In a plane with multiple cabin classes, seat row numbering is continuous across classes, meaning that the first row of the second class starts with the next number following the last row of the previous class.
- **Order cancellation policy**:
  - Customer cancellation at least 36 hours before takeoff results in a 5% cancellation fee.
  - System-initiated cancellations generate no revenue.
- **Flight execution logic**:
  - A flight is considered "completed" only if its takeoff date and time have already passed.
  - The status `Full` indicates full occupancy but does not necessarily mean the flight has already taken place.
- **Crew workload analysis**:
  - Flights are classified as short or long flights based on duration.


