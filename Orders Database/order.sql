-- Orders Database

DROP DATABASE IF EXISTS order_processing_46;

CREATE DATABASE order_processing_46;

USE order_processing_46;

CREATE TABLE IF NOT EXISTS customer(
    cust_no INT PRIMARY KEY,
    cname VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS order_(
    order_no INT PRIMARY KEY,
    odate DATE NOT NULL,
    cust_no INT NOT NULL,
    order_amt INT,
    FOREIGN KEY (cust_no) REFERENCES customer(cust_no) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS item(
    item_no INT PRIMARY KEY,
    unitprice INT NOT NULL
);

CREATE TABLE IF NOT EXISTS order_item(
    order_no INT,
    item_no INT,
    qty INT NOT NULL,
    FOREIGN KEY (order_no) REFERENCES order_(order_no) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (item_no) REFERENCES item(item_no) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS warehouse(
    warehouse_no INT PRIMARY KEY,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS shipment(
    order_no INT,
    warehouse_no INT,
    ship_date DATE NOT NULL,
    FOREIGN KEY (order_no) REFERENCES order_(order_no) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (warehouse_no) REFERENCES warehouse(warehouse_no) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO customer VALUES
(0001, "Kumar", "Mysuru"),
(0002, "customer_2", "Bengaluru"),
(0003, "customer_3", "Mumbai"),
(0004, "customer_4", "Dehli"),
(0005, "customer_5", "Bengaluru");

SELECT * FROM customer;

INSERT INTO order_ VALUES
(001, "2020-01-11", 0001, 200),
(002, "2020-02-12", 0002, 500),
(003, "2020-03-13", 0003, 100),
(004, "2020-04-14", 0004, 700),
(005, "2020-05-15", 0005, 100);

SELECT * FROM order_;

INSERT INTO item VALUES
(01, 200),
(02, 400),
(03, 600),
(04, 100),
(05, 700);

SELECT * FROM item;

INSERT INTO warehouse VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

SELECT * FROM warehouse;

INSERT INTO order_item VALUES 
(001, 01, 5),
(002, 02, 1),
(003, 03, 5),
(004, 04, 1),
(005, 05, 12);

SELECT * FROM order_item;

INSERT INTO shipment VALUES
(001, 0001, "2020-01-14"),
(002, 0002, "2020-02-16"),
(003, 0003, "2020-03-18"),
(004, 0004, "2020-04-20"),
(005, 0005, "2020-05-23");

SELECT * FROM shipment;

-- List the Order# and Ship Date for all orders shipped from Warehouse 0002.

SELECT order_no, ship_date
FROM shipment
WHERE warehouse_no = 0002;

-- List the warehouse information from which the customer named "Kumar" was supplied with his orders.Produce a listing of order#,warehouse#

SELECT order_no, warehouse_no
FROM shipment
WHERE order_no in (
    SELECT order_no
    FROM order_
    WHERE cust_no in (
        SELECT cust_no
        FROM customer
        WHERE cname = "Kumar"
    )
);

-- Mine

SELECT s.order_no, s.warehouse_no
FROM customer c, shipment s, order_ o
WHERE o.order_no=s.order_no AND c.cust_no=o.order_no AND c.cname="Kumar";


-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total
-- number of orders by the customer and the last column is the average order amount for that
-- customer. (Use aggregate functions)

SELECT cname, COUNT(order_no) AS Number_of_orders, AVG(order_amt) AS Avg_Order_Amt 
FROM customer c, order_ o
WHERE c.cust_no=o.cust_no
GROUP BY c.cust_no;


-- DELETE ALL ORDERS FROM CUSTOMER named kumar

DELETE FROM order_
WHERE cust_no IN (
	SELECT cust_no
    FROM customer c
    WHERE cname="Kumar"
);

-- FIND the item with the maximum unit price

SELECT *
FROM item
WHERE unitprice = (
    SELECT MAX(unitprice)
    FROM item
);


-- A trigger that updates order_amount based on quantity and unit price of order-item
DELIMITER //
CREATE TRIGGER UpdateOrderAmt
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
	UPDATE order_ SET order_amt=(NEW.qty * (SELECT DISTINCT unitprice FROM item NATURAL JOIN order_item WHERE item_no=NEW.item_no)) WHERE order_.order_no=NEW.order_no;
END;//
DELIMITER ; //

SELECT * FROM order_;
SELECT * FROM item;
SELECT * FROM order_item;

INSERT INTO order_item VALUES
(003, 04, 2);

SELECT * FROM order_;

-- View to display the orderid and ship_date for all orders shipped from warehouse 0002
CREATE View order_shipment AS
SELECT order_no, ship_date
FROM shipment
WHERE warehouse_no = 0002;

SELECT * FROM order_shipment;