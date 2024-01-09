-- Company Database

DROP DATABASE IF EXISTS company_46;

CREATE DATABASE IF NOT EXISTS company_46;

USE company_46;

CREATE TABLE IF NOT EXISTS employee(
    SSN VARCHAR(100) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(100),
    Sex VARCHAR(1),
    Salary INT,
    SuperSSN VARCHAR(100),
    DNo INT NOT NULL,
    FOREIGN KEY (SuperSSN) REFERENCES employee(SSN) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS department(
	DNo INT PRIMARY KEY,
    DName VARCHAR(100) NOT NULL,
    MgrSSN VARCHAR(100) NOT NULL,
    MgrStartDate DATE NOT NULL,
    FOREIGN KEY (MgrSSN) REFERENCES employee(SSN) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS dlocation(
    DNo INT,
    Dloc VARCHAR(100) NOT NULL,
    PRIMARY KEY (DNo, Dloc),
    FOREIGN KEY (DNo) REFERENCES department(DNo) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS project(
	PNo INT PRIMARY KEY,
    PName VARCHAR(100) NOT NULL,
    Plocation VARCHAR(100),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES department(DNo) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS works_on(
    SSN VARCHAR(100),
    PNo INT,
    Hours INT,
    FOREIGN KEY (SSN) REFERENCES employee(SSN) ON DELETE CASCADE,
    FOREIGN KEY (PNo) REFERENCES project(PNo) ON DELETE CASCADE
);

INSERT INTO employee VALUES
("e001", "Scott", "Siddartha Nagar, Mysuru", "M", 200000, "e001", 1),
("e002", "student_2", "Lakshmipuram, Mysuru", "F", 250000,"e001", 2),
("e003", "student_3", "Pune, Maharashtra", "M", 300000,"e001", 3),
("e004", "student_4", "Hyderabad, Telangana", "M", 620000, "e002", 4),
("e005", "student_5", "JP Nagar, Bengaluru", "F", 700000, "e002", 4);

SELECT * FROM employee;

INSERT INTO department VALUES
(1, "dept_1", "e001", "2020-10-21"),
(2, "dept_2", "e002", "2020-10-19"),
(3, "Accounts", "e003", "2020-10-27"),
(4, "dept_4", "e004", "2020-08-16"),
(5, "dept_5", "e005", "2020-09-4");

SELECT * FROM department;

ALTER TABLE employee ADD CONSTRAINT FOREIGN KEY (DNo) REFERENCES department(DNo) ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO dlocation VALUES
(1, "Jaynagar, Bengaluru"),
(2, "Vijaynagar, Mysuru"),
(3, "Chennai, Tamil Nadu"),
(4, "Mumbai, Maharashtra"),
(5, "Kuvempunagar, Mysuru");

SELECT * FROM dlocation;

INSERT INTO project VALUES
(01, "proj_1", "Mumbai, Maharashtra", 1),
(02, "IOT", "JP Nagar, Bengaluru", 2),
(03, "proj_3", "Hyderabad, Telangana", 3),
(04, "proj_4", "Kuvempunagar, Mysuru", 4),
(05, "proj_5", "Saraswatipuram, Mysuru", 5);

SELECT * FROM project;

INSERT INTO works_on VALUES
("e001", 01, 5),
("e002", 02, 6),
("e003", 03, 3),
("e004", 04, 3),
("e005", 05, 6);

SELECT * FROM works_on;

-- Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’, 
-- either as a worker or as a manager of the department that controls the project.

SELECT PNo, PName, Name FROM project p, employee e WHERE p.DNo=e.DNo and e.Name LIKE "%Scott";


-- Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise

SELECT w.SSN, Name, salary AS old_salary, salary * 1.1 AS new_salary 
FROM employee e, project p, works_on w
WHERE e.SSN=w.SSN AND p.PNo=w.PNo AND p.PName="IOT";

-- Find the sum of the salaries of all employees of the ‘Accounts’ department, 
-- as well as the maximum salary, the minimum salary, and the average salary in this department
SELECT SUM(salary) AS sal_sum, MAX(salary) AS sal_max, MIN(salary) AS sal_min, AVG(salary) AS sal_avg
FROM employee e, department d
WHERE e.DNo=d.DNo AND d.DName="Accounts";


-- Retrieve the name of each employee who works on all the projects controlled by department number 1 (use NOT EXISTS operator).
SELECT e.SSN, e.Name, e.DNo FROM employee e WHERE NOT EXISTS 
    (SELECT PNo FROM project p WHERE p.DNo=1 AND PNo NOT IN 
    	(SELECT PNo FROM works_on w where w.SSN=e.SSN)); 


-- For each department that has more than one employee, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000.

SELECT d.DNo, COUNT(*) AS employees_earning_more_than_600000
FROM department d, employee e
WHERE d.DNo=e.DNo AND e.salary > 600000
GROUP BY d.DNo
HAVING COUNT(*) > 1;

-- Create a view that shows name, dept name and location of all employees
CREATE VIEW emp_details AS
SELECT e.Name, d.DName, dl.Dloc
FROM employee e, department d, dlocation dl
WHERE e.DNo=d.DNo AND d.DNo=dl.DNo;

SELECT * FROM emp_details;

-- Create a trigger that prevents a project from being deleted if it is currently being worked by any employee.

DELIMITER //
CREATE TRIGGER prevent_delete
BEFORE DELETE ON project
FOR EACH ROW
BEGIN
	IF EXISTS (SELECT * FROM works_on WHERE PNo=OLD.PNo) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'project is currently being worked on hence, cannot be deleted';
	END IF;
END;//
DELIMITER ; //

DELETE FROM project where PNo=03; -- Will give error 

