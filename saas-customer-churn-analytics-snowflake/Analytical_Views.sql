USE DATABASE SAAS_DB;
USE SCHEMA SAAS_DB.ANALYTICS;


-- =============================================================================
-- VIEW 1: VW_CUSTOMER_360_SUMMARY (Customer 360 Profile Layer)
-- BUSINESS INTENT: Consolidate granular customer attributes (Plan Details, Tenure in Days/Months, 
--                  Lifetime Value / LTV, Total Support Tickets, and Average CSAT) into a single 
--                  unified profile for flexible BI slicing and dicing.
-- TECHNICAL CONCEPTS: CREATE VIEW, Multi-table LEFT JOINs, Customer-level Aggregations, COALESCE.
-- =============================================================================
-- =============================================================================
-- VIEW 1: VW_CUSTOMER_360_SUMMARY (Customer 360 Profile Layer)
-- BUSINESS INTENT: Consolidate granular customer attributes into a single 
--                  unified profile for flexible BI slicing and dicing.
-- TECHNICAL CONCEPTS: CREATE VIEW, Multi-table LEFT JOINs, Customer-level Aggregations.
-- =============================================================================

CREATE OR REPLACE VIEW VW_CUSTOMER_360_SUMMARY AS

 WITH customer_payments AS (
    SELECT 
        CUSTOMER_ID,
        SUM(AMOUNT) AS TOTAL_LTV
    FROM SAAS_DB.ANALYTICS.PAYMENTS
    WHERE PAYMENT_STATUS = 'Success'
    GROUP BY CUSTOMER_ID
),

 CUSTOMER_TICKETS AS (
    SELECT 
        CUSTOMER_ID,
        COUNT(DISTINCT TICKET_ID) AS TOTAL_SUPPORT_TICKETS,
        AVG(SATISFACTION_SCORE) AS CSAT_SCORE
    FROM SAAS_DB.ANALYTICS.SUPPORT_TICKETS_LOG
    GROUP BY CUSTOMER_ID
)

 SELECT 
    c.CUSTOMER_ID,
    c.SIGNUP_DATE,
    c.SUBSCRIPTION_PLAN AS PLAN,
    
     CASE 
        WHEN c.CHURN_DATE IS NOT NULL THEN 'Churned'
        ELSE 'Active'
    END AS STATUS,
    
     DATEDIFF('day', c.SIGNUP_DATE, COALESCE(c.CHURN_DATE, CURRENT_DATE())) AS TENURE_DAYS,
    
     COALESCE(p.TOTAL_LTV, 0) AS TOTAL_LTV,
    
     COALESCE(t.TOTAL_SUPPORT_TICKETS, 0) AS TOTAL_SUPPORT_TICKETS,
    ROUND(COALESCE(t.CSAT_SCORE, 0), 2) AS AVG_CSAT

FROM SAAS_DB.ANALYTICS.CUSTOMER_CHURN c
LEFT JOIN CUSTOMER_PAYMENTS p ON c.CUSTOMER_ID = p.CUSTOMER_ID
LEFT JOIN CUSTOMER_TICKETS t ON c.CUSTOMER_ID = t.CUSTOMER_ID;






-- =============================================================================
-- VIEW 2: VW_MONTHLY_EXECUTIVE_METRICS (Executive KPI & Trend Feed)
-- BUSINESS INTENT: Aggregate monthly SaaS performance metrics (New Signups, Churned Base, Net Growth,
--                  and Cumulative Lost Revenue) to directly feed high-level Executive Dashboards.
-- TECHNICAL CONCEPTS: VIEW abstraction over CTEs, Window Running Totals, Time-Series Grouping.
-- =============================================================================
CREATE or replace view VW_MONTHLY_EXECUTIVE_METRICS AS

with monthly_signups as (
    select 
        DATE_TRUNC(month,signup_date) as month,
        count(DISTINCT c.CUSTOMER_ID) as New_Signups
    from customer_churn c 
    group by month
),
monthly_churns as (
    select 
        DATE_TRUNC(MONTH,c.churn_date) as month ,
        COUNT(Distinct C.CUSTOMER_ID) AS CHURNED_CUSTOMERS ,
        COALESCE(Sum(p.amount),0) as MONTHLY_LOST_REVENUE
    from customer_churn c left join payments p
    on c.customer_id = p.customer_id AND P.PAYMENT_STATUS = 'Success'
    WHERE churn_date is not null
    group by month 
)
select 
    COALESCE(s.MONTH, c.MONTH) AS MONTH,
    COALESCE(s.NEW_SIGNUPS, 0) AS NEW_SIGNUPS,
    COALESCE(c.CHURNED_CUSTOMERS, 0) AS CHURNED_CUSTOMERS,
    COALESCE(s.NEW_SIGNUPS, 0) - COALESCE(c.CHURNED_CUSTOMERS, 0) AS NET_GROWTH,
    COALESCE(c.MONTHLY_LOST_REVENUE, 0) AS MONTHLY_LOST_REVENUE,
    
    SUM(COALESCE(c.MONTHLY_LOST_REVENUE, 0)) OVER (
        ORDER BY COALESCE(s.MONTH, c.MONTH) 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CUMULATIVE_LOST_REVENUE

 FROM monthly_signups s
 FULL OUTER JOIN monthly_churns c 
 ON s.MONTH = c.MONTH;













-- =============================================================================
-- VIEW 3: VW_HIGH_RISK_CUSTOMERS (Operational Early Warning Feed)
-- BUSINESS INTENT: Filter and dynamically flag active/recent accounts demonstrating silent churn 
--                  signals (CSAT drops, support friction, payment issues) to empower Customer Success teams.
-- TECHNICAL CONCEPTS: Dynamic View Filtering, Risk Signal Mapping (CASE WHEN), Window Functions in Views.
-- =============================================================================

CREATE OR REPLACE VIEW VW_HIGH_RISK_CUSTOMERS AS

 
WITH payment_friction AS (
    SELECT 
        CUSTOMER_ID, 
        COUNT(PAYMENT_ID) AS FAILED_PAYMENTS
    FROM SAAS_DB.ANALYTICS.PAYMENTS
    WHERE PAYMENT_STATUS = 'Failed'
    GROUP BY CUSTOMER_ID
)

 
SELECT 
    c.CUSTOMER_ID,
    c.PLAN,
    c.TENURE_DAYS,
    c.TOTAL_SUPPORT_TICKETS,
    c.AVG_CSAT,
    COALESCE(p.FAILED_PAYMENTS, 0) AS FAILED_PAYMENTS,
    
    CASE 
        WHEN c.AVG_CSAT < 2.5 OR c.TOTAL_SUPPORT_TICKETS >= 8 THEN '🚨 CRITICAL RISK (Action Required)'
        WHEN c.AVG_CSAT < 3.2 OR c.TOTAL_SUPPORT_TICKETS >= 5 OR COALESCE(p.FAILED_PAYMENTS, 0) > 0 THEN '⚠️ MEDIUM RISK (Monitor)'
        ELSE '🟡 LOW RISK'
    END AS RISK_LEVEL

FROM VW_CUSTOMER_360_SUMMARY c
LEFT JOIN payment_friction p 
    ON c.CUSTOMER_ID = p.CUSTOMER_ID
 
WHERE c.STATUS = 'Active' 
  AND (c.AVG_CSAT < 3.2 OR c.TOTAL_SUPPORT_TICKETS >= 5 OR COALESCE(p.FAILED_PAYMENTS, 0) > 0)
ORDER BY c.AVG_CSAT ASC;
/*
--------------------------------------------------------------------------------
📌 BUSINESS STORYTELLING & EXECUTIVE INSIGHTS (VIEW 3):
1. Risk Exposure: Identified 28,041 active accounts demonstrating operational 
   risk signals (low CSAT, high ticket volume, or payment failures).
2. Payment Friction Target: Successfully caught high-value Enterprise/Pro accounts with 
   perfect 5.00 CSAT scores that are slipping into Medium Risk solely due to payment failures (1-2 attempts).
3. Operational Impact: Provides Customer Success and Finance teams with a daily prioritized 
   action list to fix billing issues and support friction before users churn.
--------------------------------------------------------------------------------
*/