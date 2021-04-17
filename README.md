# Employee Database with SQL
## Overview
### *Purpose*
Pewlett Hackard, a large company, was looking to determine who will be retiring in the next few years and how many positions will need to be filled. Pewlitt Hackard additionally required a list of all employees eligible for the retirement package. 

## Resources
-	Software: PostgreSQL 13, pgAdmin 4

## Analysis
### *Create ERDs*
To create ERDs of the six CSV files from Pewlett Hackard, I used Quick DBD. 

### *Create a Database*
Using pdAdmin, I created a new database named PH-EmployeeDB.

### *Create Tables in SQL*
In my Query Editor, I inputted the following code to create six new tables corresponding to my six CSV files:
```
-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
	dept_no VARCHAR(4) NOT NULL, 
	dept_name VARCHAR(40) NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE (dept_name)
);

CREATE TABLE employees (
emp_no INT NOT NULL,
    	birth_date DATE NOT NULL,
    	first_name VARCHAR NOT NULL,
   	last_name VARCHAR NOT NULL,
   	gender VARCHAR NOT NULL,
   	hire_date DATE NOT NULL,
    	PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
    	emp_no INT NOT NULL,
    	from_date DATE NOT NULL,
    	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  	emp_no INT NOT NULL,
  	salary INT NOT NULL,
  	from_date DATE NOT NULL,
  	to_date DATE NOT NULL,
 	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
 	PRIMARY KEY (emp_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL, 
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL, 
	title VARCHAR NOT NULL, 
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);
```

### *Import Data*
Once the tables were created, I imported the correct CSV file to each table. 

### *Query Dates*
#### Determine Retirement Eligibility
It was determined that anyone born between 1952 and 1955 would be eligible to retire. Thus, I wrote a query to return a list of employees born between those years:
```
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';
```
The output produced a list of over 10,000 employees. This list was further refined to look at employees born in 1952:
```
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';
```
Three more queries were created to search for employees born in 1953, 1954, and 1955:
```
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';
```
Each query still produced a large list of employees ready to retire and so the query was further refined to narrow the list. Using the original query, a condition was added that looked for employees born between 1952 and 1955 who were also hired between 1985 and 1988:
```
-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
```
Then, I used the COUNT function to determine the length of the query:
```
-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
```
The count of the query was 41,380. 

#### Create New Tables
To create a new table with all of the employees eligible for retirement, I edited my query with the two conditions, adding a new line with “INTO retirement_info” to save the query into a new table:
```
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
```
After the retirement_info table was created, I exported it as a csv file.

### *Join the Tables*
The list of employees eligible for retirement needed to be further broken down into departments. To get this information, I needed to join the dept_emp and the employees table on the emp_no column. However, as the employees table contained all employees and not just those eligible for retirement and the retirement_info table did not include the emp_no column, I first needed to recreate the retirement_info table to include the emp_no column. To recreate the retirement_info table, I first dropped the original table:
```
DROP TABLE retirement_info;
```
Then I updated the code to create the retirement_info table with the emp_no column:
```
-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;
```
It was apparent that some of the employees within the retirement_info may not currently work for the company, and thus I needed to determine whether an employee within the table was still employed with Pewlett Hackard. To do this, I used a LEFT JOIN to join every row in the retirement_info table with the to_date column within the dept_emp table:
```
-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no,
ri.first_name,
ri.last_name,
de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
```

### *Use Count, Group By, and Order By*
After creating the current_emp table, I created a query to join the current_emp and dept_emp tables to get the number of employees by department number. A LEFT JOIN was used to ensure all employee numbers were included. The COUNT function was used on the emp_no to get the number of employees and the GROUP BY was added to group by dept_no. I additionally added an ORDER BY statement to organize the table by department number:
```
-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO emp_dept_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
```
The query produced a new table, emp_dept_count, which I exported to a CSV file.

### *Create Additional Lists*
Due to the number of people leaving each department, three additional lists were requested:
1.	Employee Information: A list of employees containing their unique employee number, their last name, first name, gender, and salary
2.	Management: A list of managers for each department, including the department number, name, and the manager's employee number, last name, first name, and the starting and ending employment dates
3.	Department Retirees: An updated current_emp list that includes everything it currently has, but also the employee's departments

#### Employee Information
To create the employee information table, I needed the employee number, first name, last name, gender, to_date, and salary. The employees table contained most of this information, while the salary table contained the salary information and to_date. To make sure the to_date column within the salary table aligned with the employment date, I created the following query:
```
SELECT * FROM salaries
ORDER BY to_date DESC;
```
The dates did not appear to be the most recent date of employment and were assumed to relate to salary instead. Thus, I also needed to use the dept_emp table to retrieve the to_date. 

The employee information table needed to only contain employees eligible for retirement, and thus I refactored my previous code for filtering the employees table, adding gender to my SELECT statement and updating the INTO portion to save the table into a new table emp_info. The code was additionally refactored to perform an inner join of the employees table with the salaries table, as well as with the dept_emp table. At the end of the code I added a final filter for the to_date:
```
SELECT e.emp_no,
e.first_name,
e.last_name,
e.gender,
s.salary,
de.to_date
INTO emp_info
FROM employees as e 
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	 AND (de.to_date = '9999-01-01');
```

#### Management
The management table required the manager’s employee number, department number, department name, first name, last name, and their starting and ending employment dates. The information required to make this table was located within the departments, dept_manager, and employees tables. To get just those retiring, I used the current_emp table instead of the employees table. To join these three tables, I used the following code:
```
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
INNER JOIN departments AS d
ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp AS ce
ON (dm.emp_no = ce.emp_no);
```

#### Department Retirees
To make the department retirees table, the current_emp list needed to be updated with the employee’s department by using an inner join on the current_emp, departments, and dept_emp tables for the columns emp_no, first_name, last_name, and dept_name:
```
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);
```

### *Create a Tailored List*
The department head for Sales asked for a list of employees retiring within their department. To make a table of just the sales department, I used the same code as was used to create the dept_info table, adding a WHERE statement to filter the dept_name to just ‘Sales’:
```
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO sales_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales';
```
The same manager asking for a list of retiring employees asked for a list of employees in both the Sales and Development departments for their new mentoring program for employees getting ready to retire. Using the same code as above, adding an IN condition to my WHERE statement to find rows where dept_name is ‘Sales’ or ‘Development’, I created a new table named sales_dev_info:
```
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO sales_dev_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales', 'Development');
```

# Challenge
## Overview
### *Purpose*
The manager at Pewlett Hackard additionally asked me to determine the number of retiring employees per title and identify the employees who are eligible to participate in a mentorship program. They will use this information to prepare for the “silver tsunami” as many current employees reach retirement age.

## Analysis
### *The Number of Retiring Employees by Title*
A Retirement Titles table needed to be created that included all the titles of the current employees who were born between January 1st, 1952 and December 31st, 1955. So, I created a query to retrieve the emp_no, first_name, and last_name columns from the employees table, as well as the title, from_date, and to_date columns from the titles table. Using the INTO clause I created a new table named retirement_titles. The employees and titles tables were joined on emp_no using an inner join. The data was filtered on the birth_date column to retrieve the employees born between 1952 and 1955 and then ordered by emp_no:
```
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
```
Once the table was created, it was apparent that it contained duplicate entries of some employees due to changes in their titles over the years. To remove these duplicates and only keep the most recent title of each employee, I used the DISTINCT ON statement to retrieve the first occurrence of the employee number for each set of rows in the emp_no, first_name, last_name, and title columns defined by the ON() clause. A unique_titles table was created using the INTO clause and sorted in ascending order by emp_no and in descending order by to_date:
```
-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (r.emp_no) r.emp_no,
r.first_name,
r.last_name,
r.title
INTO unique_titles
FROM retirement_titles as r
ORDER BY emp_no, to_date DESC;
```
To retrieve the number of employees by their most recent job title who are about to retire, I input a query that retrieved the title column and the count of the emp_no column from the unique_titles table to get the number of titles, creating a new retiring_titles table to hold the information. Then, I grouped the table by title using the GROUP BY statement and sorted the count column in descending order:
```
-- Employee count by title
SELECT COUNT(ut.emp_no), ut.title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY ut.title
ORDER BY COUNT(ut.emp_no) DESC;
```

![retiring_titles.png](https://github.com/kcharb7/Pewlett-Hackard-Analysis/blob/main/Images/retiring_titles.png)

Once the retiring_titles table was created, I used the SUM() function in the SELECT statement to get the total number of employees eligible for retirement:
```
-- Determine sum of all employees ready for retirement
SELECT SUM(count) AS total
FROM retiring_titles
```

![total_retirees.png](https://github.com/kcharb7/Pewlett-Hackard-Analysis/blob/main/Images/total_retirees.png)


### *The Employees Eligible for the Mentorship Program*
To create a Mentorship Eligibility table that holds the employees who are eligible to participate in a mentorship program, I created a query to retrieve the emp_no, first_name, last_name, and birth_date columns from the employees table, the from_date and to_date columns from the dept_emp table, as well as the title column from the titles table. I used the DISTINCT ON statement to retrieve the first occurrence of the employee number for each set of rows defined by the ON() clause, then used the INTO clause to create a new table named mentorship_eligibility. The employees and dept_emp tables were joined on the emp_no using an inner join, as was the employees and titles tables. The date was additionally filtered on the birth_date column to get employees born between January 1st, 1965 and December 31st, 1965 and on the to-date column to get current employees. Finally, the table was ordered by emp_no:
```
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
```
![mentorship_eligibility.png](https://github.com/kcharb7/Pewlett-Hackard-Analysis/blob/main/Images/mentorship_eligibility.png)

Once the mentorship_eligibility table was created, I used the COUNT() function to determine how many employees were eligible for the mentorship program:
```
SELECT COUNT(*) FROM mentorship_eligibility
```

![total_mentors.png](https://github.com/kcharb7/Pewlett-Hackard-Analysis/blob/main/Images/total_mentors.png)


### *Results*

-	90,398 employees were eligible for retirement
-	The title with the highest number of employees eligible for retirement were Senior Engineers at 29,414 employees
-	Only two managers were eligible for retirement
-	1,549 employees were eligible to participate in the mentorship program
-	Looking at the first 10 employees in the mentorship_eligibility table, it is apparent that most hold a senior title

### *Summary*
1.	How many roles will need to be filled as the “silver tsunami” begins to make an impact?
-  90,398 positions will need to be filled as the “silver tsunami” begins to make an impact
2. Are there enough qualified, retirement-ready employees in the departments to mentor the next generation of Pewlett Hackard employees?
- As only 1.7% of employees were eligible for the mentorship program out of all employees eligible for retirement, there are not enough qualified employees to mentor new employees coming in. This is further supported with an additional query that determined the number of employees eligible for the mentorship program by title:
```
SELECT COUNT(me.emp_no), me.title
FROM mentorship_eligibility as me
GROUP BY me.title
ORDER BY COUNT(me.emp_no) DESC;
```

![mentors_title.png](https://github.com/kcharb7/Pewlett-Hackard-Analysis/blob/main/Images/mentors_title.png)

As shown in the table, only 0.6% of senior engineers, 1.3% of staff, 1.7% of technique leaders, 2.0% of senior staff, 3.5% of engineers, and 4.4% of assistant engineers retiring were eligible to be mentors.  
