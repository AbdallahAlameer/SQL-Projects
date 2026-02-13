select count(*) from Swiggy_Data

select * from Swiggy_Data

-- Data Cleaning & Validations 

--Null Check 

select 
sum(case when State IS NULL then 1 else 0 end ) as State_nulls,
sum(case when City is null then 1 else 0 end ) as City_nulls,
sum(case when Order_Date is null then 1 else 0 end ) as Order_Date_nulls,
sum(case when Restaurant_Name is null then 1 else 0 end ) as Restaurant_Name_nulls,
sum(case when Location is null then 1 else 0 end ) as Location_nulls,
sum(case when Category is null then 1 else 0 end ) as Category_nulls,
sum(case when Dish_Name is null then 1 else 0 end ) as Dish_Name_nulls,
sum(case when Price_INR is null then 1 else 0 end ) as Price_INR_nulls,
sum(case when Rating is null then 1 else 0 end ) as Rating_nulls,
sum(case when Rating_Count is null then 1 else 0 end) as Rating_Count_nulls

from Swiggy_Data


--Blanck or Empty 
select * 
from Swiggy_Data
where 
state = '' or City='' or Restaurant_Name = '' or Location = '' or Dish_Name = '' 

--Duplicate Detiction 
select 
State,city,Order_Date,Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count,count(*) as CNT
from Swiggy_Data
group by State,city,Order_Date,Restaurant_Name,Location,Category,Dish_Name,Price_INR,Rating,Rating_Count 
having   count(*) > 1


--Duplicate Remove

with CTE as (

select *, Row_number() over(Partition by State,city,Order_Date,Restaurant_Name,
							Location,Category,Dish_Name,Price_INR,Rating,Rating_Count
							order by (select null) 
							) as rn
							from Swiggy_Data
)
Delete from CTE where rn >1

