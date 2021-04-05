-- Create Retirement Title table from employees and titles tables
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	ti.from_date,
	ti.to_date
INTO retirement_titles
FROM employees as e
INNER JOIN titles as ti
ON e.emp_no = ti.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY emp_no;

-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (r.emp_no) r.emp_no,
r.first_name,
r.last_name,
r.title
INTO unique_titles
FROM retirement_titles as r
ORDER BY emp_no, to_date DESC;

-- Employee count by title
SELECT COUNT(ut.emp_no), ut.title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY ut.title
ORDER BY COUNT(ut.emp_no) DESC;

-- Determine sum of all employees ready for retirement
SELECT SUM(count) AS total
FROM retiring_titles

-- Create Mentorship Eligibility Table
SELECT DISTINCT ON (e.emp_no) e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	de.from_date,
	de.to_date,
	ti.title
INTO mentorship_eligibility
FROM employees as e
INNER JOIN dept_emp as de
ON e.emp_no = de.emp_no
INNER JOIN titles as ti
ON e.emp_no = ti.emp_no
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	AND de.to_date = ('9999-01-01')
ORDER BY emp_no;

-- Determine the number of employees eligible for mentorship
SELECT COUNT(*) FROM mentorship_eligibility

-- Employee count by title
SELECT COUNT(me.emp_no), me.title
FROM mentorship_eligibility as me
GROUP BY me.title
ORDER BY COUNT(me.emp_no) DESC;