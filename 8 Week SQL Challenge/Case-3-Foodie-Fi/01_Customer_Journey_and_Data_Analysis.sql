/* ---------------------------------------------------------------------------
   Section A. Customer Journey
   Objective: Explore the onboarding journey for a sample of 8 customers.
   Insight: This query helps in understanding the logic of the data, showing 
   how customers transition from the initial 'trial' plan to paid subscriptions 
   (basic/pro) or if they cancel 'churn'.
   
    Note: Customer 11 started a trial and churned after exactly 7 days.
--------------------------------------------------------------------------- */
select s.customer_id,
s.plan_id,
p.plan_name,
s.start_date,
p.price
from subscriptions s join plans p
using (plan_id)
where s.customer_id in (1,2,11,12,13,14,15,16,18,19)
ORDER BY s.customer_id, s.start_date;




-- 1 How many customers has Foodie-Fi ever had?

Select count(Distinct customer_id) as total_customers
from subscriptions;








-- 2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select Extract(month from start_date) as month , count(Distinct customer_id) as customers
from subscriptions 
where plan_id = 0 
group by month 
order by month  ; 








-- 3 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

Select p.plan_name as plan_name ,  Count (  s.customer_id) as total
from subscriptions s join plans p
using (plan_id)
where Extract(Year from s.start_date ) > '2020'
group by plan_name
order by total desc;







-- 4 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Select 
sum(Case when plan_id = 4 then 1 Else 0 End ) as Churned_customers ,
ROUND(
  
  sum (Case when plan_id = 4 then 1 Else 0 End ) * 100 /COUNT(DISTINCT customer_id) 
,2)AS churn_percentage

FROM subscriptions;







-- 5 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with cte as 
(
  select s.customer_id,
s.plan_id,
p.plan_name,
s.start_date,
p.price,
Row_Number() over(partition by s.customer_id  ORDER BY s.start_date ) as num
from subscriptions s join plans p
using (plan_id)
  
)
select 
sum(Case when num = 2 And plan_id = 4 then 1 else 0 End) as churned_straight ,
Round (
SUM(Case when num = 2 And plan_id = 4 then 1 else 0 End) * 100.0 /Count(Distinct Customer_id),1
)
from cte ; 






-- 6 What is the number and percentage of customer plans after their initial free trial?
with cte2 as 
(
  select 
s.customer_id , 
p.plan_id,
p.plan_name,
s.start_date,
p.price,
row_number() over(partition by s.customer_id order by s.start_date ) as num
from subscriptions s join plans p 
using(plan_id)
)

select 
plan_name ,
Count(customer_id) as customer_count,
Round
(
  Count(customer_id) * 100.0 / (select count(Distinct customer_id) from 			subscriptions) ,1
  ) as percentage
from cte2
where num = 2 
group by plan_name
ORDER BY customer_count DESC;






-- 7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
with cte3 as 
(
select 
s.customer_id , 
p.plan_id,
p.plan_name,
s.start_date,
Lead(s.start_date) over(partition by s.customer_id order by s.start_date) as next_date
from subscriptions s join plans p 
using(plan_id)
)
select plan_name , count(customer_id) as count,
Round
(
  Count(customer_id) * 100.0 / (select count(Distinct customer_id) from 			subscriptions) ,1
  ) as percentage
from cte3
where start_date <= '2020-12-31' AND (next_date > '2020-12-31' OR next_date IS NULL)
group by plan_name
order by count desc;






--  8  How many customers have upgraded to an annual plan in 2020?
select count(distinct customer_id) 
from subscriptions
where Extract( year from start_date ) = '2020' And plan_id = 3;





-- 9 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with cte3 as 
(
  select customer_id , 
  plan_id,
  start_date as joined_date
  from subscriptions 
  where plan_id = 0 
), 
cte4 as 
(
  select customer_id,
  plan_id,
  start_date as upgrade_date
  from subscriptions
  where plan_id = 3 
)

select Round(Avg(upgrade_date - joined_date),2)
from cte3 c3 join cte4 c4
using(customer_id);





-- 11 How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with cte5 as 
(
  select customer_id , 
plan_id,
start_date ,
lead(plan_id) over(partition by customer_id  order by start_date) as next_plan
from subscriptions
)
select count(distinct customer_id)
from cte5
where plan_id = 2 AND next_plan = 1 
And Extract(year from start_date)  = '2020'


