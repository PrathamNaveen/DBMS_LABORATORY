-- Student Enrollment Database

DROP DATABASE IF EXISTS student_enrollment_46;

CREATE DATABASE IF NOT EXISTS student_enrollment_46;

USE student_enrollment_46;

CREATE TABLE IF NOT EXISTS student (
    regno VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    major VARCHAR(100) NOT NULL,
    bdate DATE
);

CREATE TABLE IF NOT EXISTS course(
    course_no INT PRIMARY KEY,
    cname VARCHAR(100) NOT NULL,
    dept VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS enroll(
    regno VARCHAR(100),
    course_no INT,
    sem INT NOT NULL,
    marks INT,
    FOREIGN KEY (regno) REFERENCES student(regno) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_no) REFERENCES course(course_no) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS text(
    book_ISBN INT PRIMARY KEY,
    book_title VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    author VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS book_adoption(
    course_no INT,
    sem INT,
    book_ISBN INT,
    FOREIGN KEY (course_no) REFERENCES course(course_no) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_ISBN) REFERENCES text(book_ISBN) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO student VALUES
("CS001", "student_1", "CS", "2003-05-15"),
("BS001", "student_2", "dept_2", "2003-06-15"),
("DS001", "student_3", "dept_3", "2003-07-15"),
("HS001", "student_4", "dept_4", "2003-08-15"),
("PS001", "student_5", "dept_5", "2003-09-15");

SELECT * FROM student;

INSERT INTO course VALUES
(01, "DBMS", "CS"),
(02, "course_2", "dept_2"),
(03, "course_3", "dept_3"),
(04, "course_4", "dept_4"),
(05, "course_5", "dept_5");

SELECT * FROM course;

INSERT INTO enroll VALUES
("CS001", 01, 5, 85),
("BS001", 02, 5, 87),
("DS001", 03, 3, 95),
("HS001", 04, 3, 80),
("PS001", 05, 5, 75);

SELECT * FROM enroll;

INSERT INTO text VALUES
(1, "Databases Made Easy", "Pearson", "Shakespeare"),
(2, "text_2", "publisher_2", "Ionosphere"),
(3, "text_3", "publisher_3", "Tropsphere"),
(4, "text_4", "publisher_4", "Stratosphere"),
(5, "text_5", "publisher_5", "Exosphere");

SELECT * FROM text;

INSERT INTO book_adoption VALUES
(01, 5, 1),
(02, 5, 2),
(03, 3, 3),
(04, 3, 4),
(05, 5, 5);

SELECT * FROM book_adoption;

-- demonstrate how you add a new text book to the database and make this book be adopted by some department

INSERT INTO text VALUES (6, "Query Like a God", "publisher_6", "Mesosphere");
INSERT INTO book_adoption VALUES (01, 5, 6);

-- produce a list of textbooks include course# Book-ISBN, Book-title in the alphabetical order for courses offered by department CS that use more than 2 books

SELECT ba.course_no, ba.book_ISBN, t.book_title
FROM book_adoption ba, text t, course c
WHERE c.course_no=ba.course_no AND t.book_ISBN=ba.book_ISBN AND c.dept = "CS"
GROUP BY ba.course_no, ba.book_ISBN, t.book_title
HAVING COUNT(ba.book_ISBN) > 0;

-- list any department that has all its adopted books published by a specific publisher

SELECT c.dept
FROM course c
NATURAL JOIN book_adoption ba 
NATURAL JOIN text t 
GROUP BY dept
HAVING COUNT(DISTINCT publisher) = 1;

-- list the students who have scored maximum marks in dbms course

SELECT s.name
FROM student s, course c, enroll e
WHERE s.regno=e.regno AND e.course_no=c.course_no AND c.cname = "DBMS"
AND e.marks IN (SELECT MAX(marks) FROM enroll e1, course c1 WHERE  c1.course_no=e1.course_no AND c1.cname = "DBMS");


-- create a view to display all the courses opted by a student along with the marks obtained

CREATE VIEW student_course_marks AS
SELECT course_no, marks
FROM enroll;

SELECT * FROM student_course_marks
-- trigger that prevents a student from enrolling in a course if the marks prerequisite course is less than 40

DELIMITER //
CREATE TRIGGER check_marks
BEFORE INSERT ON enroll
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Marks should be greater than 40';
    END IF;
END;//
DELIMITER ; //

INSERT INTO enroll VALUES  ("JS001", 01, 3, 35);
