
--  Data Exploration : 


-- 1 What day of the week is used for each week_date value?

select Distinct to_char(week_date,'day') as day
from clean_weekly_sales;



-- 2 What range of week numbers are missing from the dataset?
select Min(week_number) , max(week_number)
from clean_weekly_sales;
/* 
Based on the MIN (13) and MAX (36) week numbers, 
the missing weeks in a standard 52-week calendar year are:
- Weeks 1 to 12 (before the data starts)
- Weeks 37 to 52 (after the data ends)
*/


-- 3 How many total transactions were there for each year in the dataset?
select calendar_year , sum(transactions) as transactions
from clean_weekly_sales
group by calendar_year;



-- 4 What is the total sales for each region for each month?

select region, month_number  , sum(sales) as Total_sales
from clean_weekly_sales
group by  region , month_number
order by region,month_number;

-- 5 What is the total count of transactions for each platform
select platform,sum(transactions) as total_transactions
from clean_weekly_sales
group by  platform 
order by platform,total_transactions;


-- 6 What is the percentage of sales for Retail vs Shopify for each month?
 
with sales_by_platform as 
(
select platform ,month_number, sum(sales) as sales 
from clean_weekly_sales
group by platform ,month_number
)

select 
	platform,
	month_number,
 	round(100.0 *sales /  SUM(sales) OVER(PARTITION BY month_number)  ,2) as sales_percentage_from_total
from sales_by_platform;


-- 7 What is the percentage of sales by demographic for each year in the dataset?
with sales_by_demographic as 
(
select demographic ,calendar_year, sum(sales) as sales
from clean_weekly_sales
group by demographic ,calendar_year
)

select 
    demographic ,
    calendar_year,
    round(100.0 * sales / sum(sales) over (partition by calendar_year ) , 2)  as sales_percentage_from_total
from sales_by_demographic;


-- 8 Which age_band and demographic values contribute the most to Retail sales?

select
	demographic,
    age_band,
    sum(sales) as sales
from clean_weekly_sales
where platform = 'Retail'
group by demographic, age_band
order by sales desc;
/*
--- Business Insights & Findings ---
1. Data Collection Gap: The 'unknown' demographic/age_band heavily dominates Retail sales (over $16 Billion). This indicates that the vast majority of retail transactions are made without loyalty cards, representing a significant missed opportunity for the business to track and analyze customer behavior.

2. Top Customer Profile: When excluding the 'unknown' data, the primary drivers of Retail sales are 'Retirees', specifically 'Families' (~$6.6B) followed closely by 'Couples' (~$6.3B).
*/
    
    
    
    
-- 9 Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

select 
  calendar_year,
  platform,
  Round(sum(sales)::NUMERIC / sum(transactions) , 2) As    	   Avg_Trans_Size
from clean_weekly_sales
group by calendar_year,platform
order by calendar_year,platform

/*
--- Answer & Mathematical Insight ---
No, we cannot simply use the AVG() function on the existing 'avg_transaction' column.

Doing so would calculate an "Average of Averages", which is mathematically incorrect because it assigns equal weight to every row, ignoring the fact that some weeks/rows have significantly more transactions than others.

To find the true overall average transaction size, we must recalculate it from the base numbers by dividing the total absolute sales by the total absolute number of transactions:
Formula: SUM(sales) / SUM(transactions)
*/

