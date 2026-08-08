USE DATABASE SAAS_DB;
USE SCHEMA SAAS_DB.ANALYTICS;




 -- =============================================================================
-- QUESTION 1: Customer Lifetime Value (LTV) & Tenure Analysis
-- BUSINESS INTENT: Calculate total realized revenue per customer (Successful payments only)
--                  and analyze customer tenure in days alongside subscription plans.
-- TECHNICAL CONCEPTS: CTEs, LEFT JOIN, COALESCE, DATEDIFF, GROUP BY.
-- =============================================================================

with successful_payments as(
    select  customer_id, sum(amount) as TOTAL_SUCCESSFUL_REVENUE
    from payments 
    where payment_status = 'Success'  
    group by customer_id
)

select
    c.customer_id,
    c.subscription_plan,
    
    --Handle NULL payments as 0
    coalesce(sp.TOTAL_SUCCESSFUL_REVENUE,0) as TOTAL_REVENUE,
    
    --Calculating customer age in days
    DATEDIFF(day,c.signup_date,coalesce(c.churn_date,current_date())) as Tenure_Days
        
from customer_churn c 
left join successful_payments sp 
    on c.customer_id = sp.customer_id
order by TOTAL_REVENUE desc;
/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q1):
1. Full Data Hygiene: Analyzed 100% of the customer base (50,000 users). 
   Non-paying or failed-payment users were cleanly mapped to $0.00 revenue.
2. Max LTV Benchmark: Peak Lifetime Value reaches $1,790.00 (Customer CUST-129278), 
   strongly driven by long-term tenure (>800 to 1,200+ days).
3. Plan Contribution: Revenue growth is heavily tied to retention duration 
   across Pro and Basic tiers rather than high churn rates.
4. Executive Action: Customer Success should focus on 1-year retention milestones, 
   as users staying past 800 days yield the highest aggregate LTV.
--------------------------------------------------------------------------------
*/






------------------------------------------------------------------------------------------------------------------------------














-- =============================================================================
-- QUESTION 2: Impact of Failed Payments on Customer Churn (Revenue Risk)
-- BUSINESS INTENT: Measure whether experiencing failed payment transactions correlates
--                  with higher customer churn rates to detect friction in billing.
-- TECHNICAL CONCEPTS: CTEs, Conditional Aggregation (CASE WHEN), JOIN, Churn % Calculation.
-- =============================================================================

with failed_payment_custs as (

    select distinct(customer_id),payment_status from payments
    where payment_status = 'Failed'

)
select
    case 
        when f.payment_status is not null then 'Experienced Payment Failure'
        when f.payment_status is null then 'No Payment Failures' 
        END  as PAYMENT_EXPERIENCE_CATEGORY,
        
        count(c.customer_id) AS TOTAL_CUSTOMERS,
        COUNT(c.CHURN_DATE) AS CHURNED_CUSTOMERS,
        ROUND(COUNT(c.CHURN_DATE) / count(c.customer_id) * 100 , 2) AS CHURN_RATE_PCT
        

from customer_churn c 
left join failed_payment_custs f 
on c.customer_id = f.customer_id
group by PAYMENT_EXPERIENCE_CATEGORY;

/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q2):
1. Volume Exposure: 10,608 out of 50,000 customers (~21.2%) experienced at least 
   one failed payment transaction during their lifecycle.
2. Low Correlation to Churn: The Churn Rate for users with payment failures is 17.37%, 
   compared to 16.94% for users with seamless payments (a minor variance of +0.43%).
3. Key Root Cause Finding: Billing gateway friction/payment failures are NOT the 
   primary driver of customer attrition in this business.
4. Executive Action: Avoid over-allocating engineering/marketing budgets to payment-retry 
   dunning systems. Instead, pivot retention strategies toward product engagement and support.
--------------------------------------------------------------------------------
*/










------------------------------------------------------------------------------------------------------------------------------














-- =============================================================================
-- QUESTION 3: Support Ticket Satisfaction (CSAT) & Resolution Time vs Churn
-- BUSINESS INTENT: Identify which support ticket categories and resolution delays
--                  cause the highest churn rate and lower satisfaction scores (CSAT).
-- TECHNICAL CONCEPTS: Multi-table JOIN, Aggregations (AVG, COUNT), Grouping by Category & Churn Status.
-- =============================================================================

select 

 t.category,
 count(DISTINCT t.ticket_id) as TOTAL_TICKETS,
 COUNT(distinct c.customer_id) as TOTAL_CUSTOMERS,
 Round(Avg(t.RESOLUTION_TIME_HOURS),2) as AVG_RESOLUTION_HOURS,
 ROUND(Avg(t.SATISFACTION_SCORE),2) as AVG_CSAT,
 
 --Churned Customers by Ticket Category
COUNT(DISTINCT CASE WHEN c.CHURN_DATE IS NOT NULL THEN c.CUSTOMER_ID END) AS CHURNED_CUSTOMERS,

--Actual Churn Rate by Category
ROUND(
        COUNT(DISTINCT CASE WHEN c.CHURN_DATE IS NOT NULL THEN c.CUSTOMER_ID END) * 100.0 / 
        NULLIF(COUNT(DISTINCT c.CUSTOMER_ID), 0), 2
      ) AS CHURN_RATE_PCT
    
from support_tickets_log t join customer_churn c
on t.customer_id = c.customer_id 
group by t.category
order by CHURN_RATE_PCT DESC;
/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q3):
1. Highest Churn Driver: 'Account Access' tickets lead in churn rate at 17.04% 
   (2,333 churned users out of 13,691 impacted customers).
2. Volume Bottleneck: 'Technical Issue' generates the largest ticket volume with 35,919 tickets 
   across 25,652 users, driving the highest absolute churn volume (4,343 churned users).
3. SLA & Satisfaction Baseline: Resolution time is uniform at ~12 hours across categories, 
   with CSAT scores hovering around a moderate 3.27 to 3.32 out of 5.00.
4. Executive Action: Product team should automate self-service account recovery to eliminate 
   login friction, while Engineering prioritizes core bug fixes to cut down the 35k+ technical ticket load.
--------------------------------------------------------------------------------
*/
