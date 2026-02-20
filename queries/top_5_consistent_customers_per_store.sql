/*
query: top 5 most consistent customers per store

description:
this query identifies the most consistent customers for each store based on
their rental activity patterns. it calculates how many months each customer
was active, their total rentals, and their average rentals per active month.
customers are ranked per store according to consistency metrics, and the top
5 performers are returned.

skills demonstrated:
- aggregations and grouped metrics
- time-based analysis using date_format
- behavioral analytics logic
- window functions (rank)
- cte structuring
- multi-level aggregation design

business insight:
helps identify loyal and high-engagement customers who consistently rent,
making them ideal targets for retention campaigns or loyalty rewards.
*/
with format1 as(select sf.store_id, p.customer_id, date_format(p.payment_date, '%y-%m') as yearmonth, count(*) as total_rentals
from payment p
join staff sf on sf.staff_id = p.staff_id
group by p.customer_id, sf.store_id, yearmonth),

format2 as (
select store_id, customer_id,
count(distinct yearmonth) as num_active_months,
sum(total_rentals) as total_rentals,
round(sum(total_rentals) / nullif(count(distinct yearmonth),0),2) as avg_rentals_per_active_month
from format1
group by store_id, customer_id),

finaltable as (
select *,rank() over(partition by store_id order by avg_rentals_per_active_month desc, total_rentals desc) as consistency_rank
from format2)

select store_id, customer_id, avg_rentals_per_active_month, num_active_months, total_rentals, consistency_rank
from finaltable where consistency_rank < 6
order by store_id, consistency_rank;
