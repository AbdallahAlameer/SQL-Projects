-- Cleaninig Customer Orders Tables 
DROP TABLE IF EXISTS customer_orders_temp;

CREATE TEMP TABLE customer_orders_temp AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
    WHEN exclusions = '' OR exclusions = 'null' THEN NULL
    ELSE exclusions
  END AS exclusions,
  CASE
    WHEN extras = '' OR extras = 'null' THEN NULL
    ELSE extras
  END AS extras,
  order_time
FROM pizza_runner.customer_orders;







--  Cleaninig runner_orders Tables
Drop table if exists   runner_orders_tmp ;

Create table runner_orders_tmp as 
select 
order_id,
runner_id,
case 
	when pickup_time = 'null' then NULL
    else pickup_time 
    End AS pickup_time,
Case 
	when distance = 'null' then NULL
    Else trim(Replace(distance,'km',''))
    END AS distance ,
CASE 
	when duration = 'null' then NULL
    ELSE TRIM(REPLACE(REPLACE(REPLACE(duration, 'minutes', ''), 'minute', ''), 'mins', '')) 
    END AS duration ,
Case 
	when cancellation = 'null' then NULL 
    when cancellation = '' then NULL
    ELSE cancellation
    END AS cancellation
    
FROM runner_orders;

ALTER TABLE runner_orders_tmp
  ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::TIMESTAMP,
  ALTER COLUMN distance TYPE FLOAT USING distance::FLOAT,
  ALTER COLUMN duration TYPE INT USING duration::INT;
