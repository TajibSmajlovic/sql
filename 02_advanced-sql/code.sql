-- GROUP BY
SELECT b.dept_name, count(a.emp_no) FROM dept_emp AS a
INNER JOIN departments AS b
ON a.dept_no = b.dept_no
GROUP BY b.dept_name

-- HAVING
SELECT b.dept_name AS "Department name", 
       count(a.emp_no) AS "No. of employees"
FROM dept_emp AS a
INNER JOIN departments AS b
ON a.dept_no = b.dept_no
INNER JOIN employees AS c
ON c.emp_no = a.emp_no
WHERE c.gender = 'F'
GROUP BY b.dept_name
HAVING count( a.emp_no ) > 25000
----
SELECT b.dept_name AS "Department name", 
       count(a.emp_no) AS "No. of employees",
       c.gender AS "Gender"
FROM dept_emp AS a
INNER JOIN departments AS b
ON a.dept_no = b.dept_no
INNER JOIN employees AS c
ON c.emp_no = a.emp_no
GROUP BY b.dept_name, c.gender
ORDER BY count(a.emp_no) -- ORDERING 

-- UNION
SELECT NULL AS "Product Id", sum(ol.quantity)
FROM orderlines AS ol
UNION --
SELECT prod_id AS "Product Id", sum(ol.quantity)
FROM orderlines AS ol
GROUP BY "Product Id"
ORDER BY "Product Id" DESC

-- GROUPING SETS
SELECT prod_id AS "Product Id", 
       orderlineid,
       sum (ol.quantity)
FROM orderlines AS ol
GROUP BY 
    GROUPING SETS (
        (),
        (prod_id),
        (orderlineid)
    )
ORDER BY "Product Id" DESC, orderlineid DESC

-- ROLLUP
SELECT EXTRACT (YEAR FROM orderdate) AS "year",
       EXTRACT (MONTH FROM orderdate) AS "month",
       EXTRACT (DAY FROM orderdate) AS "day",
       sum(quantity)
FROM orderlines
GROUP BY
    ROLLUP (
       EXTRACT (YEAR FROM orderdate),
       EXTRACT (MONTH FROM orderdate),
       EXTRACT (DAY FROM orderdate)
    )
ORDER BY
       EXTRACT (YEAR FROM orderdate),
       EXTRACT (MONTH FROM orderdate),
       EXTRACT (DAY FROM orderdate)

----
SELECT e.hire_date, count(e.emp_no)
FROM employees AS e
GROUP BY e.hire_date
----
SELECT e.emp_no,
concat(e.first_name, e.last_name) AS "Name",
       count(t.title) AS "Amount of titles"
FROM employees AS e
INNER JOIN titles AS t USING(emp_no)
WHERE EXTRACT (YEAR FROM e.hire_date) > '1991'
GROUP BY e.emp_no
ORDER BY e.emp_no
----
SELECT e.emp_no, concat(e.first_name, ' ', e.last_name) AS "Name"
FROM employees AS e
JOIN salaries AS s USING(emp_no)
JOIN dept_emp AS de USING(emp_no)
WHERE de.dept_no = 'd005'
GROUP BY e.emp_no
ORDER BY e.emp_no;
----
SELECT dept.dept_name, round(avg(s.salary)) AS "Average Salary"
FROM employees AS e
INNER JOIN salaries AS s USING(emp_no)
INNER JOIN dept_emp AS d USING(emp_no)
INNER JOIN departments AS dept 
ON dept.dept_no = d.dept_no
GROUP BY dept.dept_name

-- WINDOW FUNCTION 
SELECT *, max(salary) OVER()
FROM salaries
----
SELECT e.emp_no, 
        concat(e.first_name, ' ', e.last_name) AS "Name",
        d.dept_name,
        avg(s.salary) OVER(
            PARTITION BY d.dept_name
        )
FROM employees AS e
JOIN salaries AS s USING(emp_no)
JOIN dept_emp AS de USING(emp_no)
JOIN departments AS d USING(dept_no)
----
SELECT emp_no, 
        count(salary) OVER(
            ORDER BY emp_no
        )
FROM salaries
----
SELECT emp_no, 
        count(salary) OVER(
            PARTITION BY emp_no
            ORDER BY salary
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
            -- partition by emp_no
            -- ROWS between UNBOUNDED PRECEDING and CURRENT ROW
        )
FROM salaries

-- SOLVING CURRENT SALARY
SELECT DISTINCT
        s.emp_no,
        last_value(salary) OVER(
            PARTITION BY s.emp_no
            ORDER BY s.from_date
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )
FROM salaries AS s
JOIN dept_emp AS de USING(emp_no)

--
SELECT
    prod_id,
    price,
    category,
    max(price) OVER(PARTITION BY category) AS "most expensive in category"
FROM products

--
SELECT 
    o.orderid,
    o.customerid,
    o.netamount,
    sum(o.netamount) OVER(
        PARTITION BY o.customerid
        ORDER BY o.orderid
    ) AS "cumulative sum"
FROM orders AS o
ORDER BY o.customerid

--
SELECT DISTINCT continent,
       sum(population) OVER(
        PARTITION BY continent
       )
FROM country
---
SELECT DISTINCT continent,
       sum(population) OVER w1
FROM country
WINDOW w1 AS(PARTITION BY continent)

--
SELECT 
    DISTINCT continent,
    sum(population) OVER w1,
    round(
        (
            sum(population::float4) OVER w1 / 
            sum(population::float4) OVER ()
        ) * 100
         )
FROM country
WINDOW w1 AS(PARTITION BY continent)

--
SELECT 
DISTINCT r.id, 
r."name", 
COUNT(t.id) OVER (
    PARTITION BY r.id
    ORDER BY r."name"
) AS "# of towns"
FROM regions AS r
JOIN departments AS d ON r.code = d.region 
JOIN towns AS t ON d.code = t.department
ORDER BY r.id;

-- CONDITIONALS (CASE STATEMENT)
SELECT
    sum( 
        CASE
            WHEN o.netamount < 100
            THEN -100
            ELSE o.netamount
        END
    ) AS "return",
    sum( o.netamount ) AS "normal total"
FROM orders AS o
----
SELECT title, price,
    CASE
        WHEN price > 20 THEN 'expensive'
        WHEN price > 10 THEN 'average'
        ELSE 'cheap'
    END
FROM products

-- NULLIF
SELECT title, special,
    NULLIF(special, 0)
FROM products

-- VIEW
CREATE OR REPLACE VIEW last_salary_change AS
SELECT e.emp_no,
       max(s.from_date)
FROM salaries AS s
JOIN employees AS e USING(emp_no)
JOIN dept_emp AS de USING(emp_no)
JOIN departments AS d USING(dept_no)
GROUP BY e.emp_no
ORDER BY e.emp_no

SELECT ls.*, s.salary 
FROM last_salary_change AS ls
JOIN salaries AS s USING(emp_no)
WHERE ls.max = s.to_date
ORDER BY ls.emp_no

----
CREATE OR REPLACE VIEW "90-95" AS
SELECT * FROM employees
WHERE 
    EXTRACT (YEAR FROM hire_date) BETWEEN 1990 AND 1995
ORDER BY hire_date

SELECT * FROM "90-95"

----
CREATE VIEW "bigbucks" AS
SELECT 
    concat(e.first_name, ' ', e.last_name) AS "Employee name",
    s.salary AS "Salary"
FROM employees AS e
JOIN salaries AS s USING(emp_no)
WHERE s.salary > 80000
ORDER BY s.salary DESC

SELECT * FROM "bigbucks"

-- INDEXES

-- create INDEX idx_countrycode
-- on city (countrycode)

CREATE INDEX idx_countrycode
ON city (countrycode) WHERE countrycode IN ('TUN', 'BE', 'NL') -- B-tree is default algorithm (best used for comparison '<,>, IN, IS NULL, etc...)

EXPLAIN ANALYZE
SELECT "name", district, countrycode FROM city
WHERE countrycode IN ('TUN', 'BE', 'NL') 

CREATE INDEX idx_countrycode
ON city USING hash (countrycode) -- hash algorithm (best used for equality '=')

EXPLAIN ANALYZE
SELECT "name", district, countrycode FROM city
WHERE countrycode = 'TUN' AND countrycode = 'BE'

-- SUBQUERY
SELECT title, price, (SELECT avg( price ) FROM products) AS "global average price"
FROM (
    SELECT * FROM products WHERE price < 10
) AS "products_subq"

----
SELECT * FROM employees
WHERE age(birth_date) > (
    SELECT avg(age(birth_date)) 
    FROM employees
    WHERE gender = 'M'
)

----
SELECT 
    emp_no,
    salary,
    from_date,
    (SELECT title FROM titles AS t
     WHERE t.emp_no = s.emp_no AND
        t.from_date = s.from_date
    )
FROM salaries AS s
ORDER BY emp_no  

SELECT 
    emp_no,
    salary,
    from_date,
    t.title
FROM salaries AS s
JOIN titles AS t USING(emp_no, from_date)
ORDER BY emp_no  

----
SELECT 
    emp_no,
    salary AS "most recent salary",
    from_date
FROM salaries AS s
WHERE from_date = (
    SELECT max(from_date) 
    FROM salaries AS sp
    WHERE sp.emp_no = s.emp_no
)
ORDER BY emp_no
    
SELECT 
    emp_no,
    salary AS "most recent salary",
    from_date
FROM salaries AS s
JOIN (
    SELECT emp_no, max(from_date) AS "max"
    FROM salaries AS sp
    GROUP BY emp_no
) AS ls USING(emp_no)
WHERE ls.max = from_date
ORDER BY emp_no

--
SELECT * FROM orders AS o, (SELECT customerid, state FROM customers) AS c
WHERE  o.customerid = c.customerid AND 
c.state IN ('NY', 'OH', 'OR')

--
SELECT emp_no, first_name, last_name
FROM employees
WHERE emp_no IN (
    SELECT emp_no
    FROM dept_emp
    WHERE dept_no = (
        SELECT dept_no 
        FROM dept_manager
        WHERE emp_no = 110183
    )
)
ORDER BY emp_no

-- Written with JOIN
SELECT e.emp_no, first_name, last_name
FROM employees AS e
JOIN dept_emp AS de USING (emp_no)
JOIN dept_manager AS dm USING (dept_no)
WHERE dm.emp_no = 110183