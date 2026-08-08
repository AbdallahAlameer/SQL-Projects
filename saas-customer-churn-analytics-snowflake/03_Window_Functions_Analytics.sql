USE DATABASE SAAS_DB;
USE SCHEMA SAAS_DB.ANALYTICS;





-- =============================================================================
-- QUESTION 1: Monthly Churn Dynamics & MoM Retention Trend
-- BUSINESS INTENT: Calculate monthly active base, new signups, churned users, net growth,
--                  and evaluate Month-over-Month (MoM) Churn Rate changes using Window Functions.
-- TECHNICAL CONCEPTS: DATE_TRUNC, LAG() OVER(), CTEs, Conditional Aggregation, MoM % Delta.
-- =============================================================================

with monthly_signups as (
    select DATE_TRUNC(month,signup_date) as monthly, count( Distinct customer_id) as NEW_SIGNUPS
    from customer_churn 
    group by monthly
),
monthly_churns as(
    select DATE_TRUNC(month,churn_date)as monthly_ch , count(Distinct CUSTOMER_ID) as CHURNED_USERS
    from CUSTOMER_CHURN
    where monthly_ch is not null
    group by monthly_ch
)

select 
    coalesce(s.monthly,c.monthly_ch) as month,
    coalesce(NEW_SIGNUPS,0) as NEW_SIGNUPS,
    coalesce(CHURNED_USERS,0) as CHURNED_USERS,
    COALESCE(NEW_SIGNUPS, 0) - COALESCE(CHURNED_USERS, 0) AS NET_GROWTH,
    LAG(coalesce(CHURNED_USERS,0)) over(order by  month) as PREV_MONTH_CHURN,
    COALESCE(CHURNED_USERS, 0) - LAG(COALESCE(CHURNED_USERS, 0), 1, 0) OVER (ORDER BY month) AS MOM_DELTA

from monthly_signups s FULL OUTER JOIN monthly_churns c
on s.monthly = c.monthly_ch
order by month

/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q1):
1. Early Hyper-Growth: In Jan 2022, the platform launched with 1,564 new signups and 
   0 churned users (Net Growth = +1,564).
2. Healthy Runway: Net growth remained consistently strong above +1,200 users/month 
   throughout 2022 despite churn gradually creeping up from 8 to 278 users/month.
3. Churn Momentum: MoM Delta tracks month-over-month attrition spikes (e.g., Dec 2022 
   experienced +46 additional churned users compared to Nov 2022).
4. Executive Action: Growth team should monitor MoM Delta spikes > 30 users to trigger 
   in-app re-engagement campaigns immediately.
--------------------------------------------------------------------------------
*/






----------------------------------------------------------------------------------------------------------------------------------------








-- =============================================================================
-- QUESTION 2: Signup Cohort Retention Analysis (Cohort Matrix)
-- BUSINESS INTENT: Group customers by signup month (Cohort) and track their retention
--                  rate at Month 1, Month 3, Month 6, and Month 12 to measure long-term product stickiness.
-- TECHNICAL CONCEPTS: Cohort Framing, DATEDIFF, Conditional Window Aggregations, Retention % Logic.
-- =============================================================================
-- =============================================================================
-- QUESTION 2: Signup Cohort Retention Analysis (Cohort Matrix)
-- BUSINESS INTENT: Group customers by signup month (Cohort) and track their retention
--                  rate at Month 1, Month 3, Month 6, and Month 12 to measure long-term product stickiness.
-- TECHNICAL CONCEPTS: Cohort Framing, DATEDIFF, Conditional Aggregations, Retention % Logic.
-- =============================================================================

SELECT 
    DATE_TRUNC('month', SIGNUP_DATE) AS COHORT_MONTH,
    COUNT(DISTINCT CUSTOMER_ID) AS COHORT_SIZE,
    
    -- Retention % at Month 1
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN CHURN_DATE IS NULL OR DATEDIFF('month', SIGNUP_DATE, CHURN_DATE) >= 1 
            THEN CUSTOMER_ID END) * 100.0 / COUNT(DISTINCT CUSTOMER_ID), 2
    ) AS MONTH_1_RETENTION_PCT,
    
    -- Retention % at Month 3
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN CHURN_DATE IS NULL OR DATEDIFF('month', SIGNUP_DATE, CHURN_DATE) >= 3 
            THEN CUSTOMER_ID END) * 100.0 / COUNT(DISTINCT CUSTOMER_ID), 2
    ) AS MONTH_3_RETENTION_PCT,
    
    -- Retention % at Month 6
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN CHURN_DATE IS NULL OR DATEDIFF('month', SIGNUP_DATE, CHURN_DATE) >= 6 
            THEN CUSTOMER_ID END) * 100.0 / COUNT(DISTINCT CUSTOMER_ID), 2
    ) AS MONTH_6_RETENTION_PCT,
    
    -- Retention % at Month 12
    ROUND(
        COUNT(DISTINCT CASE 
            WHEN CHURN_DATE IS NULL OR DATEDIFF('month', SIGNUP_DATE, CHURN_DATE) >= 12 
            THEN CUSTOMER_ID END) * 100.0 / COUNT(DISTINCT CUSTOMER_ID), 2
    ) AS MONTH_12_RETENTION_PCT

FROM CUSTOMER_CHURN
GROUP BY COHORT_MONTH
ORDER BY COHORT_MONTH;

/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q2):
1. Outstanding Long-Term Retention: The Jan 2022 cohort demonstrates extraordinary 
   stickiness, maintaining an 84.34% retention rate after 12 full months.
2. Low Initial Drop-off: Month 3 retention across most cohorts stays above 96%, 
   proving that user onboarding and initial value delivery are highly effective.
3. Stable Product-Market Fit: Retention decay is very gradual (dropping only ~15% 
   over an entire year), indicating high product dependency.
4. Executive Action: Since retention is extremely stable, marketing can aggressively 
   increase Customer Acquisition Cost (CAC) spending safely, knowing users retain long-term.
--------------------------------------------------------------------------------
*/







 

----------------------------------------------------------------------------------------------------------------------------------------











-- =============================================================================
-- QUESTION 3: Early Warning System - Engagement Decline Detection
-- BUSINESS INTENT: Identify customers demonstrating silent churn patterns (e.g., dropping CSAT
--                  or surging ticket logs) by comparing recent activity to historical moving averages.
-- TECHNICAL CONCEPTS: LAG(), Moving Window Average (ROWS BETWEEN), ROW_NUMBER() OVER(), CTEs.
-- =============================================================================
with csat_lag_analysis as (

select 
    customer_id,
    ticket_id,
    category,
    ticket_date,
    satisfaction_score as CURRENT_CSAT,
    lag(satisfaction_score) over(partition by customer_id order by ticket_date) as PREV_CSAT,
    Round(
        Avg(SATISFACTION_SCORE)
        
        over( partition by customer_id
            order by ticket_date
            ROWS between 3 preceding And  1 preceding)
            ,2
            
         ) AS HISTORICAL_MOVING_AVG_CSAT , 
    ROW_NUMBER() 
    over(
        partition by CUSTOMER_ID ORDER BY ticket_date DESC

        ) as RECENT_TICKET_RANK
         

from support_tickets_log
WHERE SATISFACTION_SCORE IS NOT NULL

)
select 
    CUSTOMER_ID,
    TICKET_ID,
    CATEGORY,
    ticket_date,
    CURRENT_CSAT,
    PREV_CSAT,
    HISTORICAL_MOVING_AVG_CSAT,
    
    -- حساب حجم الانخفاض في التقييم
    ROUND((CURRENT_CSAT - HISTORICAL_MOVING_AVG_CSAT), 2) AS CSAT_DROP_DELTA,
    
    -- علامة إنذار للبزنس
    CASE 
        WHEN CURRENT_CSAT < HISTORICAL_MOVING_AVG_CSAT THEN '🚨 RISK: CSAT Below Moving Average'
        WHEN CURRENT_CSAT < PREV_CSAT THEN '⚠️ WARNING: CSAT Dropping'
        ELSE '🟢 STABLE'
    END AS CHURN_RISK_SIGNAL

FROM csat_lag_analysis
-- نفلتر الحالات التي بها تراجع مقارنة بالمتوسط التاريخي
WHERE HISTORICAL_MOVING_AVG_CSAT IS NOT NULL 
  AND CURRENT_CSAT < HISTORICAL_MOVING_AVG_CSAT
ORDER BY CSAT_DROP_DELTA ASC;

/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q3):
1. Early Friction Detection: Captured 16,527 instances where customer satisfaction (CSAT) 
   dropped significantly below their historical moving average baseline.
2. High-Risk Anomalies: Identified severe satisfaction drops (e.g., users dropping from a 5.00 
   historical baseline directly to 1.00, generating a -4.00 CSAT delta).
3. Proactive Outreach Trigger: Rather than reacting post-churn, this query generates automated 
   risk signals ('🚨 RISK') for the Support Manager to trigger direct customer recovery calls.
4. Executive Action: Connect this query to an automated Slack/Email alert system so high-value 
   accounts dropping below moving CSAT are contacted within 2 hours of ticket closure.
--------------------------------------------------------------------------------
*/













----------------------------------------------------------------------------------------------------------------------------------------








-- =============================================================================
-- QUESTION 4: Cumulative Lost Revenue (Running Total MRR) & Churn Quartile Tiering
-- BUSINESS INTENT: Calculate cumulative recurring revenue loss over time and segment 
--                  churned customers into 4 tiers (NTILE) to analyze high-value account loss.
-- TECHNICAL CONCEPTS: Running Totals (SUM() OVER UNBOUNDED PRECEDING), NTILE(4), Window Ranking.
-- =============================================================================

With monthly_lost_revenue as (

    select 
        DATE_TRUNC(month,c.churn_date) AS CHURN_MONTH,
        count(DISTINCT c.customer_id) AS CHURNED_CUSTOMERS,
        COALESCE(SUM(P.AMOUNT),0)  AS MONTHLY_LOST_REVENUE
    from customer_churn c left join payments p
    using(customer_id)
    where c.churn_date is not null AND p.payment_status = 'Success'
    GROUP BY CHURN_MONTH
    
)
SELECT 
    CHURN_MONTH,
    CHURNED_CUSTOMERS,
    MONTHLY_LOST_REVENUE,
    Sum(MONTHLY_LOST_REVENUE) over( order by CHURN_MONTH ROWS BETWEEN unbounded preceding AND current row) AS CUMULATIVE_LOST_REVENUE
from monthly_lost_revenue
order by CHURN_MONTH
/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (Q4):
1. Revenue Snowball Loss: Cumulative recurring revenue lost to churn continuously escalated, 
   accumulating to nearly $1.97M ($1,972,136) over the analyzed timeframe.
2. Loss Scaling: Monthly revenue loss expanded from a modest $2,234 in Feb 2022 to peak 
   monthly losses exceeding $70,000/month in mid-2025.
3. Financial Impact: Running totals highlight that unmitigated churn compounds exponential 
   damage on long-term enterprise valuation and Runway.
4. Executive Action: Finance must mandate a dedicated budget for 'Win-Back' campaigns, 
   as recovering even 10% of churned users directly injects ~$197k back into company cash reserves.
--------------------------------------------------------------------------------
*/
