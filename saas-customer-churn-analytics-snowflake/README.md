# 🚀 SaaS Customer Churn & Retention Analytics | Snowflake Data Warehouse

**Author:** Abdallah Alameer Ali

## 📖 Project Overview & The Journey
Welcome to my Data Analytics portfolio project! This repository showcases a comprehensive, end-to-end data analytics solution built entirely on **Snowflake**. 

**The Journey:**
1. **Data Generation & Staging:** The project began with the conceptualization and generation of a robust, mock dataset representing 50,000 SaaS customers. 
2. **Cloud Migration via SnowSQL:** Using Snowflake's CLI (SnowSQL), the raw CSV files were successfully staged and bulk-loaded into the Snowflake environment.
3. **Advanced Data Modeling:** Applied advanced SQL techniques (CTEs, Window Functions, Time-Series Analysis) to transform raw data into actionable business intelligence.
4. **BI Semantic Layer:** Created optimized, production-ready `VIEWS` acting as a semantic layer for seamless integration with BI tools like Power BI.

This project serves as a practical application of advanced SQL to solve real-world SaaS challenges: measuring product stickiness, identifying silent churn, and quantifying revenue loss.

---

## 🏗️ Data Architecture & Schema
The data warehouse consists of three primary tables linked via `CUSTOMER_ID`:

* **`CUSTOMER_CHURN`**: The core dimension table tracking user lifecycle.
  * *Columns:* `CUSTOMER_ID`, `SIGNUP_DATE`, `CHURN_DATE`, `SUBSCRIPTION_PLAN`, `CONTRACT_TYPE`, `MONTHLY_FEE`, `SUPPORT_TICKETS`, `USAGE_HOURS`[cite: 4].
* **`PAYMENTS`**: The billing fact table recording financial transactions.
  * *Columns:* `PAYMENT_ID`, `CUSTOMER_ID`, `PAYMENT_DATE`, `AMOUNT`, `PAYMENT_STATUS`[cite: 4].
* **`SUPPORT_TICKETS_LOG`**: The operational fact table logging customer support interactions.
  * *Columns:* `TICKET_ID`, `CUSTOMER_ID`, `TICKET_DATE`, `CATEGORY`, `RESOLUTION_TIME_HOURS`, `SATISFACTION_SCORE`[cite: 4].

---

## 📂 Project Breakdown & Key Insights

### 📁 File 1: `01_DB&Table_Setup.sql`
* **Business Problem & Context:** Before analyzing data, the enterprise data warehouse needed a structured, scalable foundation.
* **Technical Highlights:** Created the `SAAS_DB` database and `ANALYTICS` schema[cite: 4]. Executed robust Data Definition Language (DDL) scripts to define tables with appropriate data types and successfully validated row counts (50,000 customers)[cite: 2, 4].

### 📁 File 2: `02_Data_Exploration_and_Joins.sql`
* **Business Problem & Context:** The business needed to understand the foundational drivers of revenue and churn. Does billing friction cause users to leave? Which support issues drive the most frustration?
* **Key Analytical Insights (Storytelling):**
  * **LTV Benchmarks:** Peak Customer Lifetime Value (LTV) reaches 1,790 USD, driven by long-term tenure (>800 days) rather than specific premium plans[cite: 2].
  * **The Payment Myth:** Interestingly, billing gateway friction is *not* a primary driver of attrition. The churn rate for users experiencing failed payments is 17.37%, almost identical to the 16.94% rate of users with seamless payments[cite: 2].
  * **Support Bottlenecks:** 'Account Access' tickets act as the highest churn driver, causing a 17.04% churn rate among impacted users[cite: 2]. 
* **Technical Highlights:** Heavy utilization of Multi-table `LEFT JOIN`s, `COALESCE` for NULL handling (hygienic LTV calculation), and Conditional Aggregation (`CASE WHEN`) to dynamically calculate churn percentages[cite: 2].

### 📁 File 3: `03_Window_Functions_Analytics.sql`
* **Business Problem & Context:** Transitioning from basic exploration to complex time-series analysis. The CFO needed a calculation of the "revenue snowball" loss, and the Customer Success team needed a system to detect declining engagement before a user officially churns.
* **Key Analytical Insights (Storytelling):**
  * **Exceptional Stickiness:** The platform's initial cohort (Jan 2022) demonstrates outstanding product-market fit, retaining 84.34% of users after 12 full months[cite: 1].
  * **Silent Churn Detection:** The Early Warning System successfully captured 16,527 instances where a customer's satisfaction (CSAT) dropped significantly below their own historical moving average[cite: 1].
  * **The Cost of Churn:** Unmitigated churn compounds exponentially. Cumulative recurring revenue lost to churn escalated to nearly 1.97M USD over the analyzed timeframe[cite: 1].
* **Technical Highlights:** Applied advanced analytical concepts including Cohort Framing (`DATEDIFF`), Moving Window Averages (`ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING`), Time-Series Running Totals (`SUM() OVER UNBOUNDED PRECEDING`), and `LAG()` functions[cite: 1].

### 📁 File 4: `04_Analytical_Views.sql`
* **Business Problem & Context:** BI tools (like Power BI or Tableau) should not process heavy joins or raw data. The objective was to build a clean "Semantic Layer" of production-ready `VIEWS` for executive and operational dashboards.
* **Key Analytical Insights (Storytelling):**
  * **Operational Agility:** The `VW_HIGH_RISK_CUSTOMERS` view acts as a daily live feed, successfully identifying 28,041 active accounts demonstrating operational risk signals (low CSAT, high ticket volume, or payment failures)[cite: 3].
  * **Proactive Targetting:** Caught high-value Enterprise accounts with perfect historical CSAT scores that were slipping into a "Medium Risk" category purely due to recent payment gateway failures[cite: 3].
* **Technical Highlights:** Created abstracted `VIEWS` using complex logic, integrated a `FULL OUTER JOIN` to align mismatched time-series data without dropping months, and implemented dynamic Risk Signal Mapping[cite: 3].

---

## 🛠️ Tech Stack & Skills Demonstrated
* **Cloud Platform:** Snowflake
* **Languages:** Advanced SQL (Snowflake SQL Dialect)
* **Concepts:** Data Modeling, Time-Series Analysis, Cohort Retention, Window Functions, Subqueries & CTEs, Business Storytelling, Data Engineering (Views & Semantic Layer).

## 🚀 How to Use This Repository
1. Navigate to the `data/` folder to find the csv files.
2. Review the SQL scripts in numerical order (`01` to `04`) to follow the logical progression from database setup to advanced analytics.
3. Check the bottom of each SQL file for documented **Executive Insights & Business Storytelling** comments.
