

--1  How many pizzas were ordered?
Select count(order_id)
from customer_orders_temp;



-- 2 How many unique customer orders were made?
Select Count(Distinct order_id)
from customer_orders_temp;




-- 3 How many successful orders were delivered by each runner?

select r.runner_id as Runner_id , count(Distinct ro.order_id) as Orders
from runners r left join runner_orders_tmp ro 
using(runner_id)
where ro.cancellation is NULL
Group by Runner_id;

-- 4 How many of each type of pizza was delivered?

select p.pizza_id,p.pizza_name , count(c.pizza_id) as delivered_pizzas
from customer_orders_temp c left join runner_orders_tmp r
using(order_id) 
join pizza_names p 
on c.pizza_id = p.pizza_id
where r.cancellation is NULL 

group by p.pizza_id,p.pizza_name;



-- 5 How many Vegetarian and Meatlovers were ordered by each customer?

select c.customer_id,c.pizza_id , p.pizza_name ,count(c.order_id)
from customer_orders_temp c left join pizza_names p 
using(pizza_id)
group by  c.customer_id,c.pizza_id , p.pizza_name
ORDER BY c.customer_id,c.pizza_id , p.pizza_name;


-- 6 What was the maximum number of pizzas delivered in a single order?

Select c.order_id , count(c.order_id) as pizzas
from customer_orders_temp c left join runner_orders_tmp r
using(order_id)
where r.cancellation is null
group by c.order_id
order by pizzas desc
LIMIT 1;


-- 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,Count(c.order_id),
sum
(
  case 
  	when exclusions is not null  or extras is not null then 1
  	     
  	Else 0 
  	end 
  
) as Number_of_Changes,
sum
(
  case 
  	when exclusions is  null  And extras is null then 1
  	   
  	Else 0 
  	end 
)as number_of_No_Changes
from customer_orders_temp c left join runner_orders_tmp r 
using(order_id)
where r.cancellation is null
Group by  c.customer_id;




-- 8 How many pizzas were delivered that had both exclusions and extras?

select count (c.order_id) as Number_of_Pizzas
from customer_orders_temp c left join runner_orders_tmp r 
using(order_id)
where c.exclusions is not null 
      And c.extras IS not null 
      And r.cancellation Is null;



-- 9 What was the total volume of pizzas ordered for each hour of the day?
select EXTRACT (Hour from order_time ) as Hour, Count(order_id)
from customer_orders_temp 
Group by Hour
ORDER BY Hour;


-- 10 What was the volume of orders for each day of the week?

Select TO_Char(order_time ,'FMday') as days,Count(order_id)
from customer_orders_temp
Group by days
order by days





