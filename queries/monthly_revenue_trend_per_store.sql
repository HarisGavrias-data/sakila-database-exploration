/*
Query: Monthly Revenue Trend per Store

Description:
This query calculates total monthly revenue for each store and analyzes
month-over-month performance using window functions. It retrieves the previous
month’s revenue, computes revenue differences, and calculates percentage growth.

Skills Demonstrated:
- Aggregations
- Date formatting for time-series grouping
- Window functions (LAG)
- Analytical calculations
- CTE structuring
- Division-safe calculations using NULLIF

Business Insight:
Helps identify revenue trends, seasonal patterns, and performance shifts
between months for each store.
*/
with format1 as (select i.store_id, date_format(p.payment_date, '%Y-%m') as YearMonth,
sum(p.amount) as monthly_revenue
from payment p
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id 
group by i.store_id, YearMonth
order by i.store_id, YearMonth),
finaltable as(
select *, lag(monthly_revenue) over(partition by store_id order by yearmonth) as previous_revenue, 
monthly_revenue - lag(monthly_revenue) over(partition by store_id order by yearmonth) as revenue_diff
from format1)

select store_id, YearMonth, monthly_revenue, previous_revenue, revenue_diff,
round(100 * (revenue_diff / nullif(previous_revenue,0)),2) as mom_growth from finaltable
