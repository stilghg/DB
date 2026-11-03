CREATE TABLE IF NOT EXISTS departments (
    dept_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    budget NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS instructors (
    instr_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    dept_id INT REFERENCES departments,
    manager_id INT REFERENCES instructors,
    salary NUMERIC(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS courses (
    course_id SERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    dept_id INT NOT NULL REFERENCES departments,
    credits INT NOT NULL
);

CREATE TABLE IF NOT EXISTS prerequisites (
    course_id INT REFERENCES courses,
    prereq_id INT REFERENCES courses,
    PRIMARY KEY (course_id, prereq_id)
);

CREATE TABLE IF NOT EXISTS students (
    student_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    advisor_id INT REFERENCES instructors
);

CREATE TABLE IF NOT EXISTS sections (
    section_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL REFERENCES courses,
    instr_id INT REFERENCES instructors,
    semester TEXT NOT NULL,
    starts_on DATE NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE IF NOT EXISTS enrollments (
    student_id INT REFERENCES students,
    section_id INT REFERENCES sections,
    score NUMERIC(5,2),
    PRIMARY KEY (student_id, section_id)
);

CREATE TABLE IF NOT EXISTS grade_scale (
    letter TEXT PRIMARY KEY,
    min_score NUMERIC(5,2) NOT NULL,
    max_score NUMERIC(5,2) NOT NULL
);