-- Sailors Database

DROP DATABASE IF EXISTS sailors_46;

CREATE DATABASE sailors_46;

USE sailors_46;

CREATE TABLE IF NOT EXISTS sailors(
    sid INT PRIMARY KEY,
    sname VARCHAR(100) NOT NULL,
    rating FLOAT,
    age INT
);

CREATE TABLE IF NOT EXISTS boats(
    bid INT PRIMARY KEY,
    bname VARCHAR(100) NOT NULL,
    color VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS reserves(
    sid INT,
    bid INT,
    reservation_date DATE,
    FOREIGN KEY (sid) REFERENCES sailors(sid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (bid) REFERENCES boats(bid) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO sailors VALUES
(1, "Albert", 8.0, 23),
(2, "sailor2", 9.1, 40),
(3, "sailor3", 6.3, 13),
(4, "sailor4", 7.4, 67),
(5, "sailor5", 8.7, 60);
    
SELECT * FROM sailors;

INSERT INTO boats VALUES
(101,"eye of the storm","red"),
(102,"boat2","green"),
(103,"boat3","blue"),
(104,"boat4","violet"),
(105,"boat5","black");

SELECT * FROM boats;

INSERT INTO reserves VALUES
(1, 101, "2023-09-26"),
(2, 101, "2023-09-27"),
(2, 102, "2023-09-27"),
(2, 103, "2023-09-27"),
(2, 104, "2023-09-27"),
(2, 105, "2023-09-27"),
(3, 103, "2023-09-28"),
(4, 104, "2023-09-29"),
(5, 105, "2023-09-30");

SELECT * FROM reserves;

-- 1. Find the colors of boats reserved by Albert.
SELECT DISTINCT b.color
FROM sailors s
NATURAL JOIN reserves r NATURAL JOIN boats b
WHERE s.sname = "Albert";

-- 2. Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103:
(SELECT s.sid
FROM sailors s
WHERE s.rating >= 8)
UNION
(SELECT r.sid
FROM reserves r
WHERE r.bid = 103);

 
-- 3. Find the names of sailors who have not reserved a boat whose name contains the string “storm”. Order the names in ascending order:

SELECT s.sname
FROM sailors s
WHERE s.sid NOT IN (
    SELECT r.sid
    FROM sailors s1, reserves r, boats b
    WHERE s.sid=r.sid AND b.bid=r.bid AND b.bname LIKE '%storm%'
)
ORDER BY s.sname ASC;

-- 4. Find the names of sailors who have reserved all boats.

SELECT s.sname from sailors s WHERE NOT EXISTS -- All reserved boats selected by one sailor
	(SELECT * FROM boats b WHERE NOT EXISTS -- All unreserved boats
		(SELECT * FROM reserves r WHERE s.sid=r.sid AND b.bid=r.bid));


-- 5. Find the name and age of the oldest sailor:

SELECT s.sname, s.age
FROM sailors s
WHERE s.age = (SELECT MAX(s.age) FROM sailors s);

-- 6. For each boat which was reserved by at least 2 sailors with age >= 40, find the boat id and the average age of such sailors:

SELECT r.bid, AVG(s.age) AS average_age
FROM sailors s, reserves r
WHERE s.sid=r.sid AND s.age >= 40
GROUP BY r.bid
HAVING COUNT(DISTINCT r.sid) >= 2;

-- View that shows the names and colors of all the boats reserved by a sailor with a specific rating
CREATE VIEW reserved_boats_by_rating AS
SELECT DISTINCT b.bname, b.color
FROM sailors s
NATURAL JOIN reserves r NATURAL JOIN boats b
WHERE s.rating = 8.0;

SELECT * FROM reserved_boats_by_rating;

-- Trigger that prevents boat from being deleted if the boat has reservations

DELIMITER //
CREATE TRIGGER boat_delete_trigger
BEFORE DELETE ON boats
FOR EACH ROW
BEGIN
    IF EXISTS(Select r.bid from reserves r WHERE r.bid = OLD.bid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Cannot delete boat since it is reserved";
    END IF;
END;//

DELIMITER ;

DELETE FROM boats WHERE bid = 101;