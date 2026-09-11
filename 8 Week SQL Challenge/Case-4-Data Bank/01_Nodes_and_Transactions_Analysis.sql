--   A. Customer Nodes Exploration


-- 1 How many unique nodes are there on the Data Bank system?

select Count(Distinct node_id) from customer_nodes;



-- 2 What is the number of nodes per region?

 select r.region_name as Region , count(Distinct c.node_id)
 from regions r join customer_nodes c
 using(region_id)
 group by Region;
 
 
 
--  3 How many customers are allocated to each region?

 select r.region_name as Region , count(Distinct c.customer_id)
 from regions r join customer_nodes c
 using(region_id)
 group by Region;
 
 
 
--  4 How many days on average are customers reallocated to a different node?

select Round(Avg(end_date - start_date ),2)
from customer_nodes
where end_date <> '9999-12-31';


-- 5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

select 
r.region_name as Region,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY c.end_date - c.start_date) as median_days,
PERCENTILE_CONT(0.8) WITHIN GROUP ( ORDER BY C.END_DATE - C.start_date) AS percentile_80_days,
PERCENTILE_CONT(0.95) WITHIN GROUP ( ORDER BY  c.end_date - c.start_date) as percentile_95_days
from regions r join customer_nodes c
using(region_id)
where c.end_date <>'9999-12-31'
group by region;
 
 
 
 
 
 
 
 
--  B. Customer Transactions

-- 1 What is the unique count and total amount for each transaction type?

select txn_type,
count(Distinct customer_id) as unique_count, sum(txn_amount) as Total_amount
from customer_transactions
group by txn_type;




-- 2 What is the average total historical deposit counts and amounts for all customers?
with customers_cte as 
(
  select customer_id , count(txn_amount) as txn_count , sum(txn_amount) as Amount
  from customer_transactions
  where txn_type = 'deposit'
  group by customer_id
)
select Round(Avg(txn_count),0) as Avg_txns, Round(Avg(Amount),2) as Avg_total_Amount 
from customers_cte;





-- 3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with cte as 
(
  select customer_id ,
  EXTRACT(MONTH FROM txn_date) AS MONTH,
  sum(Case when txn_type = 'deposit'  then 1 Else 0 End) as count_deposit,
  sum(Case when txn_type = 'purchase'  then 1 Else 0 End) as count_purchase,
  sum(Case when txn_type = 'withdrawal'  then 1 Else 0 End) as count_withdrawal
  from customer_transactions
  group by Customer_id,MONTH
)

SELECT 
  month, 
  COUNT(customer_id) AS customer_count
FROM cte 
WHERE count_deposit > 1 
  AND (count_purchase >= 1 OR count_withdrawal >= 1) 
GROUP BY month
ORDER BY month;
 
 
 
 
--  4 What is the closing balance for each customer at the end of the month?

WITH monthly_net AS (
  SELECT 
    customer_id,
    EXTRACT(MONTH FROM txn_date) AS month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE txn_amount * -1 END) AS net_amount
  FROM customer_transactions  
  GROUP BY customer_id, EXTRACT(MONTH FROM txn_date)
)


select customer_id , Month ,SUM(net_amount) over(partition by customer_id order by month ) as Running_Balance
from monthly_net;





 
 
--   5  What is the percentage of customers who increase their closing balance by more than 5%?
WITH monthly_net AS
  (
    SELECT 
      customer_id,
      EXTRACT(MONTH FROM txn_date) AS month,
      SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE txn_amount * -1 END)  AS net_amount
    FROM customer_transactions  
    GROUP BY customer_id, EXTRACT(MONTH FROM txn_date)
  ),
running_balances as 
  (
    select customer_id , month , sum(net_amount) over( partition by customer_id   order by month ) as running_balance 
    from monthly_net
  ),
  
first_last_balances as 
  (
    select DISTINCT  customer_id , 
    first_value(running_balance) over(partition by customer_id order by month) as 		first_balance , 
    last_value(running_balance) over(partition by customer_id order by month 
                                    rows between unbounded PRECEDING AND unbounded 	following ) as last_balance
    from running_balances
  )
  
  
 SELECT 
  ROUND(COUNT(customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions), 2) AS percentage_of_customers
FROM first_last_balances 
WHERE 100 * (last_balance - first_balance) / NULLIF(ABS(first_balance), 0) > 5;

