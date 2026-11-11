Drop table if exists employees cascade ;
Drop table if exists departments cascade ;
Drop table if exists projects cascade ;
-- Create table: employees
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);
-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000);
--Part 2
--2.1
Create view employee_details as
SELECT
    e.emp_name,e.salary,d.dept_name,d.location
from employees e
inner join departments d
on e.dept_id=d.dept_id;

SELECT * FROM employee_details;

--2.2
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;

--2.3
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
         JOIN departments d
              ON p.dept_id = d.dept_id
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_name,
    d.location;

SELECT * FROM project_overview;

--2.4
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;

--Part 3
--3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
        END AS salary_grade
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

--3.2
ALTER VIEW high_earners
RENAME TO top_performers;

SELECT * FROM top_performers;

--3.3
CREATE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;
DROP VIEW temp_view;

--Part 4
--4.1
CREATE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;

SELECT * FROM employee_salaries;

--4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT *
FROM employees
WHERE emp_name = 'John Smith';

--4.3
INSERT INTO employee_salaries
(emp_id, emp_name, dept_id, salary)
VALUES
    (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees
WHERE emp_name = 'Alice Johnson';

--4.4
CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;

SELECT * FROM it_employees;

--Part 5
--5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,

    (SELECT COUNT(*)
     FROM employees e
     WHERE e.dept_id = d.dept_id) AS total_employees,

    COALESCE(
            (SELECT SUM(e.salary)
             FROM employees e
             WHERE e.dept_id = d.dept_id), 0
    ) AS total_salaries,

    (SELECT COUNT(*)
     FROM projects p
     WHERE p.dept_id = d.dept_id) AS total_projects,

    COALESCE(
            (SELECT SUM(p.budget)
             FROM projects p
             WHERE p.dept_id = d.dept_id), 0
    ) AS total_project_budget

FROM departments d
WITH DATA;

SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

--5.2
INSERT INTO employees
(emp_id, emp_name, dept_id, salary)
VALUES
    (8, 'Charlie Brown', 101, 54000);

SELECT *
FROM dept_summary_mv;

REFRESH MATERIALIZED VIEW dept_summary_mv;
--5.3
CREATE UNIQUE INDEX dept_summary_idx
    ON dept_summary_mv(dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

--5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM projects p
         JOIN departments d
              ON p.dept_id = d.dept_id
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_name
WITH NO DATA;

REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;

--Part 6
--6.1
CREATE ROLE analyst;

CREATE ROLE data_viewer
    WITH LOGIN PASSWORD 'viewer123';

CREATE USER report_user
    WITH PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';

--6.2
CREATE ROLE db_creator
    WITH LOGIN CREATEDB PASSWORD 'creator789';

CREATE ROLE user_manager
    WITH LOGIN CREATEROLE PASSWORD 'manager101';

CREATE ROLE admin_user
    WITH LOGIN SUPERUSER PASSWORD 'admin999';

--6.3
GRANT SELECT
    ON employees, departments, projects
    TO analyst;

GRANT ALL PRIVILEGES
    ON employee_details
    TO data_viewer;

GRANT SELECT, INSERT
    ON employees
    TO report_user;

--6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 PASSWORD 'hr001';
CREATE USER hr_user2 PASSWORD 'hr002';
CREATE USER finance_user1 PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;

GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE
    ON employees
    TO hr_team;

GRANT SELECT
    ON dept_statistics
    TO finance_team;

--6.5
REVOKE UPDATE
    ON employees
    FROM hr_team;

REVOKE hr_team
    FROM hr_user2;

REVOKE ALL PRIVILEGES
    ON employee_details
    FROM data_viewer;
--6.6
ALTER ROLE analyst
    WITH LOGIN PASSWORD 'analyst123';

ALTER ROLE user_manager
    WITH SUPERUSER;

ALTER ROLE analyst
    PASSWORD NULL;

ALTER ROLE data_viewer
    CONNECTION LIMIT 5;

--Part 7
--7.1
-- Create parent role
drop role if exists read_only cascad;

CREATE ROLE read_only;

-- Grant SELECT on all tables in public schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

-- Create child roles
CREATE ROLE junior_analyst
    WITH LOGIN PASSWORD 'junior123';

CREATE ROLE senior_analyst
    WITH LOGIN PASSWORD 'senior123';

-- Grant parent role to child roles
GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

-- Grant additional privileges to senior analyst
GRANT INSERT, UPDATE ON employees TO senior_analyst;
--7.2
-- Create project manager role
CREATE ROLE project_manager
    WITH LOGIN PASSWORD 'pm123';

-- Transfer ownership of the view
    ALTER VIEW dept_statistics
    OWNER TO project_manager;

-- Transfer ownership of the table
ALTER TABLE projects
    OWNER TO project_manager;

-- Check table ownership
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

--7.3
-- Create temporary owner
CREATE ROLE temp_owner WITH LOGIN;

-- Create table
CREATE TABLE temp_table (
                            id INT
);

-- Transfer ownership
ALTER TABLE temp_table
    OWNER TO temp_owner;

-- Reassign all owned objects to postgres
REASSIGN OWNED BY temp_owner TO postgres;

-- Drop remaining privileges and objects
DROP OWNED BY temp_owner;

-- Drop role
DROP ROLE temp_owner;
--7.4
-- Create HR employee view
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

-- Grant SELECT to HR team
GRANT SELECT ON hr_employee_view TO hr_team;

-- Create Finance employee view
CREATE VIEW finance_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary
FROM employees;

-- Grant SELECT to Finance team
GRANT SELECT ON finance_employee_view TO finance_team;

--Part 8
--8.1
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,

    COUNT(DISTINCT e.emp_id) AS employee_count,

    ROUND(AVG(e.salary), 2) AS average_salary,

    COUNT(DISTINCT p.project_id) AS active_projects,

    COALESCE(SUM(DISTINCT p.budget), 0) AS total_project_budget,

    ROUND(
            COALESCE(SUM(DISTINCT p.budget), 0)::numeric
                / NULLIF(COUNT(DISTINCT e.emp_id), 0),
            2
    ) AS budget_per_employee

FROM departments d
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
         LEFT JOIN projects p
                   ON d.dept_id = p.dept_id

GROUP BY d.dept_id, d.dept_name, d.location;

SELECT * FROM dept_dashboard;

--8.2
-- Add created_date column
ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Create high budget projects view
CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,

    CASE
        WHEN p.budget > 150000
            THEN 'Critical Review Required'
        WHEN p.budget > 100000
            THEN 'Management Approval Needed'
        ELSE 'Standard Process'
        END AS approval_status

FROM projects p
         JOIN departments d
              ON p.dept_id = d.dept_id

WHERE p.budget > 75000;
--8.3
-- Level 1: Viewer Role
CREATE ROLE viewer_role;

GRANT SELECT
    ON ALL TABLES IN SCHEMA public
    TO viewer_role;


-- Level 2: Entry Role
CREATE ROLE entry_role;

GRANT viewer_role TO entry_role;

GRANT INSERT
    ON employees, projects
    TO entry_role;


-- Level 3: Analyst Role
CREATE ROLE analyst_role;

GRANT entry_role TO analyst_role;

GRANT UPDATE
    ON employees, projects
    TO analyst_role;


-- Level 4: Manager Role
CREATE ROLE manager_role;

GRANT analyst_role TO manager_role;

GRANT DELETE
    ON employees, projects
    TO manager_role;


-- Create users
CREATE USER alice WITH PASSWORD 'alice123';

CREATE USER bob WITH PASSWORD 'bob123';

CREATE USER charlie WITH PASSWORD 'charlie123';


-- Assign roles to users
GRANT viewer_role TO alice;

GRANT analyst_role TO bob;

GRANT manager_role TO charlie;

