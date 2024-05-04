create database Company;
use Company;

CREATE TABLE depts (
    dept_code INT PRIMARY KEY,
    dept_title VARCHAR(255)
);

CREATE TABLE emps (
    emp_code INT PRIMARY KEY,
    emp_fname VARCHAR(255),
    dept_code INT,
    manager_id INT,
    join_date DATE,
    salary DECIMAL(10, 2),
    FOREIGN KEY (dept_code) REFERENCES depts(dept_code),
    FOREIGN KEY (manager_id) REFERENCES emps(emp_code)
);

CREATE TABLE salaries (
    emp_code INT,
    salary DECIMAL(10, 2),
    FOREIGN KEY (emp_code) REFERENCES emps(emp_code)
);

-- Departments
INSERT INTO depts VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Marketing');

-- Employees
INSERT INTO emps VALUES
(1, 'Robert', 1, NULL, '2022-01-01', 60000.00),
(2, 'Silvia', 2, 1, '2020-02-15', 80000.00),
(3, 'Amar', 2, 1, '2022-01-10', 80000.00),
(4, 'Akbar', 3, 2, '2022-04-20', 30000.00),
(5, 'Anthony', 3, 2, '2022-05-05', 60000.00),
(6, 'David', 4, 3, '2022-06-15', 80000.00),
(7, 'Grace', 4, 3, '2022-07-01', 80000.00),
(8, 'Frank', 1, NULL, '2022-08-10', 65000.00),
(9, 'Helen', 3, 2, CURDATE() - INTERVAL 1 YEAR, 70000.00),
(10, 'Salman', 4, 3, CURDATE() - INTERVAL 6 MONTH, 60000.00),
(11, 'Variko', 2, 1, CURDATE() - INTERVAL 1 YEAR, 80000.00),
(12, 'Aparichita', 3, 1, '2024-03-15', 67916),
(13, 'Saksham', NULL, 1, '2024-02-10', 80000),
(14, 'Vidushi', 1, 1, '2024-01-12', 60000);

-- Salaries
INSERT INTO salaries VALUES
(1, 60000.00),
(2, 70000.00),
(3, 70000.00),
(4, 55000.00),
(5, 60000.00),
(6, 80000.00),
(7, 80000.00),
(8, 65000.00),
(9, 70000.00),
(10, 75000.00),
(11, 100000.00),
(12, 67916.60),
(13, 80000.00),
(14, 60000.00);

-- 50 Tricky Questions

-- 1. Retrieve all employees and their departments, including those without a department.
select e.dept_code, e.emp_fname, d.dept_title, e.salary from emps e
left join depts d on e.dept_code = d.dept_code;

-- 2. Find the second highest salary from the “salaries” table.
select max(salary) from emps
where salary < (select max(salary) from emps); -- or where salary not in (select max(salary) from emps);

-- 3. Calculate the average salary for each department.
with emp as 
(select e.dept_code, e.emp_fname, d.dept_title, e.salary from emps e
inner join depts d on e.dept_code = d.dept_code)

select dept_title, avg(salary) as average from emp
group by dept_title;

-- 4. List the employees who have the same salary as the second highest-paid employee.
SELECT e.emp_code, e.emp_fname, s.salary FROM emps e
JOIN salaries s ON e.emp_code = s.emp_code
WHERE s.salary = (SELECT MAX(salary) AS second_highest_salary FROM salaries 
WHERE salary < (SELECT MAX(salary) FROM salaries));

-- 5. Retrieve the employees who joined before their manager.
select emp_fname, join_date from emps
where manager_id is null;

-- 6. Find the top 3 departments with the highest average salary.
with emp as 
(select e.dept_code, e.emp_fname, d.dept_title, e.salary from emps e
inner join depts d on e.dept_code = d.dept_code)

select dept_title, avg(salary) as average_salary from emp
group by dept_title
order by average_salary desc limit 3;

-- 7. List the departments where the average salary is above the overall average salary.
with emp as 
(select e.dept_code, d.dept_title, s.salary from emps e
join depts d on e.dept_code = d.dept_code
join salaries s on s.emp_code = e.emp_code)

select dept_code, dept_title, avg(salary) as average_salary from emp
group by dept_code, dept_title
having average_salary > (select avg(salary) from emp);

-- 8. Update employee salaries to the maximum salary within their department. Also, print the old salary vs the new salary.
drop table if exists new_salary;
create temporary table new_salary as
select  d.dept_code, d.dept_title, s.salary as old_salary, s.salary as new_salary from depts d
join emps e on e.dept_code = d.dept_code
join salaries s on e.emp_code = s.emp_code;

UPDATE salaries s
JOIN emps e ON s.emp_code = e.emp_code
JOIN new_salary ns ON e.dept_code = ns.dept_code
SET s.salary = ns.new_salary;

select  * from new_salary;

-- 9. Find the employees who have the same salary and department as their manager.
select e.emp_fname from emps e
join emps m on e.manager_id = m.emp_code
where e.dept_code = m.dept_code and e.salary = m.salary;

-- 10. Retrieve the cumulative salary for each employee considering the running total within their department.
select emp_fname, dept_code, salary, 
sum(salary) over (partition by dept_code order by salary) as cumulative_salary from emps;

-- 11. Find the third maximum salary from the “salaries” table without using the LIMIT clause.
with ranks as 
(select emp_fname, salary, dense_rank() over(order by salary desc) as ranks from emps
group  by emp_fname, salary)

select * from ranks
where ranks = 3
group by emp_fname, salary; 

-- 12. List the employees who have never been assigned to a department.
select emp_fname from emps
where dept_code is null;

-- 13. Retrieve the employees with the highest salary in each department. 
with emp as 
(select e.emp_fname, d.dept_title, e.salary from emps e
join depts d on d.dept_code = e.dept_code)

select emp_fname, dept_title, salary from
(select emp_fname, dept_title, salary, rank() over(partition by dept_title order by salary desc) as rn from emp) as rnk
where rn = 1;

-- 14. Calculate the median salary for each department.
SELECT dept_code,
       AVG(salary) AS median_salary
FROM (
    SELECT dept_code,
           salary,
           ROW_NUMBER() OVER (PARTITION BY dept_code ORDER BY salary) AS row_num,
           COUNT(*) OVER (PARTITION BY dept_code) AS total_rows
    FROM emps
) ranked
WHERE row_num IN ((total_rows + 1) DIV 2, (total_rows + 2) DIV 2)
GROUP BY dept_code;

-- 15.  Find the employees who have the same manager as the employee with ID 3.
select emp_fname from emps
where manager_id = (select manager_id from emps 
where emp_code = 3);

-- 16. Retrieve the employees who have the highest salary in their respective department and joined in the last 6 months.
with emp as 
(select e.emp_fname, d.dept_title, e.join_date, e.salary from emps e
join depts d on d.dept_code = e.dept_code)

select emp_fname, dept_title, join_date salary from
(select emp_fname, dept_title, join_date, salary, rank() over(partition by dept_title order by salary desc) as rn from emp 
where join_date >= now() - interval 6 month) as rnk
where rn = 1;

-- 17. List the departments with more than 3 employees.
with emp as 
(select e.emp_fname, d.dept_title, e.join_date, e.salary from emps e
join depts d on d.dept_code = e.dept_code)

select dept_title from emp
group by dept_title
having count(dept_title) > 3;

-- 18.  Retrieve the employees with the second lowest salary.
with emp as 
(select e.emp_fname, d.dept_title, e.join_date, e.salary from emps e
join depts d on d.dept_code = e.dept_code)

select emp_fname, dept_title, salary from
(select emp_fname, dept_title, salary, rank() over(order by salary) as rn from emp) as rnk
where rn = 1;

-- 19. Find the departments where the highest and lowest salaries differ by more than $10,000.
select dept_code from
(select dept_code, max(salary) - min(salary) as sal_diff from emps
group by dept_code) as diff
where sal_diff > 10000;

-- 20. Update the salaries of all employees in the “IT” department to be 10% higher. Also, make sure to print records displaying new salary.
drop table if exists updated;
create temporary table updated as
select  emp_code, emp_fname, salary as old_salary, salary as new_salary from emps
where dept_code = (select dept_code from depts where dept_title = "IT");

select emp_code, new_salary from updated;
update updated 
set new_salary = old_salary * 1.1;

-- 21. Retrieve the employees who have the same salary as the employee with ID 2 in a different department.
select emp_code, dept_code, salary from emps
where salary = (select salary from emps where emp_code = 2 and dept_code <>1);

-- 22. Calculate the difference in days between the hire dates of each employee and their manager.
SELECT e.emp_fname, e.join_date, m.emp_fname AS manager_name, m.join_date AS manager_join_date,
       DATEDIFF(e.join_date, m.join_date) AS days_difference
FROM emps e
JOIN emps m ON e.manager_id = m.emp_code;

-- 23. Find the departments where the sum of salaries is greater than the overall average salary.
select dept_code, salary from
(select dept_code, salary from emps
group by dept_code, salary
having salary > (select avg(salary) from emps)) as average
group by dept_code, salary;

-- 24. List the employees who have the same salary as at least one other employee.
select e.emp_fname from emps e
where exists (select 1 from emps where salary = e.salary and emp_code <> e.emp_code);

-- 25. Retrieve the employees with the highest and lowest salary in each department.
select  dept_code, max(salary) as highest, min(salary) as lowest from emps
group by dept_code; 

-- 26. Find the employees who have the same salary as the employee with ID 2 and are in the same department.
select emp_code, dept_code, salary from emps
where salary = (select salary from emps where emp_code = 2) and dept_code = (select dept_code from emps where emp_code = 2);

-- 27. Calculate the average salary excluding the highest and lowest salaries in each department.
SELECT dept_code,
       AVG(salary) AS average_salary
FROM (
    SELECT dept_code, salary,
           RANK() OVER (PARTITION BY dept_code ORDER BY salary) AS salary_rank_asc,
           RANK() OVER (PARTITION BY dept_code ORDER BY salary DESC) AS salary_rank_desc
    FROM emps
) ranked
WHERE salary_rank_asc > 1 
  AND salary_rank_desc > 1 
GROUP BY dept_code;

-- 28. List the employees who have a higher salary than their manager.
select  e.emp_fname  from emps e
join emps m on e.manager_id = m.emp_code
where m.salary < e.salary; 


-- 29. Retrieve the top 5 departments with the highest salary sum.
select dept_code, sum(salary), row_number() over(partition by dept_code order by sum(salary) desc) as rnk from emps
group by dept_code; 

-- 30. Find the employees who have the same salary as the average salary in their department
with salary as 
(select dept_code, avg(salary) as salary  from emps 
group by dept_code)

select s.dept_code, s.salary from salary s
where salary = (select avg(e.salary) from emps e where dept_code = s.dept_code);

-- 31. Calculate the moving average salary for each employee over the last 3 months.
select emp_code, join_date, avg(salary) over(partition by emp_code order by join_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg from emps;

-- 32. List the employees who have joined in the same month as their manager.
select e.emp_code, e.join_date from emps e
join emps m on e.manager_id = m.emp_code
where month(e.join_date) = month(m.join_date) and year(e.join_date) = year(m.join_date);

-- 33. Retrieve the employees with salaries in the top 10% within their department.
select * from 
(select emp_code, dept_code, salary, percent_rank() over(partition by dept_code order by salary desc) as rnks from emps) as rnks
where rnks >= 1.0;

-- 34. Find the departments where the number of employees is greater than the number of employees in the “IT” department.
select dept_code from
(select dept_code, count(*) as cnts from emps 
group by dept_code) as cnt
where cnts > (select count(emp_code) from emps where dept_code = 2);
 
--  35. Retrieve the employees who have the same salary as the employee with ID 2 in a different department and joined in the last year.
select emp_code, dept_code, salary from emps
where salary = (select salary from emps where emp_code = 2 and dept_code <>1) 
and join_date = now() - interval 1 year;

-- 36. Calculate the difference in salary between each employee and the employee with ID 1.
select emp_fname, salary, salary - (select salary from emps where emp_code = 1) as sal_diff from emps;

-- 37. List the employees who have the same salary as the employee with ID 3 in the same department.
select emp_fname, dept_code, salary from emps
where salary = (select salary from emps where emp_code = 3) 
and dept_code = (select dept_code from emps where emp_code = 3);

-- 38. Retrieve the employees who have the same manager as the employee with ID 2 and are in a different department.
select emp_fname, dept_code, salary from emps
where salary = (select salary from emps where emp_code = 2) 
and dept_code <> (select dept_code from emps where emp_code = 2);

-- 39. Calculate the difference in years between the hire dates of each employee and the average hire date in their department.
select e.emp_code, e.join_date , 
abs(timestampdiff(year, (select avg(join_date) from emps
where dept_code = e.dept_code), e.join_date)) as diff 
from emps e;

-- 40. Find the employees who have a salary equal to or more than the average salary across all departments.
SELECT emp_fname
FROM emps
WHERE salary >= (SELECT AVG(salary) FROM emps);

-- 41. Retrieve the employees who have the same salary as the median salary in their department.
SELECT emp_fname FROM 
( SELECT emp_fname,
        ROW_NUMBER() OVER (PARTITION BY dept_code ORDER BY salary) AS row_num,
        COUNT(*) OVER (PARTITION BY dept_code) AS total_count
    FROM emps) ranked
WHERE row_num = CEIL(total_count / 2.0);

-- 42. Calculate the difference in days between the hire dates of each employee and the hire date of the employee with the earliest hire date in their department.
SELECT e.emp_fname, e.join_date,
       DATEDIFF(e.join_date, (SELECT MIN(join_date) 
       FROM emps WHERE dept_code = e.dept_code)) AS days_difference
FROM emps e;

-- 43. Retrieve the employees who have the same salary as the employee with ID 5 in a different department.
SELECT emp_fname
FROM emps
WHERE salary = (SELECT salary FROM emps WHERE emp_code = 5)
  AND dept_code <> (SELECT dept_code FROM emps WHERE emp_code = 5);
  
-- 44. List the employees who have the same manager as the employee with ID 5 and have a higher salary.
select emp_fname from emps
WHERE manager_id = (SELECT manager_id FROM emps WHERE emp_code = 5)
AND salary > (SELECT salary FROM emps WHERE emp_code = 5);

-- 45. Calculate the difference in months between the hire dates of each employee and the hire date of the employee with the latest hire date in their department.
SELECT e.emp_fname, e.join_date,
       TIMESTAMPDIFF(MONTH, e.join_date, (SELECT MAX(join_date) 
FROM emps WHERE dept_code = e.dept_code)) AS months_difference
FROM emps e;

-- 46. Retrieve the employees who have the same salary as the employee with ID 1 and joined in the last 6 months.
SELECT emp_fname
FROM emps
WHERE salary = (SELECT salary FROM emps WHERE emp_code = 1) 
AND join_date >= current_date() - INTERVAL 6 MONTH;

-- 47. List the departments where the highest salary is more than twice the lowest salary.
SELECT dept_code
FROM (
    SELECT dept_code, MAX(salary) AS max_salary, MIN(salary) AS min_salary
    FROM emps
    GROUP BY dept_code
) diff
WHERE max_salary > 2 * min_salary;

-- 48. Retrieve the employees who have the same manager as the employee with ID 3 and are in the same department.
SELECT emp_fname
FROM emps
WHERE manager_id = (SELECT manager_id FROM emps WHERE emp_code = 3)
 AND dept_code = (SELECT dept_code FROM emps WHERE emp_code = 3);
 
-- 49. Calculate the difference in hours between the hire dates of each employee and the hire date of the employee with the earliest hire date in the company.
SELECT emp_fname, join_date,
       ABS(TIMESTAMPDIFF(HOUR, join_date, (SELECT MIN(join_date) FROM emps))) AS hours_difference
FROM emps;

-- 50. Find the employees who have the same salary as the employee with ID 2 and joined in the last year.
SELECT emp_fname
FROM emps
WHERE salary = (SELECT salary FROM emps WHERE emp_code = 2)
 AND join_date >= CURDATE() - INTERVAL 1 YEAR;