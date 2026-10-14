--Tatibay Miras
DROP SCHEMA IF EXISTS lab5 CASCADE;
DROP SCHEMA IF EXISTS ecommerce_lab5 CASCADE;
CREATE SCHEMA lab5;
CREATE SCHEMA ecommerce_lab5;
SET search_path TO lab5;

--Part 1: CHECK Constraints
-- 1.1 Basic CHECK Constraint
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65), --это у нас ограничения, то есть возраст только между 18 и 65
    salary NUMERIC CHECK (salary > 0) -- только больше нуля
);

-- 1.2 Named CHECK Constraint
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND discount_price > 0 AND discount_price < regular_price
    )--проверяет чтоб скидка была положительной и чтоб не превышал обычную цену
);

-- 1.3 Multiple Column CHECK
-- может сравнивать два столбца однйо строки
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,

    CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

--1.4 Testing CHECK Constraints
--1   2 correct data
INSERT INTO employees
VALUES (1, 'Alex', 'Smith', 25, 300000);

INSERT INTO employees
VALUES (2, 'John', 'Brown', 35, 450000);
--Обе записи добавятся, потому что возраст от 18 до 65 и зарплата больше 0

--2 incorrect data
-- ERROR: Age must be between 18 and 65
-- INSERT INTO employees
-- VALUES (3, 'Anna', 'White', 16, 250000);

-- ERROR: Salary must be greater than 0
-- INSERT INTO employees
-- VALUES (4, 'Bob', 'Green', 30, -1000);


--correct data for products_catalog
INSERT INTO products_catalog VALUES
(1, 'Laptop', 500000, 450000),
(2, 'Phone', 300000, 250000);

--incorrect data for products_catalog
-- ERROR: regular_price must be greater than 0
-- INSERT INTO products_catalog VALUES (3, 'Mouse', -5000, 3000);
-- ERROR: discount_price must be greater than 0
-- INSERT INTO products_catalog VALUES (4, 'Keyboard', 20000, 0);
-- ERROR: discount_price must be less than regular_price
-- INSERT INTO products_catalog VALUES (5, 'Monitor', 70000, 80000);
-- All three cases violate valid_discount.

--correct data for bookings
INSERT INTO bookings VALUES
(1, '2026-10-15', '2026-10-18', 2),
(2, '2026-10-20', '2026-10-25', 5);

--incorrect data for bookings
-- ERROR: Number of guests must be between 1 and 10
-- INSERT INTO bookings VALUES (3, '2026-10-15', '2026-10-18', 15);
-- ERROR: Check-out date must be after check-in date
-- INSERT INTO bookings VALUES (4, '2026-10-20', '2026-10-18', 2);


--------------------------------------------------------------------------------------------------------


-- Part 2: NOT NULL Constraints
-- 2.1 NOT NULL Implementation
-- Only phone is nullable
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- 2.2: Combining Constraints
-- Combine required columns with CHECK conditions
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- 2.3: Testing NOT NULL
-- Complete rows and legal NULL in a nullable column
--correct data
INSERT INTO customers
VALUES (1, 'alex@gmail.com', NULL, '2026-10-13');

INSERT INTO customers
VALUES (2, 'john@gmail.com', '87001234567', '2026-10-13');

INSERT INTO inventory
VALUES (1, 'Laptop', 10, 350000, '2026-10-13 14:30:00');

INSERT INTO inventory
VALUES (2, 'Mouse', 0, 5000, '2026-10-13 15:00:00');

--incorrect data
-- ERROR: customer_id cannot be NULL
-- INSERT INTO customers
-- VALUES (NULL, 'anna@gmail.com', '87001112233', '2026-10-13');

-- ERROR: email cannot be NULL
-- INSERT INTO customers
-- VALUES (3, NULL, '87001112233', '2026-10-13');

-- ERROR: item_name cannot be NULL
-- INSERT INTO inventory
-- VALUES (3, NULL, 5, 1000, '2026-10-13 16:00:00');

-- ERROR: unit_price cannot be NULL
-- INSERT INTO inventory
-- VALUES (4, 'Keyboard', 5, NULL, '2026-10-13 16:00:00');


-- ERROR: registration_date cannot be NULL
-- INSERT INTO customers VALUES (3, 'new@gmail.com', NULL, NULL);
-- ERROR: item_id cannot be NULL
-- INSERT INTO inventory VALUES (NULL, 'Chair', 5, 1000, '2026-10-13 16:00:00');
-- ERROR: quantity cannot be NULL
-- INSERT INTO inventory VALUES (5, 'Desk', NULL, 20000, '2026-10-13 16:00:00');
-- ERROR: last_updated cannot be NULL
-- INSERT INTO inventory VALUES (6, 'Lamp', 2, 3000, NULL);
-- ERROR: quantity must be non-negative
-- INSERT INTO inventory VALUES (7, 'Mousepad', -1, 1000, '2026-10-13 16:00:00');
-- ERROR: unit_price must be greater than 0
-- INSERT INTO inventory VALUES (8, 'Cable', 3, 0, '2026-10-13 16:00:00');


--------------------------------------------------------------------------------------------------------


-- Part 3: UNIQUE Constraints
-- 3.1: Single Column UNIQUE
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE, --не должен повторяться
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

-- 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,

    UNIQUE (student_id, course_code, semester)
);

--correct data
INSERT INTO course_enrollments
VALUES (1, 101, 'Python', 'Fall2026');

INSERT INTO course_enrollments
VALUES (2, 101, 'SQL', 'Fall2026');

INSERT INTO course_enrollments
VALUES (3, 101, 'Python', 'Spring2027');

--incorrect data
-- INSERT INTO course_enrollments
-- VALUES (4, 101, 'Python', 'Fall2026');

-- 3.3 — Named UNIQUE Constraints
--эти двое удаляет ограничения если они есть
ALTER TABLE users
DROP CONSTRAINT IF EXISTS users_username_key;

ALTER TABLE users
DROP CONSTRAINT IF EXISTS users_email_key;

--а эти двое дают ограничения
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES
(1, 'Alex', 'alex@gmail.com', '2026-10-13 10:00:00'),
(2, 'John', 'john@gmail.com', '2026-10-13 11:00:00');

-- ERROR: Duplicate username
-- INSERT INTO users
-- VALUES (4, 'Alex', 'alex2@gmail.com', '2026-10-13 13:00:00');

-- ERROR: Duplicate email
-- INSERT INTO users
-- VALUES (5, 'Mike', 'alex@gmail.com', '2026-10-13 14:00:00');


--------------------------------------------------------------------------------------------------------


-- Part 4: PRIMARY KEY Constraints
-- 4.1: Single Column Primary Key
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
--correct data
INSERT INTO departments VALUES
(1, 'IT', 'Almaty'),
(2, 'HR', 'Astana'),
(3, 'Finance', 'Shymkent');

--incorrect data
--Expected ERROR: duplicate primary key 1.
-- INSERT INTO departments VALUES (1, 'Sales', 'Almaty');
-- Expected ERROR: primary key cannot be NULL.
-- INSERT INTO departments VALUES (NULL, 'Sales', 'Almaty');

-- 4.2: Composite Primary Key
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,

    PRIMARY KEY (student_id, course_id)
);
--correct data
INSERT INTO student_courses VALUES
(100, 10, '2026-09-01', 'A'),
(100, 11, '2026-09-01', 'B'),
(101, 10, '2026-09-01', 'A');
--incorrect data
-- Expected ERROR: repeated composite primary key (100, 10).
-- INSERT INTO student_courses VALUES (100, 10, '2026-09-02', 'C');

-- 4.3: Comparison exercise
-- UNIQUE prevents duplicate *non-NULL* values; PostgreSQL UNIQUE normally permits
-- multiple NULL values. PRIMARY KEY also prevents NULLs and identifies each row.
-- Single-column PK: choose when one value uniquely identifies a row (dept_id).
-- Composite PK: choose when only a combination uniquely identifies a row
-- (student_id, course_id).
-- A table has one logical PRIMARY KEY (possibly multiple columns), which defines
-- its primary row identity; multiple UNIQUE constraints can enforce extra business
-- rules on other columns or column combinations.


--------------------------------------------------------------------------------------------------------


-- PART 5: FOREIGN KEY CONSTRAINTS
-- 5.1: Basic Foreign Key
-- Сотрудники ссылаются на существующие отделы
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id), --ID отдела должен существовать в departments
    hire_date DATE
);
INSERT INTO employees_dept VALUES
(1, 'Alex', 1, '2026-01-15'),
(2, 'Dana', 2, '2026-03-20');

-- Expected ERROR: department 999 does not exist.
-- INSERT INTO employees_dept VALUES (3, 'Sam', 999, '2026-04-01');


-- 5.2: Library schema with two foreign keys in books.
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
INSERT INTO authors VALUES
(1, 'Abai Qunanbaiuly', 'Kazakhstan'),
(2, 'George Orwell', 'United Kingdom');

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
INSERT INTO publishers VALUES
(1, 'Arman', 'Almaty'),
(2, 'Penguin', 'London');

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id), --Книга должна ссылаться на существующего автора.
    publisher_id INTEGER REFERENCES publishers(publisher_id),--Книга должна ссылаться на существующее издательство.
    publication_year INTEGER,
    isbn TEXT UNIQUE -- уникальный идентификатор издания книги, который не должен повторяться.
);
INSERT INTO books VALUES
(1, 'Book of Words', 1, 1, 2020, 'ISBN-001'),
(2, '1984', 2, 2, 1949, 'ISBN-002');


-- Expected ERROR: author_id=999 absent from authors.
-- INSERT INTO books VALUES (3, 'Unknown', 999, 1, 2021, 'ISBN-003');
-- Expected ERROR: ISBN-001 already exists (books.isbn UNIQUE).
-- INSERT INTO books VALUES (4, 'Duplicate ISBN', 1, 1, 2022, 'ISBN-001');

-- 5.3: ON DELETE Options
-- RESTRICT блокирует удаление родительской записи; CASCADE удаляет дочерние строки.
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER
        REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories
VALUES (1, 'Electronics');
INSERT INTO products_fk
VALUES (1, 'Laptop', 1);
-- DELETE FROM categories
-- WHERE category_id = 1;

INSERT INTO orders
VALUES (1, '2026-10-13');
INSERT INTO order_items
VALUES (1, 1, 1, 2);
BEGIN;
DELETE FROM orders
WHERE order_id = 1;

SELECT * FROM orders;
SELECT * FROM order_items;
ROLLBACK;

-- Task 5.3: Test Results

-- RESTRICT:
-- Cannot delete a category if it has products.
-- PostgreSQL returns a foreign key error.

-- CASCADE:
-- When an order is deleted, its order_items
-- are automatically deleted.

-- The product itself is not deleted.


--------------------------------------------------------------------------------------------------------


-- PART 6: E-COMMERCE DATABASE
-- 6.1: E-commerce Database Design
SET search_path TO ecommerce_lab5;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL
        CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL
        CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (
        status IN (
            'pending',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    )
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    product_id INTEGER NOT NULL
        REFERENCES products(product_id)
        ON DELETE RESTRICT,
    quantity INTEGER NOT NULL
        CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL
        CHECK (unit_price >= 0)
);

-- Five valid sample records per table.
INSERT INTO customers VALUES
(1, 'Alex', 'alex@gmail.com', '87001111111', '2026-10-01'),
(2, 'John', 'john@gmail.com', '87002222222', '2026-10-02'),
(3, 'Anna', 'anna@gmail.com', '87003333333', '2026-10-03'),
(4, 'Mike', 'mike@gmail.com', '87004444444', '2026-10-04'),
(5, 'Sara', 'sara@gmail.com', NULL, '2026-10-05');

INSERT INTO products VALUES
(1, 'Laptop', 'Gaming laptop', 500000, 10),
(2, 'Mouse', 'Wireless mouse', 5000, 50),
(3, 'Keyboard', 'Mechanical keyboard', 20000, 30),
(4, 'Monitor', '24-inch monitor', 80000, 15),
(5, 'Headphones', 'Bluetooth headphones', 15000, 25);

INSERT INTO orders VALUES
(1, 1, '2026-10-06', 500000, 'pending'),
(2, 2, '2026-10-07', 10000, 'processing'),
(3, 3, '2026-10-08', 20000, 'shipped'),
(4, 4, '2026-10-09', 80000, 'delivered'),
(5, 5, '2026-10-10', 30000, 'cancelled');

INSERT INTO order_details VALUES
(1, 1, 1, 1, 500000),
(2, 2, 2, 2, 5000),
(3, 3, 3, 1, 20000),
(4, 4, 4, 1, 80000),
(5, 5, 5, 2, 15000);

-- ERROR: Duplicate customer_id
-- INSERT INTO customers
-- VALUES (1, 'Bob', 'bob@gmail.com', NULL, '2026-10-11');

-- ERROR: Duplicate email
-- INSERT INTO customers
-- VALUES (6, 'Bob', 'alex@gmail.com', NULL, '2026-10-11');

-- ERROR: Customer name cannot be NULL
-- INSERT INTO customers
-- VALUES (6, NULL, 'bob@gmail.com', NULL, '2026-10-11');

-- ERROR: Price cannot be negative
-- INSERT INTO products
-- VALUES (6, 'Tablet', 'New tablet', -1000, 5);

-- ERROR: Stock quantity cannot be negative
-- INSERT INTO products VALUES (7, 'Cable', 'USB cable', 1000, -2);
-- ERROR: Total amount cannot be negative
-- INSERT INTO orders VALUES (7, 1, '2026-10-11', -1, 'pending');
-- ERROR: Unit price cannot be negative
-- INSERT INTO order_details VALUES (7, 1, 2, 1, -500);

-- ERROR: Invalid order status
-- INSERT INTO orders
-- VALUES (6, 1, '2026-10-11', 5000, 'unknown');

-- ERROR: Customer 99 does not exist
-- INSERT INTO orders
-- VALUES (6, 99, '2026-10-11', 5000, 'pending');

-- ERROR: Quantity must be positive
-- INSERT INTO order_details
-- VALUES (6, 1, 2, -3, 5000);

-- ERROR: Customer 1 has an order
-- DELETE FROM customers
-- WHERE customer_id = 1;

-- ON DELETE CASCADE test
BEGIN;
DELETE FROM orders
WHERE order_id = 5;
SELECT * FROM order_details WHERE order_id = 5;
-- Expected result: 0 rows; related order_details are deleted.
ROLLBACK;

SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_details_count FROM order_details;
-- Expected result: 5 rows in each table.
