DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;

-- Create tables
CREATE TABLE employees (
employee_id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
department VARCHAR(50),
salary NUMERIC(10,2),
hire_date DATE,
manager_id INTEGER,
email VARCHAR(100)
);

CREATE TABLE projects (
project_id SERIAL PRIMARY KEY,
project_name VARCHAR(100),
budget NUMERIC(12,2),
start_date DATE,
end_date DATE,
status VARCHAR(20)
);

CREATE TABLE assignments (
assignment_id SERIAL PRIMARY KEY,
employee_id INTEGER REFERENCES employees(employee_id),
project_id INTEGER REFERENCES projects(project_id),
hours_worked NUMERIC(5,1),
assignment_date DATE
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

--part 1
--1.1
select
    first_name || ' ' || last_name as full_name,
    department,
    salary
from employees;

--1.2
select distinct department
from employees;

--1.3
select
    project_name, budget, case
        when budget>150000 then 'Large'
        when budget between 100000 and 150000 then 'Medium'
        else 'Small'
    end as budget_category
from projects;

--1.4
select
    first_name || ' ' || last_name as full_name,
    coalesce(email, 'No email provided') as email
from employees;

--part 2
--2.1
select * from employees where hire_date>'2020-01-01';

--2.2
select * from employees where salary between 60000 and 70000;

--2.3
select * from employees where last_name like 'S%' or last_name like 'J%';

--2.4
select * from employees where manager_id is not null and department='IT';

--part 3
--3.1
select
    upper(first_name || ' ' || last_name) as upper_full_name,
    length(last_name) as last_name_length,
    substring(email from 1 for 3) as email_prefix
from employees;

--3.2
select
    first_name || ' ' || last_name as employee_name,
    salary as annual_salary,
    round(salary / 12.0, 2) as monthly_salary,
    round(salary * 0.10, 2) as raise_amount
from employees;

--3.3
select
    format('Project: %s Budget: $%s Status: %s', project_name, budget, status) as project_info
from projects;

--3.4
select
    first_name || ' ' || last_name as employee_name,
    hire_date,
    extract(year from age(current_time, hire_date)) as years_with_company
--  ивзлекает год, считывает разницу
from employees;

--part 4
--4.1
select
    department,
    avg(salary) AS avg_salary
from employees
group by department; --так как использован агрегатная функция авг

--4.2
--вычисляет суммарное количество часов отработанных над каждым проектом
select
    projects.project_name,
    sum(assignments.hours_worked) as total_hours
from projects
join assignments on projects.project_id = assignments.project_id
group by projects.project_id, projects.project_name;

--4.3
select
    department,
    count(*) as employee_count
from employees
group by department
having count(*) > 1;

--4.4
select
    max(salary) as max_salary,
    min(salary) as min_salary,
    sum(salary) as total_payroll
from employees;

--part 5
--5.1
select employee_id, first_name || ' ' || last_name as full_name, salary
from employees
where salary > 65000
union --типо склеивает
select employee_id, first_name || ' ' || last_name as full_name, salary
from employees
where hire_date > '2020-01-01';

--5.2
select employee_id, first_name || ' ' || last_name as full_name, salary
from employees
where department = 'IT'
intersect --обычное пересечение или же and, то что есть в обоих
select employee_id, first_name || ' ' || last_name as full_name, salary
from employees
where salary > 65000;

--5.3
select employee_id, first_name || ' ' || last_name as full_name
from employees
except --берёт список из первого и удаляет из него все строки, которые встретились во втором
select e.employee_id, e.first_name || ' ' || e.last_name as full_name
from employees
join assignments on employees.employee_id = assignments.employee_id;

--part 6
--6.1 у которого есть хотябы одна задача
select employees.employee_id, employees.last_name, employees.first_name
from employees
where exists(
    select 1
    from assignments
    where employees.employee_id=assignments.employee_id
);

--6.2 сотрудник работающий над активным проектом
select *
from employees
where employee_id in (
    select assignments.employee_id
    from assignments
    join projects on assignments.project_id = projects.project_id
    where projects.status = 'Active'
);

--6.3 Сотрудники чья зарплата выше чем у ЛЮБОГО сотрудника отдела продаж.
select *
from employees
where salary > any (
    select salary
    from employees
    where department = 'Sales'
);

--part 7
--7.1
select
    e.first_name || ' ' || e.last_name as full_name,
    e.department,
    avg(a.hours_worked) as avg_hours_worked,
    dense_rank() over (partition by e.department order by e.salary desc) as salary_rank
from employees e
left join assignments a on e.employee_id=a.employee_id -- гарантия что в отчет попадет все сотрудник
group by e.employee_id, e.first_name, e.last_name, e.department, e.salary;

--7.2 Проекты в которых общее количество отработанных часов больше 150
select
    p.project_name,
    sum(a.hours_worked) as total_hours,
    count(distinct a.employee_id) as assigned_employees_count
from projects p --p у нас аллиас
join assignments a on p.project_id = a.project_id
group by p.project_id, p.project_name
having sum(a.hours_worked) > 150;

--7.3
WITH highest_paid AS (
    SELECT DISTINCT ON (department)
        department,
        first_name || ' ' || last_name AS highest_paid_employee
    FROM employees
    ORDER BY department, salary DESC, employee_id
)
select
    e.department,
    count(*) as total_employees,
    avg(e.salary) as avg_salary, --можно навсякий в round взятб
    hp.highest_paid_employee,
    greatest(round(avg(e.salary), 2), 50000) as salary_floor_check,
    least(max(e.salary), 100000) as capped_max_salary
from employees e
join highest_paid hp on e.department = hp.department
group by e.department, hp.highest_paid_employee;