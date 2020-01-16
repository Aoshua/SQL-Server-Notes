--Joshua Abbott
--11/05/2018

USE HR2550;

GO

PRINT '1A. Display the first name, last name, department number and department name, for all employees including those without any department.'
SELECT first_name, last_name, departments.department_id, department_name
FROM employees
	JOIN departments ON employees.department_id = departments.department_id;

PRINT '1B. With one simple change, modify your query to display all departments including departments without any employees.'
SELECT first_name, last_name, departments.department_id, department_name
FROM employees
	FULL JOIN departments ON employees.department_id = departments.department_id;

PRINT '2A. For each employee, display the last name, and the manager’s last name.'
SELECT employees.last_name AS 'Employee Last Name', emp2.last_name AS 'Manager Last Name'
FROM employees
	JOIN employees emp2 ON employees.manager_id = emp2.employee_id;

PRINT '2B. With one simple change, modify your query to display all employees including those without any manager.'
SELECT employees.last_name AS 'Employee Last Name', emp2.last_name AS 'Manager Last Name'
FROM employees
	FULL JOIN employees emp2 ON employees.manager_id = emp2.employee_id
WHERE employees.last_name IS NOT NULL;

PRINT '3. Display the first name, last name, and department number for all employees who work in the same department as employee whose last name is “King”.'
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id = 
	(SELECT department_id
	 FROM employees
	 WHERE last_name = 'King');

PRINT '4. Display the last name and salary for all employees who earn less than employee number 103.'
SELECT last_name, salary
FROM employees
WHERE salary < 
	(SELECT salary 
	 FROM employees
	 WHERE employee_id = '103');

PRINT '5. Display the first name and salary for all employees who earn more than employee number 103'
SELECT first_name, salary
FROM employees
WHERE salary > 
	(SELECT salary
	 FROM employees
	 WHERE employee_id = '103' );

PRINT '6. Display the department id and department name for all departments whose location id is equal to the location id where the department id = 9'
SELECT department_id, department_name
FROM departments 
WHERE location_id = 
	(SELECT location_id
	 FROM departments
	 WHERE department_id = 9);

PRINT '7. Display the last name and hire date for all employees who was hired after employee number 101'
SELECT last_name , hire_date
FROM employees
WHERE hire_date > 
	(SELECT hire_date
	 FROM employees
	 WHERE employee_id = '101');

PRINT '8. Display the first name, last name, and department number for all employees who work in Sales department.'
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id = 
	(SELECT department_id
	 FROM departments
	 WHERE department_name = 'Sales');

PRINT '9. Display the department number and department name for all departments located in Toronto'
SELECT department_id, department_name
FROM departments
WHERE location_id = 
	(SELECT location_id
	 FROM locations
	 WHERE city = 'Toronto');

PRINT '10. Display the first name, salary and department number for all employees who work in the department as employee number 123'
SELECT first_name, salary, department_id
FROM employees
WHERE department_id = 
	(SELECT department_id
	 FROM employees
	 WHERE employee_id = 123)
AND employee_id <> 123;

PRINT '11. Display the first name, salary, and department number for all employees who earn more than the average salary'
SELECT first_name, salary, department_id 
FROM employees
WHERE salary > 
	(SELECT AVG(salary)
	 FROM employees);

PRINT '12. Display the first name, salary, and department number for all employees whose salary equals one of the salaries in department number 11'
SELECT first_name, salary, department_id 
FROM employees
WHERE salary = ANY 
	(SELECT salary
	 FROM employees
	 WHERE department_id = 11);

PRINT '13. Display the first name, salary, and department number for all employees who earn more than maximum salary in department number 50'
SELECT first_name, salary, department_id 
FROM employees
WHERE salary > ALL
	(SELECT salary
	 FROM employees
	 WHERE department_id = 50);

SELECT department_id, department_name
from departments;

PRINT '14. Display the first name, salary, and department number for all employees who earn more than the minimum salary in department number 10'
SELECT first_name, salary, department_id 
FROM employees
WHERE salary > 
	(SELECT MIN(salary)
	 FROM employees
	 WHERE department_id = 10);

PRINT '15. Display the first name, salary, and department number for all employees who earn less than the minimum salary of department number 90'
SELECT first_name, salary, department_id 
FROM employees
WHERE salary < ALL
	(SELECT salary
	 FROM employees
	 WHERE department_id = 90);

PRINT '16. Display the first name, salary and department number for all employees whose department is located Seattle'
SELECT first_name, salary, department_id 
FROM employees
WHERE department_id = ANY 
	(SELECT department_id
	 FROM departments
		JOIN locations ON departments.location_id = locations.location_id
	 WHERE city = 'Seattle');

GO

USE ACDB;

GO 

PRINT '17A Display the first name, last name, internet speed and monthly payment for all customers. Use INNER JOIN to solve this exercise'
SELECT first_name, last_name, speed, monthly_payment
FROM customers
	INNER JOIN packages ON customers.pack_id = packages.pack_id;

PRINT '17B With one simple change, Modify last query to display all customers, including those without any internet package.'
SELECT first_name, last_name, speed, monthly_payment
FROM customers
	LEFT JOIN packages ON customers.pack_id = packages.pack_id;

PRINT '17C With one simple change, Modify last query to display all packages, including those without any customers.'
SELECT first_name, last_name, speed, monthly_payment
FROM customers
	RIGHT JOIN packages ON customers.pack_id = packages.pack_id;

PRINT '17D With one simple change, Modify last query to display all packages and all customers.'
SELECT first_name, last_name, speed, monthly_payment
FROM customers
	FULL JOIN packages ON customers.pack_id = packages.pack_id;

PRINT '18 Display the first name, monthly discount and package number for all customers whose monthly payment is greater than the average monthly payment'
SELECT first_name, monthly_discount, customers.pack_id
FROM customers JOIN packages ON customers.pack_id = packages.pack_id
WHERE monthly_payment > 
	(SELECT AVG(monthly_payment)
	 FROM packages);

PRINT '19 Display the first name, city, state, birthdate and monthly discount for all customers who was born on the same date as customer number 179, and whose monthly discount is greater than the monthly discount of customer number 107'
SELECT first_name, city, state, birth_date, monthly_discount
FROM customers
WHERE birth_date = 
	(SELECT birth_date
	 FROM customers
	 WHERE customer_id = 179)
	AND monthly_discount > 
	(SELECT monthly_discount
	 FROM customers
	 WHERE customer_id = 107);

PRINT '20 Display the first name, monthly discount, package number, main phone number and secondary phone number for all customers whose sector name is Business'
SELECT first_name, monthly_discount, customers.pack_id, main_phone_num, secondary_phone_num
FROM customers JOIN packages ON customers.pack_id = packages.pack_id
WHERE sector_id = 
	(SELECT sector_id
	 FROM sectors
	 WHERE sector_name = 'Business');
--Test