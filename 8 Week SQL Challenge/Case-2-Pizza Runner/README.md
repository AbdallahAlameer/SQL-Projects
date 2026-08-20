# 🍕 Case Study #2 - Pizza Runner

**Data Analyst:** Abdallah Alameer Ali  
**Domain:** Food Delivery & Logistics  
**Tools Used:** SQL (PostgreSQL) - Data Cleaning, CTEs, Joins, Aggregations, String Manipulation, Time-Series Analysis.

---

## 📌 Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide? Danny was inspired by "80s Retro Styling and Pizza Is The Future!" and decided to launch "Pizza Runner". He recruited runners to deliver fresh pizzas and developed a mobile app to accept customer orders. 

To ensure the business's growth, data collection was critical. The purpose of this project is to assist Danny in cleaning his raw data and applying calculations to better direct his runners and optimize Pizza Runner’s operations.

---

## 🗄️ Database Schema
All datasets exist within the `pizza_runner` database schema. The database consists of 6 interconnected tables:
* **`runners`**: Shows the registration date for each new runner.
* **`customer_orders`**: Captures individual pizza orders, including requested exclusions and extras.
* **`runner_orders`**: Contains delivery logistics such as pickup time, distance, duration, and cancellations.
* **`pizza_names`**: Maps pizza IDs to their names (Meat Lovers or Vegetarian).
* **`pizza_recipes`**: Details the standard set of toppings for each pizza recipe.
* **`pizza_toppings`**: Contains all topping names and their corresponding IDs.

---

## 📂 Repository Structure
This repository is organized logically to showcase the end-to-end data analysis process, starting from raw data preparation to advanced business insights:

* **`01_Data_Cleaning.sql`**: Contains the SQL scripts used to clean the raw `customer_orders` and `runner_orders` tables, handling NULL values, messy string formats, and correcting data types.
* **`02_A_Pizza_Metrics.sql`**: Queries answering core business questions regarding order volumes, successful deliveries, and pizza variations.
* **`03_B_Runner_Customer_Experience.sql`**: Analysis of runner performance, average delivery times, travel distances, and overall delivery efficiency.
* **`04_C_Ingredient_Optimisation.sql`**: Deep dive into inventory management, analyzing the most commonly added or excluded ingredients, and generating detailed order item formatting.
* **`05_D_Pricing_and_Ratings.sql`**: Financial calculations to determine total revenue and remaining profit after factoring in delivery costs and custom extras.
* **`06_E_Bonus_Questions.sql`**: DML operations demonstrating how to scale the database design for new pizza additions (e.g., a Supreme pizza).

---

## 🔍 Key Business Areas Explored

### A. Pizza Metrics
Focuses on understanding customer demand:
- Total pizzas ordered and unique customer orders.
- Volume of each pizza type delivered.
- Daily and hourly order volume trends (Time-Series).

### B. Runner and Customer Experience
Evaluates logistical efficiency:
- Runner sign-up trends over time.
- Average prep time, delivery duration, and distance traveled.
- Runner speed analysis and successful delivery percentages.

### C. Ingredient Optimisation
Assists in inventory and kitchen management:
- Identifying standard ingredients and the most common extras/exclusions.
- Calculating the exact quantity of each ingredient used in delivered pizzas.

### D. Pricing and Ratings
Focuses on profitability:
- Calculating total revenue based on fixed pizza prices.
- Factoring in delivery costs per kilometer to determine net profit.
- Designing a new schema for a customer rating system.

---