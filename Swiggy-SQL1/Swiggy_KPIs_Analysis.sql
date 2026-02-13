
-- KPI's :

--Total Orders : 
select count(*) as Total_Orders
from Fact_Swiggy_Orders

--Total revenue (INR million)/
select
format(sum(convert(float,price_inr))/1000000,'N2')+ ' INR Million'
as Total_Revenue
from Fact_Swiggy_Orders

--Avg Dish Price 
select 
format(avg(convert(float,Price_INR)),'N2') + ' INR'
as Avg_Dish_Price
from Fact_Swiggy_Orders

--Avg Rating 
 select AVG(Rating)
 from Fact_Swiggy_Orders



------------------------------

--Deep_Dive Business Analysis 

--Monthly Order trends  :
select 
d.year,
d.Month,
d.month_Name,
count(*) as Total_Orders
from Fact_Swiggy_Orders f 
join Dim_Date d on f.date_id=d.date_id
group by d.year,d.Month,d.month_Name

-- Monthly total revenue : 
select 
d.year,
d.month_Name,
format(sum(Price_INR)/1000000,'N2') + ' INR million' as Total_Revenue
from Fact_Swiggy_Orders f
join Dim_Date d on f.date_id = d.date_id
group by  d.year,
d.month_Name


--Quartly Order trends : 

select 
d.year,
d.quarter,
count(*) as Total_Orders
from Fact_Swiggy_Orders f 
join Dim_Date d on f.date_id=d.date_id
group by d.year,d.quarter
order by count (*) desc

----Yearly  Order trends  : 

select 
d.year,
count(*) as Total_Orders
from Fact_Swiggy_Orders f 
join Dim_Date d on f.date_id=d.date_id
group by d.year


--Weekly Order trends : 

select 
d.week_num,DATENAME(WEEKDAY,d.Full_Date) as Day_Name,
count(*) as Total_Orders
from Fact_Swiggy_Orders f 
join Dim_Date d on f.date_id=d.date_id
group by d.week_num,DATENAME(WEEKDAY,d.Full_Date)
order by count (*) desc


-- Top 10 Cities by Order Volume : 
with CTE2 as
(
select
l.City,
count(f.order_id) as Total_Orders
from Fact_Swiggy_Orders f
join Dim_location l
		on f.location_id = l.location_id
group by l.City 
)

select top 10  *
from CTE2 
order by Total_Orders desc



---------------------------


-- Revenue Contribution by states : 

select 
l.state,
format(sum(Price_INR)/1000000,'N2') + ' INR million' As Total_Revenue
from Fact_Swiggy_Orders f 
join Dim_location l on f.location_id = l.location_id 
group by l.state
order by sum(f.Price_INR) desc

---------------------------
--Top 10 Resturant by Orders : 

select top 10
r.Resturant_name,
format(sum(Price_INR)/1000000,'N2') + ' INR million' As Total_Revenue
from Fact_Swiggy_Orders f 
join Dim_Resturant r on f.Resturant_id =r.resturant_id 
group by r.Resturant_name
order by sum(f.Price_INR) desc

------------------------------
--Top 10 Categories 
select top 10
c.category,
format(sum(Price_INR)/1000000,'N2') + ' INR million' As Total_Revenue
from Fact_Swiggy_Orders f 
join Dim_Category c on f.category_id =c.category_id
group by c.category
order by sum(f.Price_INR) desc

------------------------------

--Most Ordered Dish 

select top 10 
d.Dish_name,
count(*) as Order_Count
from Fact_Swiggy_Orders f 
join Dim_Dish d on f.dish_id = d.Dish_id
group by d.Dish_name
order by Order_Count desc
------------------------------------

-- Cuisine Performance (Order+Avg Rating ) : 
select 
c.category,
COUNT(*) AS Total_Orders ,
format(Avg(convert(float,f.Rating)),'N2') as Avg_Rating 
from Fact_Swiggy_Orders f 
join Dim_Category c on f.category_id = c.category_id 
group by c.category
order by Total_Orders desc
------------------------------------

--Customer Spending Inside :

--Total Orders by Price Range 

select 
	case
		when Price_INR <100 then 'Under 100'
		when Price_INR between 100 and 199 then '100 - 199'
		when Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
		WHEN Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
		ELSE '500+'
	END AS Price_range,
count(*) As Total_Orders
from Fact_Swiggy_Orders 
group by 
	case
		when Price_INR <100 then 'Under 100'
		when Price_INR between 100 and 199 then '100 - 199'
		when Price_INR BETWEEN 200 AND 299 THEN '200 - 299'
		WHEN Price_INR BETWEEN 300 AND 499 THEN '300 - 499'
		ELSE '500+'
	END
order by Total_Orders desc\

------------------------

--Rating Count Distribution
 select 
	rating,
	count(*) As Rating_Count
from Fact_Swiggy_Orders
group by Rating
order by Count(*) desc 



