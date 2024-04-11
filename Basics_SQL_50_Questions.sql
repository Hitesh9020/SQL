CREATE DATABASE ORG;
USE ORG;

CREATE TABLE Worker (
	WORKER_ID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	FIRST_NAME CHAR(25),
	LAST_NAME CHAR(25),
	SALARY INT(15),
	JOINING_DATE DATETIME,
	DEPARTMENT CHAR(25)
);

INSERT INTO Worker 
	(WORKER_ID, FIRST_NAME, LAST_NAME, SALARY, JOINING_DATE, DEPARTMENT) VALUES
		(001, 'Monika', 'Arora', 100000, '21-02-20 09.00.00', 'HR'),
		(002, 'Niharika', 'Verma', 80000, '21-06-11 09.00.00', 'Admin'),
		(003, 'Vishal', 'Singhal', 300000, '21-02-20 09.00.00', 'HR'),
		(004, 'Amitabh', 'Singh', 500000, '21-02-20 09.00.00', 'Admin'),
		(005, 'Vivek', 'Bhati', 500000, '21-06-11 09.00.00', 'Admin'),
		(006, 'Vipul', 'Diwan', 200000, '21-06-11 09.00.00', 'Account'),
		(007, 'Satish', 'Kumar', 75000, '21-01-20 09.00.00', 'Account'),
		(008, 'Geetika', 'Chauhan', 90000, '21-04-11 09.00.00', 'Admin');

CREATE TABLE Bonus (
	WORKER_REF_ID INT,
	BONUS_AMOUNT INT(10),
	BONUS_DATE DATETIME,
	FOREIGN KEY (WORKER_REF_ID)
		REFERENCES Worker(WORKER_ID)
        ON DELETE CASCADE
);

INSERT INTO Bonus 
	(WORKER_REF_ID, BONUS_AMOUNT, BONUS_DATE) VALUES
		(001, 5000, '23-02-20'),
		(002, 3000, '23-06-11'),
		(003, 4000, '23-02-20'),
		(001, 4500, '23-02-20'),
		(002, 3500, '23-06-11');
CREATE TABLE Title (
	WORKER_REF_ID INT,
	WORKER_TITLE CHAR(25),
	AFFECTED_FROM DATETIME,
	FOREIGN KEY (WORKER_REF_ID)
		REFERENCES Worker(WORKER_ID)
        ON DELETE CASCADE
);

INSERT INTO Title 
	(WORKER_REF_ID, WORKER_TITLE, AFFECTED_FROM) VALUES
 (001, 'Manager', '2023-02-20 00:00:00'),
 (002, 'Executive', '2023-06-11 00:00:00'),
 (008, 'Executive', '2023-06-11 00:00:00'),
 (005, 'Manager', '2023-06-11 00:00:00'),
 (004, 'Asst. Manager', '2023-06-11 00:00:00'),
 (007, 'Executive', '2023-06-11 00:00:00'),
 (006, 'Lead', '2023-06-11 00:00:00'),
 (003, 'Lead', '2023-06-11 00:00:00');
 
 
-- Top 100 Questions
 
-- Q-1. Write an SQL query to fetch “FIRST_NAME” from the Worker table using the alias name <WORKER_NAME>.
select FIRST_NAME AS WORKER_NAME FROM WORKER;
 
-- Q-2. Write an SQL query to fetch “FIRST_NAME” from the Worker table in upper case.
select UPPER(FIRST_NAME) AS WORKER_NAME FROM WORKER;
 
-- Q-3. Write an SQL query to fetch unique values of DEPARTMENT from the Worker table.
SELECT DISTINCT DEPARTMENT FROM WORKER;

-- Q-4. Write an SQL query to print the first three characters of  FIRST_NAME from the Worker table.
SELECT substring(FIRST_NAME,1,3) FROM WORKER;

-- Q-5. Write an SQL query to find the position of the alphabet (‘a’) in the first name column ‘Amitabh’ from the Worker table. 
SELECT instr(FIRST_NAME,BINARY 'a') from worker
where FIRST_NAME = 'Amitabh';

-- Q-6. Write an SQL query to print the FIRST_NAME from the Worker table after removing white spaces from the right side.
select rtrim(first_name) from worker; 

-- Q-7. Write an SQL query to print the DEPARTMENT from the Worker table after removing white spaces from the left side. 
select ltrim(department) from worker; 
 
-- Q-8. Write an SQL query that fetches the unique values of DEPARTMENT from the Worker table and prints its length. 
select distinct length(department) from worker;

-- Q-9. Write an SQL query to print the FIRST_NAME from the Worker table after replacing ‘a’ with ‘A’.
select replace(first_name,'a','A') from worker;

-- Q-10. Write an SQL query to print the FIRST_NAME and LAST_NAME from the Worker table into a single column COMPLETE_NAME. A space char should separate them.
select concat(first_name,' ',last_name) as Name from worker;

-- Q-11. Write an SQL query to print all Worker details from the Worker table order by FIRST_NAME Ascending.
select * from worker
order by first_name;

-- Q-12. Write an SQL query to print all Worker details from the Worker table order by FIRST_NAME Ascending and DEPARTMENT Descending.
select * from worker
order by first_name asc, department desc;

-- Q-13. Write an SQL query to print details for Workers with the first names “Vipul” and “Satish” from the Worker table.
select * from worker
where first_name = "Vipul" or first_name = "Satish";

-- Q-14. Write an SQL query to print details of workers excluding first names, “Vipul” and “Satish” from the Worker table. 
select * from worker
where first_name != "Vipul" and first_name != "Satish";

-- Q-15. Write an SQL query to print details of Workers with DEPARTMENT name as “Admin”.
select * from worker
where department = "Admin";

-- Q-16. Write an SQL query to print details of the Workers whose FIRST_NAME contains ‘a’.
select * from worker
where first_name like "%a%";

-- Q-17. Write an SQL query to print details of the Workers whose FIRST_NAME ends with ‘a’.
select * from worker
where first_name like "%a";

-- Q-18. Write an SQL query to print details of the Workers whose FIRST_NAME ends with ‘h’ and contains six alphabets.
select * from worker
where first_name like "_____h";

-- Q-19. Write an SQL query to print details of the Workers whose SALARY lies between 100000 and 500000.
select * from worker
where salary between 100000 and 500000;

-- Q-20. Write an SQL query to print details of the Workers who joined in Feb 2021.
select * from worker
where year(joining_date) = 2021 and month(joining_date) = 2;

-- Q-21. Write an SQL query to fetch the count of employees working in the department ‘Admin’.
select count(*) from worker
where department = "Admin";

-- Q-22. Write an SQL query to fetch worker names with salaries >= 50000 and <= 100000.
select concat(first_name," ",last_name) as name, salary from worker
where salary  >= 50000 and salary <= 100000
group by name, salary;

-- Q-23. Write an SQL query to fetch the number of workers for each department in descending order.
select concat(first_name," ",last_name) as name, department from worker
group by name, department
order by name desc;

-- Q-24. Write an SQL query to print details of the Workers who are also Managers.
select * from 
(select w.worker_id, w.first_name, w.last_name, w.salary, t.worker_title from worker as w
join title as t on w.worker_id = t.worker_ref_id) as manager
where worker_title = "Manager";

-- Q-25. Write an SQL query to fetch duplicate records having matching data in some fields of a table.
select worker_ref_id, worker_title, count(*) from title
group by worker_ref_id, worker_title
having count(*) > 1 ;

-- Q-26. Write an SQL query to show only odd rows from a table.
select * from worker
where mod(worker_id,2) <> 0;

-- Q-27. Write an SQL query to show only even rows from a table.
select * from worker
where mod(worker_id,2) = 0;

-- Q-28. Write an SQL query to clone a new table from another table.
CREATE TABLE workerclone AS
SELECT * FROM worker;

-- Q-29. Write an SQL query to fetch intersecting records of two tables.
(select * from worker)
intersect
(select * from workerclone);

-- Q-30. Write an SQL query to show records from one table that another table does not have.
(select * from worker)
minus
(select * from title);

-- Q-31. Write an SQL query to show the current date and time.
select now();

-- Q-32. Write an SQL query to show the top n (say 10) records of a table.
select * from worker
order by salary desc limit 10;

-- Q-33. Write an SQL query to determine the nth (say n=5) highest salary from a table.
select salary from worker 
order by salary desc limit 4,1; 

-- Q-34. Write an SQL query to determine the 5th highest salary without using the TOP or limit method.
select * from 
(select worker_id, salary, rank() over(order by salary desc) as rank_salary from worker
group by worker_id,salary) as salary
where rank_salary = 5;

-- Q-35. Write an SQL query to fetch the list of employees with the same salary.
select w.worker_id, w.first_name, w.salary from worker w, worker w1
where w.salary = w1.salary and w.worker_id = w1.worker_id;

-- Q-36. Write an SQL query to show the second-highest salary from a table.
select max(salary) from worker
where salary not in (select max(salary) from worker);

-- Q-37. Write an SQL query to show one row twice in the results from a table.
(select * from worker w)
union all
(select * from worker w1);
 
-- Q-38. Write an SQL query to fetch intersecting records of two tables.
(select * from worker)
intersect
(select * from workerclone);

-- Q-39. Write an SQL query to fetch the first 50% of records from a table.
select * from worker
where worker_id <= (select count(worker_id)/2 from worker);

-- Q-40. Write an SQL query to fetch the departments that have less than five people in them.
select department, count(worker_id) from worker
group by department 
having count(worker_id) < 5;

-- Q-41. Write an SQL query to show all departments along with the number of people in there.
select department, count(worker_id) from worker
group by department;

-- Q-42. Write an SQL query to show the last record from a table.
select * from worker
where worker_id = (select max(worker_id) from worker);

-- Q-43. Write an SQL query to fetch the first row of a table.
select * from worker
where worker_id = (select min(worker_id) from worker);

-- Q-44. Write an SQL query to fetch the last five records from a table.
select * from worker
group by worker_id
order by worker_id desc limit 5;

-- Q-45. Write an SQL query to print the names of employees having the highest salary in each department.
select first_name, department, salary from
(select first_name, department, salary, rank() over(partition by department order by salary desc) as rnk from worker) as ranks
where rnk = 1;

-- Q-46. Write an SQL query to fetch three max salaries from a table.
select first_name, department, salary from
(select first_name, department, salary, rank() over(order by salary desc) as rnk from worker) as ranks
where rnk <= 3 ;

-- Q-47. Write an SQL query to fetch three min salaries from a table.
select first_name, department, salary from
(select first_name, department, salary, rank() over(order by salary) as rnk from worker) as ranks
where rnk <= 3 ;

-- Q-48. Write an SQL query to fetch nth max salaries from a table. (n = 4)
select first_name, department, salary from
(select first_name, department, salary, rank() over(order by salary desc) as rnk from worker) as ranks
where rnk = 4 ;

-- Q-49. Write an SQL query to fetch departments along with the total salaries paid for each of them.
select department, sum(salary) from worker
group by department;

-- Q-50. Write an SQL query to fetch the names of workers who earn the highest salary.
select first_name, max(salary) as salary from worker
group by first_name
order by salary desc limit 2;
