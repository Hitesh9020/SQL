use first;

-- 1 Retrieve the first 10 rows from a table:
select * from order_list 
limit 10;

-- 2. Find the second highest amount from an order_list table:
select max(amount) from order_list
where amount < (select max(amount) from  order_list);

-- 3. List order_id who ordered in the July month:
select * from order_list
where date between "2022-07-01" and "2022-07-31";

-- 4. Count the number of partner_id made by each order_id:
select partner_id, count(*) as Total_users from order_list
group by partner_id
order by partner_id;

-- 5. Retrieve order_id who have the highest amount in each partner_id:
select partner_id, count(order_id), max(amount) as highest_amount from order_list
group by partner_id
order by partner_id;

-- 6.  Find the nth highest amount from an Employee table: (assume 4th highest)
with cte as
(select order_id,amount, row_number() over(order by amount desc) as rk from order_list)

select amount from cte
where rk = 4;

-- 7. List restruants who don't have a rating:
select * from order_list 
where restaurant_rating = 0;

-- 8. Retrieve order_id who got ordered more than 500rs:
select order_id,amount from order_list
where amount > 500
order by amount;

-- 9. Find duplicate records in a table:
select order_id,amount, count(*) from order_list
group by order_id, amount
having count(*)>1;

-- 10. Calculate the total sales for each partner_id:
select partner_id,sum(amount) as Total_sales_by_partner_id from order_list
group by partner_id
order by partner_id;

-- 11. Retrieve the top 3 user_id with the highest total purchase amount:
select user_id, sum(amount) as total from order_list
group by user_id
order by total desc limit 3;

-- 12. List all user_id who have made at least 3 orders:
select user_id, count(order_id) as total_orders from order_list
group by user_id
having count(order_id) > 3;

-- 13. Calculate the average amount of orders by user_id:
select user_id, round(avg(amount),0) as avg_amount from order_list
group by user_id
order by user_id;

-- 14. Find the most common food type in a food table:
select type , count(type) as total from food
group by type
order by total desc;

-- 15. Retrieve the oldest and newest order by each user_id:
select user_id, min(date) as oldest, max(date) as newest from order_list
group by user_id
order by user_id;

-- 16. List the top 3 best delivery_time by each partner:
with delivery as
(select partner_id, delivery_time, dense_rank() over (partition by partner_id order by delivery_time desc) as rw from order_list)

select partner_id, delivery_time from delivery
where rw < 3;

-- 17. Calculate the percentage of total amount contributed by each user_id:
select user_id, round((sum(amount)/(select sum(amount) from order_list)),2)*100 as sales_percentage from order_list
group by user_id
order by sales_percentage;

-- 18.  Find partner_id who have the same salary delivery_time:
select order_id,delivery_time, count(*) from order_list
group by order_id, delivery_time
having count(*)>1;

-- 19. List the user who have not order last month:
select user_id,date from order_list
where date not between "2022-07-01" and "2022-07-31";

-- 20. Retrieve orders that have rating below 2:
select order_id,delivery_rating from order_list
where delivery_rating < 3;

-- 21. Calculate the total number of orders placed each month:
select extract(month from date) as month, count(*) as total from order_list
group by month; 

-- 22. Find the customer who has placed the highest number of orders:
with ord as 
(select user_id, order_id, rank() over(order by count(order_id) desc) as orde from order_list
group by user_id, order_id)

select user_id, count(order_id) from ord
where orde <2
group by user_id;  

-- 23. Retrieve the above more than 20% of  revenue distributions:
with sales_percentage as 
(select user_id, round((sum(amount)/(select sum(amount) from order_list)),2)*100 as sales_percentage from order_list
group by user_id
order by sales_percentage asc)

select user_id, sales_percentage from sales_percentage
where sales_percentage > 20;

-- 24. List partner who have the delivered order most:
with total_delivererd as 
(select partner_id, count(partner_id)as total_deliveres, row_number() over(order by count(partner_id) desc) as rnk from order_list
group by partner_id)

select partner_id, total_deliveres from total_delivererd
where rnk = 1
group by partner_id;

-- 25. Calculate the running total of sales for each month:
select  distinct(date), sum(amount) over( order by date) as total_sales_per_month from order_list;

-- 26. Retrieve the latest order placed by each user:
SELECT user_id, MAX(date) AS latest_order_date FROM order_list
GROUP BY user_id;

-- 27. Find customers who have never placed an order:
select * from order_list
where user_id not in (select distinct user_id from order_list);

-- 28. List the food that have never been sold:
with sold as 
( select food.f_id, food.f_name, order_details.order_id from food
join order_details on food.f_id = order_details.f_id
order by food.f_id )

SELECT * FROM sold
WHERE order_id NOT IN (SELECT DISTINCT order_id FROM sold);

-- 29. Retrieve the average time taken to ship orders for each delivery time:
select partner_id, round(avg(delivery_time),2) from order_list
group by partner_id
order by partner_id;

-- 30. Find the total number of unique customers who made purchases in each month:
SELECT EXTRACT(month FROM date) AS month, COUNT(DISTINCT user_id) AS num_users FROM Order_list
GROUP BY EXTRACT(month FROM date);

use datalytics;    -- Changing the database for next questions.

-- 31. Retrieve the top 3 highest-income by Acquistion_channel in each Category department:
select Acquisition_Channel, Categroy, Income from 
(select Acquisition_Channel, Categroy, Income, row_number() over(partition by Categroy order by income desc) as rk_in from marketing) as rank_income
where rk_in < 3;

-- 32. Find the average income difference between Electronics and Clothing department:
select Categroy, round(avg(income),2) as average from marketing
where Categroy = "Electronics"
union
select Categroy, round(avg(income),2) from marketing
where Categroy = "Clothing";

-- 33. List location where have spent more than the average total income by all Category:
select Categroy,sum(income) as sum_income from marketing
group by Categroy
having sum(income) > (select avg(income) as average_in);

-- 34. Retrieve the top 5 categories with the highest average sales amount:
select Categroy, avg(income) as average from marketing
group by Categroy
order by average desc
limit 5;

-- 35. Calculate the median income by Email Acquisition_Channel:
select Acquisition_Channel, avg(income) from
(select Acquisition_Channel, income, row_number() over(order by income) as rw_num, count(*) over() as total_rows from marketing) as income_data
WHERE rw_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)
group by Acquisition_Channel;

-- 36. Find the Acquisition_Channel who have never repeat_purachase:
select Acquisition_Channel, Repeat_Purchase from marketing
where Repeat_Purchase in (SELECT DISTINCT Repeat_Purchase FROM marketing WHERE Repeat_Purchase = "No")
group by Acquisition_Channel;

-- 37. Retrieve the top 3 most recent orders for each category:
select Categroy, Order_date from 
(select Categroy, Order_date, row_number() over(partition by Categroy order by Order_date desc) as date_rank from marketing) as ordering
where date_rank < 4;

-- 38. check if both genders have placed orders in all categories:
select Gender, Categroy from marketing
group by Gender, Categroy
having count(distinct Gender) = (select count(Gender) from marketing);         

-- 39. Calculate the percentage of null values in each column of a table:
SELECT Customer_satisfaction,
 (COUNT(*) - COUNT(Customer_satisfaction)) / COUNT(*) * 100 AS null_percentage
FROM marketing
GROUP BY Customer_satisfaction;

-- 40. Find the category that have been sold every month for the past year:
select Categroy from marketing
group by Categroy
having count(distinct extract(month from Order_date)) = 12;

-- 41.  Retrieve the most recent order for each Category:
select Categroy, max(Order_date) as recent from marketing
group by Categroy;

-- 42. Find the total number of orders and the average order amount for each Category:
select Categroy, count(Categroy) as total_orders, round(avg(income),2) as average from marketing
group by Categroy;

-- 43. List the product that have been sold more than 100 times:
select Product_id, count(Product_id) from marketing
group by Product_id
having count(Product_id) < 100;

-- 44. Retrieve the age group more than 35 of customers who have made purchases:
select Age, count(Product_id) from marketing
where Age > 35
group by Age;

-- 45. Calculate the total products sold in last one month:
select count(Product_id), Order_date from marketing
where Order_date >= now() - interval 2 month
group by order_date;

-- 46. Find the categories with the highest and lowest average incomes:
(select Categroy, avg(income) as average from marketing
group by Categroy
order by average desc limit 1)
union
(select Categroy, avg(income) as average from marketing
group by Categroy
order by average asc limit 1);

-- 47. Count customers who have made purchases in all months of the year 2023:
select Order_date, count(Customer_Id) from marketing
where extract(year from Order_date) = 2023
group by  Order_date;

-- 48. Calculate the difference in sales between the current year and the previous year for each product:
select Product_id,
sum(case when extract(year from Order_date) = extract(year from current_date()) -1  then income else 0 end) - 
sum(case when extract(year from Order_date) = extract(year from current_date()) then income else 0 end) as sales
from marketing
group by Product_id;

-- 49. Retrieve the customer who have purchased in the last quarter:
SELECT * from marketing 
WHERE Order_date >= now() - interval 1 quarter;

-- 50. List the products that have sold less times:
select Product_id, count(Product_id) as cont from marketing
group by Product_id
order by  cont asc limit 5;

-- 51. Retrieve the average income of last month for each Category:
select Categroy, avg(income) as average from marketing
group by Categroy
having now() - interval 1 month;

-- 52. Find the customers who have placed orders on consecutive days:
select distinct (marketing.Customer_Id) from marketing
where datediff(day, marketing.Order_date, marketing.Order_date) = 1;

-- 53. Calculate the total revenue generated from each product category:
select Categroy, Product_id, sum(income) as revenue from marketing
group by Categroy, Product_id
order by revenue desc;

-- 54. Retrieve the top 3 most profitable products id based on total revenue: 
with sales as
(select Product_id, 
row_number() over(order by sum(income)) as high_revenue from marketing 
group by Product_id) 

select Product_id from sales
where high_revenue < 4;

-- 55. Find the number of employees in each income range (e.g., 0-50000, 50001-100000, etc.):
select concat(floor(income/50000)*50000 + 1, '-', floor(income/50000)*50000 + 50000) as income_range, count(*) as total_employs
from marketing
group by floor(income/50000);

-- 56.  Retrieve the top 5 most frequent words from a text column:
select Categroy, count(*) as frequency from
(select regexp_split_to_table(Categroy,'\s+') as word from marketing) as words
group by Categroy
order by frequency desc
limit 5;

-- 57. Calculate the percentage change in sales amount compared to the previous month for each product:
SELECT product_id,
 (SUM(amount) - LAG(SUM(amount)) OVER(PARTITION BY product_id ORDER BY EXTRACT(YEAR_MONTH FROM sale_date))) 
 / LAG(SUM(amount)) OVER(PARTITION BY product_id ORDER BY EXTRACT(YEAR_MONTH FROM sale_date)) * 100 AS percentage_change
FROM Sales
GROUP BY product_id;

-- 58. Genders count total orders for products:
select Gender, Categroy, count(Categroy) from marketing
group by Gender, Categroy;

-- 59. Retrieve the orders placed by customers who have not logged in to the system in the last 30 days:
SELECT * FROM Orders
WHERE customer_id IN 
( SELECT customer_id FROM Customers
 WHERE last_login_date <= DATEADD(day, -30, now()));

-- 60. Find the average number of products sold per month:
select extract(month from Order_date), count(Product_id) from marketing
group by extract(month from Order_date)
order by extract(month from Order_date) asc;

-- 61. Retrieve the customers who have made purchases on weekdays only:
SELECT count(customer_id) FROM marketing
WHERE DAYOFWEEK(Order_date) BETWEEN 2 AND 6;

-- 62. Find the average sales price to ship orders for each product category:
select Categroy, round(avg(Sales),1) from marketing
group by Categroy;

-- 63. Retrieve the customers who have placed orders for more than 3 unique restruants:
select user_id, r_id from 
( select user_id, r_id, count(distinct r_id) as rest from order_list
group by user_id, r_id) as restru
where rest < 3;

-- 64. Calculate the total sales for each product category in the last quarter:
select Categroy, sum(Sales) from marketing
where Order_date >= now() - interval 1 quarter
group by Categroy;

-- 65. List count of Acquisition_Channel who have get ordered in multiple Category:
select Acquisition_Channel, count(Categroy) from marketing
group by Acquisition_Channel;

-- 66. Retrieve the orders with the highest and lowest incomes:
(select * from marketing
where income = (select max(income) from marketing))
union 
(select * from marketing
where income = (select min(income) from marketing));

-- 67. Rank the Acquisition_Channel by sells of category bought by Acuisition_Channel:
select Acquisition_Channel, row_number() over(order by count(Categroy)) as rank_order from marketing
group by Acquisition_Channel;

-- 68. Calculate the percentage of total orders for each product category:
select Categroy, round(count(*) * 100/(select count(*) from marketing),2) as percentage from marketing
group by Categroy;

-- 69. Retrieve the customers who have made purchases on weekends only:
SELECT count(customer_id) FROM marketing
WHERE DAYOFWEEK(Order_date) not BETWEEN 2 AND 6;

-- 70. lIst top 10 ranked product_id which generated income:
with product as 
(select Product_id, sum(income), rank() over(order by sum(income) desc) as product_income from marketing
group by Product_id)

select * from product
where product_income <= 10;

-- 71. Retrieve the Loaction where most products are sold:
with location as 
(select Location, count(Categroy), rank() over(order by count(Categroy) desc) as rank_location from marketing
group by Location)

select * from location
where rank_location <= 10;

-- 72. Find the top 3 most common words in a text column excluding common stop words ("and", "the", "is", etc.):
SELECT Location, COUNT(*) AS frequency FROM (
 SELECT regexp_split_to_table(LOWER(text_column), '\s+') AS word FROM marketing ) AS words
WHERE Location NOT IN ('and', 'the', 'is', 'of', 'a', 'to', 'in', 'it')
GROUP BY Location
ORDER BY frequency DESC LIMIT 3;

-- 73. Calculate the average number of orders per month for each Category: 
select Categroy, avg(total) as count from 
( select Categroy, extract(month from Order_date) as mth, count(*) as total from marketing
group by Categroy, extract(month from Order_date)) as mth_orders
group by Categroy;

-- 74. Retrieve the products that have sold most by age more than 70:
select Age, count(Product_id) as sold from marketing
where Age > 70
group by Age
order by sold desc limit 1;

-- 75. List the products who were sold by more than 70 age people:
select Age, count(Product_id) as sold from marketing
where Age > 70
group by Age
order by Age;

-- 76. Retrieve the products that have experienced a decrease in sales amount for each consecutive month for the last three months:
SELECT Product_id FROM (
 SELECT Product_id, ROW_NUMBER() OVER (PARTITION BY Product_id ORDER BY Order_date) AS rn, SUM(income) AS total_amount FROM marketing
 GROUP BY Product_id, EXTRACT(YEAR_MONTH FROM Order_date)) AS sales_per_month
WHERE rn <= 3
GROUP BY Product_id
HAVING COUNT(*) = 3 AND total_amount = MAX(total_amount);
 
-- 77. Find the average length of time between orders for each customer:
SELECT Customer_id, AVG(datediff(day, LAG(Order_date) OVER(PARTITION BY Customer_id ORDER BY Order_date), Order_date)) AS avg_time_between_orders FROM marketing
GROUP BY Customer_id;

-- 78.  Retrieve the customers who have made purchases of Veg food:
with food as
(select o.order_id,f.f_id,f.f_name, f.type from food as f
join order_details as o on o.f_id = f.f_id
where f.type = "Veg")

select f_id, count(order_id) from food
group by f_id;

-- 79.  Find the top 3 most popular food name based on the total number of orders:
with food as
(select o.order_id,f.f_id,f.f_name, f.type from food as f
join order_details as o on o.f_id = f.f_id)

select f_name, count(order_id) as total from food
group by f_name
order by total desc limit 3;

-- 80. Retrieve the orders with the highest and lowest total order amounts within each food category:
with food as
(select o.order_id,f.f_id,f.f_name, f.type from food as f
join order_details as o on o.f_id = f.f_id) 

(select type, count(order_id) as total from food
where type = "Veg" 
group by type
order by total desc limit 1)
union
(select type, count(order_id) as total from food
where type = "Non-Veg" 
group by type
order by total desc limit 1);

-- 81. List the customers who have made purchased all type of food:
with food as
(select o.order_id,f.f_id,f.f_name, f.type from food as f
join order_details as o on o.f_id = f.f_id) 

select o.order_id, f.f_id, count(user_id) as totals from food as f
join order_list as o on o.order_id = f.order_id
group by o.order_id, f.f_id;

-- 82. Calculate the percentage of total orders for each customer:
SELECT order_id, round((COUNT(order_id) * 100.0 / (SELECT COUNT(*) FROM order_list)),2) AS percentage_of_total_orders FROM order_list 
GROUP BY order_id;

-- 83. Find the employees who have not been ordered any food:
with food as
(select o.order_id,f.f_id,f.f_name, f.type from food as f
join order_details as o on o.f_id = f.f_id) 

select order_id from food
where order_id not in (select distinct order_id from food);

-- 84. Retrieve the orders with the highest and lowest total order quantities within each product category:
with ranking as 
( select * , 
rank() over(partition by order_id order by sum(f_id) desc) as high, 
rank() over(partition by order_id order by sum(f_id) asc) as low from (select * from order_details) as ranks
group by order_id)
SELECT * FROM ranking WHERE high = 1 OR low = 1;

-- 85. List the customers who have made purchases on both weekdays and weekends:
SELECT count(order_id) FROM order_list
WHERE (DAYOFWEEK(date) not BETWEEN 2 AND 6) and ((DAYOFWEEK(date) BETWEEN 2 AND 6));

-- 86. Retrieve the top 5 customers with the highest average order amounts:
select * from 
(select user_id, rank() over(partition by user_id order by count(user_id)) as top_5 from order_list 
group by user_id) as rankings
where top_5 <= 5;

-- 87. Find the most frequent restruants ordered by users:
select user_id, r_id, count(r_id) as total_orders_restruant from order_list
group by user_id, r_id
order by total_orders_restruant desc;

-- 88. List the customers who have made purchases in every month of a given year:
select user_id from order_list
where  EXTRACT(YEAR FROM date) = 2022
GROUP BY user_id
HAVING COUNT(DISTINCT EXTRACT(MONTH FROM date)) = 3;

-- 89. Retrieve the top 2 most profitable months based on total sales amount:
select extract(month from date) as mth, sum(amount) as sales from order_list
group by extract(month from date)
order by sales desc limit 2;

-- 90. Find the customers who have delivery rating is 5 and delivers within 20 mins:
select user_id, delivery_time, delivery_rating from order_list
where delivery_rating = 5 and delivery_time < 20;

-- 91. Retrieve the orders with the highest and lowest total order amounts for each month:
with mth_orders as
(select user_id, extract(month from date) as mth, sum(amount) as total from order_list
group by user_id, extract(month from date))

select * from 
( select *, rank() over(partition by mth order by total desc) as high from mth_orders) as highest
where high = 1
union
select * from 
( select *, rank() over(partition by mth order by total) as low from mth_orders) as lowest
where low = 1;

-- 92. List the food_id that have been sold at least once every month for the past month:
with ord as 
(select o.order_id, o.f_id, l.date, l.amount from order_details as o
join order_list as l on o.order_id = l.order_id)

select order_id from (select order_id, extract(month from date) as mth from ord
group by order_id, extract(month from date)
having count(distinct extract(month from date)) = 3) as mth_orders
group by order_id
having count(*) = 3;

-- 93. Retrieve the partner_name who have highest amount due to their orders:
with partner as 
(select o.order_id, o.amount, o.partner_id, p.partner_name from order_list as o
join delivery_boy as p on p.partner_id = o.partner_id)

select * from 
(select partner_name, rank() over(order by sum(amount) desc) as rnk_partner from partner
group by partner_name) as rnkings
where rnk_partner < 6;
