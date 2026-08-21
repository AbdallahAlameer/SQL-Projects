  
  
--1 How many runners signed up for each 1 week period? (i.e.week starts 2021-01-01)

select to_char(registration_date,'ww') as Week ,
Count(runner_id) as registered_runners
from runners 
group by  Week 
Order by Week;


-- 2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with unique_orders as
(
  select Distinct
  c.order_id,
  c.order_time,
  r.runner_id,
  r.pickup_time
  from customer_orders_temp c join runner_orders_tmp r 
      ON c.order_id = r.order_id
  WHERE r.pickup_time IS NOT NULL
 )
 
select runner_id , Avg(Extract(Minute from pickup_time - order_time )) as Estmated_time
from unique_orders
Group by runner_id;
 


-- 3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
 
with order_prep_time as 
(
  select 
  c.order_id,
  count(c.order_id) as pizza_count,
  Extract(Minute from pickup_time - order_time ) as prep_time_minutes
  from customer_orders_temp c join runner_orders_tmp r 
  USING(order_id) 
  WHERE r.pickup_time IS NOT NULL
  GROUP BY c.order_id, r.pickup_time, c.order_time
)
SELECT 
    pizza_count, 
    AVG(prep_time_minutes) AS avg_prep_time
FROM order_prep_time
GROUP BY pizza_count
ORDER BY pizza_count;

-- 4 What was the average distance travelled for each customer?
With Customers as 
(
   Select Distinct 
   c.Order_id ,
   c.customer_id as Customer,
   r.distance as dis,
   r.cancellation
   from customer_orders_temp c left join runner_orders_tmp r 
   using (order_id)
   Where r.cancellation is null
 )
 select Customer, Avg(dis) as avg_distance
 from Customers
 group by Customer;

-- 5 What was the difference between the longest and shortest delivery times for all orders?

select Max(duration) - Min(duration) as Difference
from runner_orders_tmp
where cancellation is null;

-- 6 What was the average speed for each runner for each delivery and do you notice any trend for these values?

Select order_id ,runner_id ,  Round((distance / (duration / 60.0))::Numeric,2) as Avg_speed
from runner_orders_tmp r 
Where cancellation is null ; 




-- 7 What is the successful delivery percentage for each runner?
select runner_id ,
Round((  100.0  * count(pickup_time) / count(order_id) )::Numeric , 2 ) as Succes_percentage
From runner_orders_tmp
group by runner_id


  
  
  
  