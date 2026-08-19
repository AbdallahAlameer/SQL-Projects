1 What is the total amount each customer spent at the restaurant?

select s.customer_id as customer, sum(m.price) as total
from sales s join menu m
on s.product_id = m.product_id
group by customer 
order by total desc;






--2  How many days has each customer visited the restaurant?
select customer_id , count(distinct order_date) as days 
from sales
group by customer_id
order by days desc






-- 3  What was the first item from the menu purchased by each customer?
with cte as (
select s.customer_id ,s.product_id,m.product_name, Dense_Rank() 
						over( partition by s.customer_id order by s.order_date) as rank
from sales s join menu m
on s.product_id = m.product_id
 )
 
 select Distinct * from cte
where rank = 1 






-- 4  What is the most purchased item on the menu and how many times was it purchased by all customers?

select s.product_id , m.product_name ,count(s.product_id) as times
from sales s left join menu m
using(product_id)
group by s.product_id , m.product_name
order by times desc
LIMIT 1;






--5  Which item was the most popular for each customer?
with cte as (
select customer_id ,product_name, count(*) as times ,Dense_rank() over(partition by customer_id  order by count(*) desc ) as rank
from sales join menu 
using (product_id)
group by customer_id ,product_name 
)
select customer_id , product_name ,  times
from cte
where rank  = 1






-- 6 Which item was purchased first by the customer after they became a member?
with cte as (
select m.customer_id ,m.join_date ,s.order_date,s.product_id,n.product_name,row_number() over (partition by customer_id order by order_date asc) as num
from members m left join sales s 
using(customer_id)
join menu n
using(product_id)
where s.order_date >= m.join_date
  )
  select * 
  from cte
  where num = 1
  
  
  
  
  
  
-- --   7 Which item was purchased just before the customer became a member?
with cte as (
select m.customer_id ,m.join_date ,s.order_date,s.product_id,n.product_name,DENSE_RANK() over (partition by customer_id order by order_date DESC) as num
from members m left join sales s 
using(customer_id)
join menu n
using(product_id)
where s.order_date < m.join_date
  )
  select * 
  from cte
  where num = 1
  
  
  
  
  

-- -- 8 What is the total items and amount spent for each member before they became a member?

select s.customer_id , count(s.product_id) as items,sum(menu.price) as total_amount
from members m left join sales s 
using(customer_id)
join menu 
on s.product_id = menu.product_id

where s.order_date < m.join_date
group by s.customer_id






-- -- 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select
s.customer_id ,
sum(m.price) as total_price ,
sum(
  case 
	when m.product_name = 'sushi' then 20 * m.price
    Else 10 * m.price
    End 
)as total_points

from sales s left join menu m
using(product_id)
group by s.customer_id






-- 10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select
m.customer_id ,
sum(n.price),
sum
(
case 
	when s.order_date >= m.join_date 
  		And order_date < m.join_date + Interval ' 7 days 'then n.price * 20
  	when  n.product_name = 'sushi' then n.price * 20 
 	Else n.price * 10 
  End
 ) as total_point
  
from members m 
left join sales s
using(customer_id)
join menu n
on s.product_id = n.product_id
where s.order_date <= '2021-01-31'
group by m.customer_id
order by m.customer_id




























 