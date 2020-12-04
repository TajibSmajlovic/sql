SELECT * FROM departments

SELECT * FROM salaries
WHERE emp_no = 10001

SELECT emp_no AS "Employee #", birth_date AS "Kad si rodjen", first_name AS "Kako se zoves boudalo" FROM employees

/*
 * Multi 
 * line
 * comments
 */

-- Concatinating column 
SELECT emp_no, 
       concat(first_name, ' ', last_name ) AS "Ime i prezime" 
FROM employees

-- Agregate functions 
SELECT count(*) FROM departments
SELECT count(*) FROM employees
SELECT max(salary) AS "Najveca plata" FROM salaries
SELECT sum(salary) FROM salaries

-- Filtering data
SELECT * FROM employees
WHERE gender = 'F'

-- AND and OR keyword
SELECT count(*) FROM customers
WHERE gender = 'F' 
AND (state = 'OR' OR state = 'NY')

-- NOT keyword
SELECT count(*) FROM customers
WHERE NOT age = 55 AND NOT age = 20
// 0 !> 1

-- IS keyword
SELECT * FROM customers
WHERE age IS NULL

-- COALESCE
SELECT COALESCE(age, 0) AS "ages" FROM customers

-- BETWEEN AND
SELECT age FROM customers
WHERE age BETWEEN 10 AND 20

-- IN
SELECT * FROM customers
WHERE age IN(40, 50)

-- LIKE and ILIKE
SELECT firstname FROM customers
WHERE firstname LIKE 'M%'

SELECT firstname FROM customers
WHERE firstname LIKE 'M___PT'

SELECT age FROM customers -- Or use CAST (CAST(age as TEXT))
WHERE age::TEXT LIKE '_7'

SELECT firstname FROM customers
WHERE firstname ILIKE 'm%n'

-- DATE
SHOW timezone
SET TIME ZONE 'utc'
SELECT now()

ALTER USER postgres SET timezone = 'UTC'

SELECT to_char(CURRENT_DATE, 'dd-mm-yyyy') AS "datum"

SELECT date '2/5/1990'

SELECT now() - '2/5/1990'

SELECT age(date '7/6/1985')
SELECT age(date '7/6/1985', date '12/7/1967')

--- EXTRACK
SELECT EXTRACT (DAY FROM date '1995/12/3')
SELECT EXTRACT (MONTH FROM date '1995/12/3')
SELECT EXTRACT (YEAR FROM date '1995/12/3')

SELECT birth_date FROM employees
WHERE (
   EXTRACT (YEAR FROM AGE(birth_date))
) > 60 ;

SELECT hire_date FROM employees
WHERE (EXTRACT (MONTH FROM hire_date)) = 2

SELECT max(age(hire_date)) FROM employees

--- DATE_TRUNC
SELECT date_trunc('year', date '1995/12/3')
SELECT date_trunc('month', date '1995/12/3')
SELECT date_trunc('day', date '1995/12/3')

SELECT COUNT(orderid) FROM orders
WHERE DATE_TRUNC('month', orderdate) = date '2004-01-01';

--- INTERVAL
SELECT * FROM orders
WHERE purchase_date <= now() - INTERVAL '30 days' -- years, months, days, hours, minutes

SELECT EXTRACT (YEAR FROM INTERVAL '6 years 24 months')

-- DISTINCT
SELECT DISTINCT age FROM employees

-- ORDER BY
SELECT * FROM employees
ORDER BY first_name DESC, last_name ASC
LIMIT 50

SELECT * FROM employees
ORDER BY length(first_name) DESC

-- MULTI TABLE SELECT
SELECT e.first_name, s.salary
FROM employees AS e, salaries AS s
WHERE e.emp_no = s.emp_no
ORDER BY s.salary DESC
LIMIT 10

-- INNER JOIN
SELECT e.emp_no, e.first_name, 
       s.salary, t.title, 
       t.from_date
       FROM employees AS e
INNER JOIN salaries AS s
    ON e.emp_no = s.emp_no
INNER JOIN titles AS t 
    ON e.emp_no = t.emp_no 
AND(
    s.from_date = t.from_date
    OR (s.from_date + INTERVAL '2 days') = t.from_date
   )
ORDER BY emp_no
LIMIT 50

-- SELF JOIN
SELECT a.id, a.name AS "employee",
       b.name AS "supervisor"
FROM employees AS a, employees AS b
WHERE a.supervisorId = b.id

-- OUTER JOIN
SELECT count(*)
FROM employees AS emp
LEFT JOIN dept_manager AS dep
ON emp.emp_no = dep.emp_no
WHERE dep.emp_no IS NULL

SELECT e.emp_no, e.first_name, 
       s.salary, t.from_date,
       COALESCE(t.title, 'No title change')
       FROM employees AS e
INNER JOIN salaries AS s
    ON e.emp_no = s.emp_no
LEFT JOIN titles AS t 
    ON e.emp_no = t.emp_no 
AND(
    s.from_date = t.from_date
    OR (s.from_date + INTERVAL '2 days') = t.from_date
   )
ORDER BY emp_no

-- USING
SELECT count(*)
FROM employees AS emp
LEFT JOIN dept_manager AS dep
USING(emp_no)
WHERE dep.emp_no IS NULL