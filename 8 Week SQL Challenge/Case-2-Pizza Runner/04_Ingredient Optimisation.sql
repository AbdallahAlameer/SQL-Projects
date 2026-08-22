 
  
  --  Cleaninig pizza_recipes Tables

 Drop table if exists   pizza_recipes_tmp ;

Create table pizza_recipes_tmp as 
 SELECT 
    pizza_id,
    UNNEST(STRING_TO_ARRAY(toppings, ', '))::INT AS topping_id
FROM pizza_recipes
ORDER BY pizza_id, topping_id;


-- 1 What are the standard ingredients for each pizza?
select p.pizza_name , string_agg(ptp.topping_name,',') AS standard_ingredients
from pizza_names p left join pizza_recipes_tmp pt
using(pizza_id)
join pizza_toppings ptp
on pt.topping_id = ptp.topping_id
group by p.pizza_name;


-- 2 What was the most commonly added extra?
with Extra_cte as 
(
  SELECT 
        order_id,
        UNNEST(STRING_TO_ARRAY(REPLACE(extras, ' ', ''), ','))::INT AS extra_id  
    FROM customer_orders_temp
    WHERE extras IS NOT NULL 
      AND extras NOT IN ('', 'null', 'NULL')
)

  
 select extra_id, Count(extra_id) as count_extra
 from Extra_cte
 group by extra_id
 order by count_extra desc ;
 
 
 
--4 Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
 
WITH customer_cte AS (
    SELECT 
        *,
        ROW_NUMBER() OVER() AS record_id
    FROM customer_orders_temp
),
extras_split AS (
    SELECT 
        record_id,
        UNNEST(STRING_TO_ARRAY(REPLACE(extras, ' ', ''), ','))::INT AS extra_id
    FROM customer_cte
    WHERE extras IS NOT NULL AND extras NOT IN ('', 'null', 'NULL')
),
extras_cte AS (
    SELECT 
        e.record_id,
        STRING_AGG(pt.topping_name, ', ') AS extra_names
    FROM extras_split e
    JOIN pizza_toppings pt ON pt.topping_id = e.extra_id
    GROUP BY e.record_id
),
exclusions_split as 
(
  select 
  record_id,
  Unnest(String_to_array(REPLACE(exclusions,' ',''),','))::INT as exclusions_id
  from customer_cte
  Where exclusions is not null AND exclusions not in (' ' , 'null','NULL')
),
exclusions_cte as 
(
select 
 ex.record_id ,
 String_agg(topping_name,',') as exclusion_names 
  from exclusions_split ex   join  pizza_toppings pt 
   on pt.topping_id=ex.exclusions_id 
  group by ex.record_id
  
  
)
SELECT 
    c.order_id,
    CONCAT(
        pn.pizza_name, 
        CASE WHEN exc.exclusion_names IS NOT NULL THEN ' - Exclude ' || exc.exclusion_names ELSE '' END,
        CASE WHEN ext.extra_names IS NOT NULL THEN ' - Extra ' || ext.extra_names ELSE '' END
    ) AS order_item
FROM customer_cte c
JOIN pizza_names pn 
    ON c.pizza_id = pn.pizza_id
LEFT JOIN extras_cte ext 
    ON c.record_id = ext.record_id
LEFT JOIN exclusions_cte exc 
    ON c.record_id = exc.record_id
ORDER BY c.order_id;