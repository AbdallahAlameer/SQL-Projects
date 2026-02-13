
--Creating Schema 


create table Dim_Date (
date_id int identity(1,1) primary Key ,
Full_Date date ,
year int ,
Month int , 
month_Name varchar(20) ,
Quarter int ,
day int, 
week_num int 

)
select * from Dim_Date
--------------------------------

create table Dim_location (
location_id int identity(1,1) primary key ,
state varchar(100) , 
City varchar(100) , 
Location varchar(200)
)
select * from Dim_location
-------------------------------

create table Dim_Resturant (
resturant_id int identity (1,1) primary key , 
Resturant_name varchar(200)
)
------------------------------

create table Dim_Category (
category_id int identity(1,1) primary key ,
category varchar(200)
)
--------------------------------

create table Dim_Dish (
Dish_id int identity (1,1) primary key,
Dish_name varchar(200)
)


select * from Swiggy_Data


------------------
--Fact Table : 

create table Fact_Swiggy_Orders (
order_id int identity(1,1) primary key ,
date_id int ,
Price_INR decimal(10,2),
Rating decimal(4,2),
Rating_Count int , 
location_id int ,
Resturant_id int ,
category_id int ,
dish_id int ,

foreign key (date_id) references dim_date(date_id),
foreign key (location_id) references dim_location(location_id),
foreign key (Resturant_id) references dim_Resturant(Resturant_id),
foreign key (category_id) references dim_category(category_id),
foreign key (dish_id) references dim_dish(dish_id),

)


select * from Fact_Swiggy_Orders


-------------------
-- insert data to Dims :

insert into Dim_Date (Full_Date,year,Month,month_Name,Quarter,day,week_num)
select distinct 
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATEPART(MONTH,Order_Date),
	DATEPART(QUARTER,Order_Date),
	DAY(Order_Date),
	DATEPART(WEEK,Order_Date)
from Swiggy_Data
where Order_Date is not null


update Dim_Date 
set month_Name = DATENAME(MONTH,Full_Date)

select * from Dim_Date

--------------------------------

insert into Dim_location (state , City ,Location)
select distinct
	state , 
	City,
	Location
from Swiggy_Data

select * from Dim_location


----------------------------------

insert into Dim_Resturant (Resturant_name)
select distinct 
	Restaurant_Name
from Swiggy_Data

------------------------------------

insert into Dim_Category (category)
select distinct 
	Category
from Swiggy_Data


-------------------------------------

insert into Dim_Dish (Dish_name)
select distinct
	Dish_Name
from Swiggy_Data
	

----------------------------
-- Fact table 

insert into Fact_Swiggy_Orders 
(
	date_id,
	Price_INR,
	Rating,
	Rating_Count,
	location_id,
	Resturant_id,
	category_id,
	dish_id
)
select 

	dd.date_id,
	s.price_inr,
	s.rating,
	s.rating_count,

	dl.location_id,
	dr.resturant_id,
	dc.category_id,
	dsh.dish_id

from Swiggy_Data s

join Dim_Date dd
	on s.Order_Date = dd.Full_Date

join Dim_location dl 
	on dl.state = s.State
	and dl.City = s.City 
	and dl.Location = s.Location

join Dim_Resturant dr
	on dr.Resturant_name = s.Restaurant_Name

join Dim_Category dc
	on dc.category = s.Category

join Dim_Dish dsh 
	on dsh.Dish_name = s.Dish_Name 



select * from Fact_Swiggy_Orders


 -- show final table : 

select * from Fact_Swiggy_Orders f 

join Dim_Date d on f.date_id = d.date_id
join Dim_location l on l.location_id = f.location_id
join Dim_Resturant r on f.Resturant_id = r.resturant_id
join Dim_Category c on f.category_id = c.category_id 
join Dim_Dish sh on sh.Dish_id = f.dish_id
