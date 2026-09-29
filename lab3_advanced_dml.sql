--PART A
-- 1
CREATE DATABASE advanced_lab;

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY ,
    first_name VARCHAR(30) NOT NULL ,
    last_name VARCHAR(30) NOT NULL ,
    department VARCHAR(30) ,
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(30) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

--PART B
--2
INSERT INTO employees(first_name, last_name, department)
VALUES ('miras', 'tatibay', 'IT');

--3
INSERT INTO employees(first_name, last_name, salary, status)
VALUES ('daryn', 'tatibay', DEFAULT, DEFAULT);

--4
INSERT INTO departments(dept_name, budget, manager_id)
VALUES ('IT', 20000, 1),
       ('manager',15000, 2 ),
       ('hr', 25000, 3);

--5
INSERT INTO employees(first_name, last_name, department, salary, hire_date)
VALUES ('jon', 'harris', 'IT', 50000*1.1, CURRENT_DATE);

--6
CREATE TEMP TABLE temp_employees AS SELECT * FROM employees WHERE 1=0;
INSERT INTO temp_employees
SELECT * FROM employees WHERE department = 'IT';

--PART C
--7
UPDATE employees SET salary=salary*1.10;

--8
UPDATE employees SET status='Senior' WHERE salary>60000 AND hire_date<'2020-01-01';

--9
UPDATE employees
SET department= CASE
    WHEN salary>80000 THEN  'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'JUNIOR'
END;

--10
UPDATE employees SET department=DEFAULT WHERE status='Inactive';

--11
UPDATE departments SET budget=(
SELECT AVG(salary)*1.20
FROM employees
WHERE employees.department=departments.dept_name )

WHERE EXISTS(
    SELECT 1 FROM employees
             WHERE employees.department=departments.dept_name
);

--12
UPDATE employees
SET salary=salary*1.15,
    status='Promoted'
WHERE department='Sales';

--PART D
--13
DELETE FROM employees WHERE status='Terminated';

--14
DELETE FROM employees WHERE salary<40000
                        AND hire_date>'2023-01-01'
                        AND department IS NULL;

--15
DELETE FROM departments WHERE dept_id NOT IN (
    SELECT DISTINCT department FROM employees
                               WHERE department IS NOT NULL
    );

--16
DELETE FROM projects WHERE end_date<'2023-01-01'
RETURNING *;

--PART E
--17
INSERT INTO employees(FIRST_NAME, LAST_NAME, DEPARTMENT, salary)
VALUES ('baan', 'dovin', NULL, NULL);

--18
UPDATE employees SET department='Unassigned' WHERE department IS NULL;

--19
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

--PART F
--20
INSERT INTO employees(first_name, last_name, department, salary)
VALUES ('Brus', 'benner', 'IT', 50000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

--21
UPDATE employees SET salary=salary-5000 WHERE department='IT'
RETURNING emp_id, (salary-5000) AS old_salary, salary AS new_salary;

--22
DELETE FROM employees WHERE hire_date<'2020-01-01'
RETURNING *;

--PART G
--23
INSERT INTO employees(FIRST_NAME, LAST_NAME, DEPARTMENT, SALARY)
SELECT 'angelina', 'jony', 'management', 90000
WHERE NOT EXISTS(
    SELECT 1 FROM employees
        WHERE first_name='angelina' AND last_name='jony'
);

--24
UPDATE employees
SET salary=CASE
    WHEN ( SELECT budget FROM departments WHERE departments.dept_name=employees=department)>100000
        THEN salary*1.10
    ELSE salary*1.05
END
WHERE department IS NOT NULL;

--25
INSERT INTO employees(first_name, last_name, department, salary)
values('fn1', 'ln1', 'sales', 35000),
      ('fn2', 'ln2', 'management', 39000),
      ('fn3', 'ln3', 'it', 32000),
      ('fn4', 'ln4', 'sales', 42000),
      ('fn5', 'ln5', 'sales', 36000);

--26
create table employee_archive(like employees including all);
insert into employee_archive select * from employees where status='Inactive';
delete
from employees
where status='Inactive';

--27
UPDATE projects
SET end_date=end_date+30
WHERE budget>50000
    AND dept_id IN(
        SELECT dept_id
        FROM departments
        JOIN employees ON departments.dept_id=employees.department
        GROUP BY dept_id
        HAVING count(*)>3
    );