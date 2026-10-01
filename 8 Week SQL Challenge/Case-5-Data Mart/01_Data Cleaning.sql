-- Data Cleaning Part :
Create table clean_weekly_sales as
select 

	To_Date(week_date,'DD/MM/YY') as week_date,
    Extract(week from To_Date(week_date,'DD/MM/YY') ) as week_number ,
    Extract(Month from To_Date(week_date,'DD/MM/YY')) as month_number ,
    Extract(Year from To_Date(week_date,'DD/MM/YY')) as calendar_year ,
    
    region,
    platform,
    
    CASE 
        WHEN segment = 'null' OR segment IS NULL THEN 'unknown'
        ELSE segment 
    END AS segment,
    
    case 
    	when segment like '%1%' then 'Young Adults'
        when segment like '%2%' then 'Middle Aged'
        when segment like '%3%' or segment like '%4%' then 'Retirees'
        else 'unknown'
        end as age_band ,
        
    case 
    	when segment like '%C%' then 'Couples'
        when segment like '%F%' then 'Families'
        Else 'unknown'
        end as demographic ,
    round(sales::NUMERIC / transactions,2)  as avg_transaction ,
    customer_type,
    transactions,
    sales
    
    
 from  data_mart.weekly_sales;
 
 
select * from clean_weekly_sales