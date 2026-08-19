# 🍜 Case Study #1: Danny's Diner

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/SQL-Data_Analysis-orange?style=for-the-badge" alt="SQL"/>
</p>

## 📌 Business Context
Danny opened a restaurant featuring three Japanese comfort foods: Sushi, Curry, and Ramen. This project analyzes customer visit patterns, spending behaviors, dish preferences, and loyalty program performance to help Danny's Diner optimize its business strategy.

**Author:** Abdallah Alameer Ali

---

## 🗄️ Entity Relationship Diagram (ERD)

```text
       MEMBERS                        SALES                         MENU
+---------------+             +---------------+             +---------------+
| customer_id   |<---+   +--->| customer_id   |        +--->| product_id    |
| join_date     |    |   |    | order_date    |        |    | product_name  |
+---------------+    +---+    | product_id    |--------+    | price         |
                              +---------------+             +---------------+
```
## 📂 Repository Contents

* **`schema.sql`**: Contains the DDL and DML queries to create the database schema and insert the sample data.
* **`solution.sql`**: Contains the exact SQL queries used to solve the business questions. Techniques demonstrated include **CTEs**, **Window Functions** (`DENSE_RANK`, `ROW_NUMBER`,), **Aggregations**, and **`CASE WHEN` statements**.

---

## 🎯 Business Questions Addressed

Through SQL analysis, this project answers the following core business questions (refer to `solution.sql` for the detailed code):

### Customer Behavior & Spending
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?

### Loyalty Program & Conversion
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What are the total items and amount spent for each member before they joined?
9. How many loyalty points would each customer have (assuming $1 = 10 points, and sushi has a 2x multiplier)?
10. How many points do customers A and B have at the end of January, factoring in a first-week 2x bonus on all items?

---

## 💡 Key Business Insights

* **Top Product:** Ramen is the undisputed favorite among customers, driving the highest order volume.
* **Customer Retention:** Customer B is the most frequent visitor, while Customer A generates the highest overall revenue.
* **Loyalty Program Success:** The promotional 2x points multiplier successfully drove high engagement and spending for members A and B immediately after joining the program.
