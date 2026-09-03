-- Section C: Challenge Payment Question
-- 
-- Business Purpose:
-- This script generates a detailed 'payments' table for the year 2020. 
-- Since the original 'subscriptions' table only logs the start date of a plan, 
-- a Recursive CTE is utilized to dynamically expand these time periods into 
-- individual monthly payment rows. 
--
-- Key Logic Applied:
-- 1. Excluded trial plans (plan_id = 0) as they do not generate revenue.
-- 2. Handled 'churn' events to stop generating payments once a customer cancels.
-- 3. Filtered 'Pro Annual' plans to bill only once per year without monthly loops.
--------------------------------------------------------------------------- */



WITH RECURSIVE base_table AS 
(
  
  select s.customer_id,
  s.plan_id,
  p.plan_name,
  s.start_date,
  COALESCE(lead(s.start_date) over( partition by s.customer_id order by  s.start_date ),
          '2020-12-31' )  as next_date
  from subscriptions s left join plans p 
  using(plan_id)
  where s.plan_id <> 0
),
payments_cte AS 
(
  --  (Base Case)
  SELECT 
    customer_id, 
    plan_id, 
    plan_name, 
    start_date AS payment_date,
    next_date
  FROM base_table
  WHERE plan_id != 4   

  UNION ALL

  --  (Recursive Step)
  SELECT 
    customer_id, 
    plan_id, 
    plan_name, 
    (payment_date + INTERVAL '1 month')::DATE, 
    next_date
  FROM payments_cte
  WHERE (payment_date + INTERVAL '1 month')::DATE < next_date
    AND plan_id != 3
)



SELECT * 
FROM payments_cte
ORDER BY customer_id, payment_date;

















