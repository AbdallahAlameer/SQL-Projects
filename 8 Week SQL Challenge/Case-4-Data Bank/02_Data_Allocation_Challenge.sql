-- 1. جدول بيولد الشهور من 1 لـ 4 لكل العملاء
WITH customer_months AS (
  SELECT DISTINCT customer_id, m.month
  FROM customer_transactions
  CROSS JOIN generate_series(1, 4) AS m(month)
),

-- 2. حساب صافي حركة كل شهر (إيداع موجب، وسحب/شراء سالب)
monthly_net AS (
  SELECT 
    customer_id,
    EXTRACT(MONTH FROM txn_date) AS month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE txn_amount * -1 END) AS net_amount
  FROM customer_transactions  
  GROUP BY customer_id, EXTRACT(MONTH FROM txn_date)
),

-- 3. الرصيد التراكمي في نهاية كل شهر لكل عميل
customer_monthly_balances AS (
  SELECT 
    cm.customer_id,
    cm.month,
    COALESCE(mn.net_amount, 0) AS net_amount,
    SUM(COALESCE(mn.net_amount, 0)) OVER(
      PARTITION BY cm.customer_id 
      ORDER BY cm.month
    ) AS closing_balance
  FROM customer_months cm
  LEFT JOIN monthly_net mn 
    ON cm.customer_id = mn.customer_id AND cm.month = mn.month
)

--  Option 1: data is allocated based off the amount of money at the end of the previous month

select month,
sum(Greatest(closing_balance,0)) as total_byts
from customer_monthly_balances
group by month
order by month

,customer_avg_balances as 
(
 select customer_id,
  month , 
  Avg(closing_balance) over(partition by customer_id order by month) as avg_balance
 from customer_monthly_balances
)

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
select 
	month,
    Round(Sum(Greatest(avg_balance,0)),2) as total_allocation_bytes
from customer_avg_balances
group by month 
order by month

,
Customer_max_balance as 
(
  select customer_id ,
  month,
  Max(closing_balance) over( partition by customer_id order by month ) as max_balance
  from customer_monthly_balances
)
-- Option 3: data is updated real-time

select month ,
sum(GReatest(max_balance,0)) as total_allocation_bytes
from Customer_max_balance
group by month
order by month



/* 
================================================================================
Section C: Data Allocation Challenge (What-If & Capacity Planning Analysis)
================================================================================
BUSINESS CONTEXT:
Data Bank provides cloud data storage to its customers based on their account balances 
(1 USD balance = 1 Byte of data allocation). Negative balances receive 0 Bytes (using GREATEST(balance, 0)).
The goal is to forecast and compare total storage requirements across 3 different allocation scenarios.

LOGIC APPLIED:
1. customer_months: Built a scaffold using CROSS JOIN with generate_series(1, 4) to ensure no missing months (Gap-Filling).
2. monthly_net: Aggregated net cash flow per customer per month (deposits as positive, withdrawals/purchases as negative).
3. customer_monthly_balances: Computed monthly closing running balances via SUM() OVER().

SCENARIOS EVALUATED:
- Option 1 (Closing Balance): Storage based on exact balance at the end of each month.
- Option 2 (Average Balance): Storage based on cumulative running average balance (smoothest demand).
- Option 3 (Max Balance): Storage based on peak balance reached up to that month (customer-friendly, high reserve).

SUMMARY RESULTS (Total Allocated Bytes per Month):
+-------+--------------------+--------------------+--------------------+
| Month | Option 1 (Closing) | Option 2 (Average) | Option 3 (Max)     |
+-------+--------------------+--------------------+--------------------+
|   1   |      235,595       |     235,595.00     |      235,595       |
|   2   |      261,508       |     226,537.00     |      345,177       |
|   3   |      260,971       |     219,671.33     |      422,554       |
|   4   |      264,857       |     220,694.75     |      454,606       |
+-------+--------------------+--------------------+--------------------+

STRATEGIC TAKEAWAYS:
1. Option 2 is the most cost-effective and resource-efficient for infrastructure (~220K bytes in month 4).
2. Option 3 requires the highest infrastructure investment (~454K bytes in month 4, nearly 2x Option 2) 
   because peak balances are retained even if funds are withdrawn.
3. Option 1 represents a realistic middle-ground tracking true point-in-time liabilities (~264K bytes).
================================================================================
*/

