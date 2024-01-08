-- Insurance Database

DROP TABLE IF EXISTS insurance_46;

CREATE DATABASE insurance_46;

USE insurance_46;

CREATE TABLE IF NOT EXISTS person (
    driver_id VARCHAR(100) PRIMARY KEY,
    driver_name VARCHAR(100) NOT NULL,
    address VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS car (
    regno VARCHAR(100) PRIMARY KEY,
    model VARCHAR(100) NOT NULL ,
    year INT
);

CREATE TABLE IF NOT EXISTS accident(
    report_number INT PRIMARY KEY,
    acc_date DATE,
    location VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS owns(
    driver_id VARCHAR(100),
    regno VARCHAR(100),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (regno) REFERENCES car(regno) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS participated(
    driver_id VARCHAR(100),
    regno VARCHAR(100),
    report_number INT,
    damage_amount INT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)  ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (regno) REFERENCES car(regno) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO person VALUES
("d001", "Smith", "Kuvempunagar, Mysuru"),
("d002", "driver_2", "JP Nagar, Mysuru"),
("d003", "driver_3", "Jayanagar, Mysuru"),
("d004", "driver_4", "Rajivnagar, Mysuru"),
("d005", "driver_5", "Vijayanagar, Mysuru");

SELECT * FROM person;

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2018),
("KA-20-BC-5674", "Mazda", 2019),
("KA-21-CD-5473", "Alto", 2020),
("KA-21-DE-4728", "Triber", 2021),
("KA-09-MA-1234", "Tiago", 2022);

SELECT * FROM car;

INSERT INTO owns VALUES
("d001", "KA-20-AB-4223"),
("d001", "KA-20-BC-5674"),
("d002", "KA-20-BC-5674"),
("d003", "KA-21-CD-5473"),
("d004", "KA-21-DE-4728"),
("d005", "KA-09-MA-1234");

SELECT * FROM owns;

DROP TABLE owns;
DROP TABLE participated;
DROP TABLE car;
DROP TABLE person;

INSERT INTO accident VALUES
(001, "2020-04-05", "Nazarbad, Mysuru"),
(002, "2020-04-06", "Gokulam, Mysuru"),
(003, "2020-04-07", "Vijaynagar, Mysuru"),
(004, "2020-04-08", "Kuvempunagar, Mysuru"),
(005, "2020-04-09", "JSS Layout, Mysuru");

SELECT * FROM accident;

INSERT INTO participated VALUES
("d001", "KA-20-BC-5674", 001, 2000),
("d002", "KA-20-BC-5674", 002, 2500),
("d003", "KA-21-CD-5473", 003, 3000),
("d004", "KA-21-DE-4728", 004, 3500),
("d005", "KA-09-MA-1234", 005, 4000);

SELECT * FROM participated;

-- 1.	Find the total number of people who owned cars that were involved in accidents in 2021.
Select COUNT(*) as total_accidents
FROM car c, accident a, participated p
WHERE a.report_number=p.report_number AND c.regno=p.regno AND c.year=2021;

-- 2. Find the number of accidents in which the cars belonging to "Smith"  were involved

Select COUNT(pt.report_number) as total_accidents
FROM person p, participated pt 
WHERE p.driver_id=pt.driver_id AND p.driver_name LIKE "%Smith%";

-- 3. Add a new accident to the database; assume any values for required attributes.

INSERT INTO accident VALUES (006, "2023-12-30", "Mysore");

-- 4. Delete the MAZDA belonging to "Smith".

DELETE FROM car c WHERE regno IN (SELECT o.regno FROM person p, owns o WHERE p.driver_id=o.driver_id AND p.driver_name like "%Smith%" AND c.model = "Mazda");

-- 5. Update the damage amount for the car with license number "KA09MA1234" in the accident with report

UPDATE participated SET damage_amount = 100000 WHERE regno = "KA-09-MA-1234";

-- View that shows models and year of cars that are involved in accident

CREATE VIEW accident_cars AS
SELECT DISTINCT model, year
FROM car c, participated pt
WHERE c.regno=pt.regno;

SELECT * FROM accident_cars;

-- A trigger that prevents a driver from participating in more that 3 accidents a year

DELIMITER //
CREATE TRIGGER accident_limit
BEFORE INSERT on participated
FOR EACH ROW
BEGIN 
    IF ( SELECT COUNT(*) from participated pt, accident a WHERE pt.report_number=a.report_number AND pt.driver_id = NEW.driver_id AND acc_date like "2021%") >= 2
    THEN
        SIGNAL SQLSTATE '42000' SET MESSAGE_TEXT = 'Driver has exceeded accident limit';
    END IF;
END;//
DELIMITER ; //

INSERT INTO accident VALUES 
(0011, "2021-04-25", "JSSSTU, Mysuru");

INSERT INTO participated VALUES
("d001", "KA-20-AB-4223", 006, 20000);

INSERT INTO participated VALUES
("d001", "KA-20-AB-4223", 0011, 25000);
