# 🏦 Case Study #4: Data Bank (FinTech & Cloud Storage)

## 📝 Introduction
There is a new innovation in the financial industry called Neo-Banks: new aged digital-only banks without physical branches. 
Data Bank is a Neo-Bank that goes a step further! They don't just manage money; they also provide cloud data storage to their customers. The catch? **The amount of data storage a customer receives is directly linked to their account balance.** 

This project aims to analyze customer movements across branches (nodes), track their financial transactions, calculate running balances, and forecast the exact data storage required for each customer based on different business scenarios.

## 🛠️ Tools & Technologies Used
* **Database:** PostgreSQL
* **Advanced SQL Techniques:** Recursive CTEs, Window Functions  , Percentiles (`PERCENTILE_CONT`), Conditional Aggregation.

## 📊 Datasets Used
1. **`regions`:** Contains the continents where Data Bank operates.
2. **`customer_nodes`:** Tracks the assignment of customers to specific branches (nodes) over time.
3. **`customer_transactions`:** Logs all financial movements (deposits, withdrawals, purchases).

---

## 🎯 Case Study Sections & Insights

### Section A: Customer Nodes Exploration (Spatial Analysis)
* Explored the geographical distribution of the bank's customers across different regions.
* Calculated the average and median duration customers stay in a specific node before being reallocated.
* Cleaned the data by filtering out "active/ongoing" records (handling `9999-12-31` outliers) to ensure accurate statistical percentiles (80th and 95th).

### Section B: Customer Transactions (Financial Analysis)
* Conducted historical analysis of customer deposits, withdrawals, and purchases.
* Tracked monthly transaction behaviors using pivot-style conditional aggregations.
* Computed the **Monthly Running Balance** for each customer using advanced Window Functions.
* Measured customer financial growth by calculating the percentage of users whose closing balance increased by more than 5% from their initial month.

### Section C: Data Allocation Challenge (Forecasting & What-If Analysis)
* Analyzed the required cloud storage capacity for the bank by translating financial balances into data bytes.
* Conducted a "What-If" analysis testing three different business scenarios for allocating data to customers:
  1. Allocation based on the current running balance.
  2. Allocation based on the average running balance.
  3. Allocation based on the maximum running balance.

---

## 💡 Key Business Takeaways
This case study demonstrates how a Data Analyst bridges the gap between raw database logs and strategic business planning. By mastering running balances and forecasting scenarios, the data can directly answer critical operational questions like: *"How many servers do we need to buy next month to cover our customers' data allocation?"*
