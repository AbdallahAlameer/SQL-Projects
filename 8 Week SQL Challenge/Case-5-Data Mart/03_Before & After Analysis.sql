
--  Before & After Analysis :


-- 1 What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

with cte as 
( 
  select 
    sum(case when week_number in (21, 22, 23, 24) then sales end) as before_change,
    sum(case when week_number in (25, 26, 27, 28) then sales end) as after_change
  from clean_weekly_sales
  where calendar_year = 2020
)

select 
  before_change,
  after_change,
  (after_change - before_change) as abs_change,
  round(100.0 * (after_change - before_change) / before_change, 2) as percentage_change
from cte;
/*
--- Business Insights & Findings (4-Week Before & After Analysis) ---
1. Immediate Sales Decline: Total sales decreased by $26,884,188 (-1.15%) in the 4 weeks following the introduction of sustainable packaging on June 15, 2020 (week 25).
2. Short-Term Friction: This negative short-term impact suggests initial customer hesitation due to altered product aesthetics, potential stock availability issues,
or temporary supply chain adjustments during the rollout.
*/


-- 2 What about the entire 12 weeks before and after?
with cte12month as 
( 
  select 
    sum(case when week_number between 13 And 24 then sales end) as before_change,
    sum(case when week_number between 25 And 36  then sales end) as after_change
  from clean_weekly_sales
  where calendar_year = 2020
)

select 
  before_change,
  after_change,
  (after_change - before_change) as abs_change,
  round(100.0 * (after_change - before_change) / before_change, 2) as percentage_change
from cte12month;
/*
--- Business Insights & Findings (12-Week Before & After Analysis) ---
1. Sustained Sales Decline: Over the 12-week period following the packaging change, sales dropped by $152,325,394 (-2.14%).
2. Compounding Negative Trend: Comparing the 4-week decline (-1.15%) with the 12-week decline (-2.14%) reveals that the negative impact accelerated over time rather than recovering,
indicating a lasting customer friction or ongoing operational issues in 2020.
*/


-- 3 How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

with cte3 as 
( 
  select 
  	calendar_year,
    sum(case when week_number between 13 And 24 then sales end) as before_change,
    sum(case when week_number between 25 And 36  then sales end) as after_change
  from clean_weekly_sales
  group by calendar_year
)

select 
	calendar_year,
  before_change,
  after_change,
  (after_change - before_change) as abs_change,
  round(100.0 * (after_change - before_change) / before_change, 2) as percentage_change
from cte3;

/*
--- Business Insights & Findings (Historical 12-Week Comparison) ---

1. Seasonality Ruled Out: Comparing the same 12-week period across years shows that the severe drop in 2020 (-2.14%) cannot be explained by standard seasonality alone.

2. Trend Breakdown: In 2018, sales grew by +1.63% during weeks 25–36, while 2019 experienced a slight dip of -0.30%.

The steep decline of -2.14% (-$152.3M) in 2020 confirms that the performance drop was directly tied to changes introduced in 2020 (such as the sustainable packaging rollout) rather than annual market trends.
*/



 -- Bonus Question: 
WITH cte3 AS 
( 
  SELECT 
    region,
    platform,
    age_band,
    demographic,
    customer_type,
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales END) AS before_change,
    SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales END) AS after_change
  FROM clean_weekly_sales
  WHERE calendar_year = 2020 
  GROUP BY region, platform, age_band, demographic, customer_type
)

SELECT 
  region,
  platform,
  age_band,
  demographic,
  customer_type,
  before_change,
  after_change,
  (after_change - before_change) AS abs_change,
  ROUND(100.0 * (after_change - before_change) / NULLIF(before_change, 0), 2) AS percentage_change
FROM cte3
ORDER BY percentage_change ASC;


/*
--- Business Insights & Findings (Bonus Question: Segment Impact Analysis) ---
1. Worst Impacted Regions: SOUTH AMERICA and EUROPE suffered the largest percentage drops in sales following the 2020 sustainable packaging change.

2. Highest Channel Vulnerability: Shopify sales in SOUTH AMERICA experienced the sharpest drop (-42.23%), followed by EUROPE Shopify segments (-33.71% and -27.97%).

3. Actionable Takeaway: Management should prioritize investigating supply chain logistics and market feedback specifically in SOUTH AMERICA and EUROPE,
as these regions heavily dragged down overall 2020 performance.
*/
 
