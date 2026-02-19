/*
Query: Top Customers Per Store Ranking

Description:
This query identifies the top 3 customers in each store based on total spending.
It calculates each customer's total payment amount, ranks customers within each
store using a window function, and filters to return only the highest-spending
customers per store.

Concepts Demonstrated:
- Common Table Expressions (CTEs)
- Multi-table joins
- Aggregation (SUM)
- Window functions (RANK with PARTITION BY)
- Analytical filtering

Business Use Case:
Helps management identify high-value customers per store for loyalty rewards,
targeted promotions, or VIP programs.
*/
with format1 as(select c.customer_id, concat(c.first_name, ' ' ,c.last_name) as full_name,
sum(p.amount) as total_spent, s.store_id from customer c
join payment p on c.customer_id = p.customer_id
join staff f on f.staff_id = p.staff_id
join store s on s.store_id = f.store_id 
group by  c.customer_id, c.first_name, c.last_name, s.store_id),
finaltable as( 
select customer_id, full_name, total_spent , store_id, 
rank() over(partition by store_id order by total_spent desc) as store_ranking
from format1 order by store_id, store_ranking)

select customer_id, full_name, total_spent , store_id, store_ranking
from finaltable where store_ranking <= 3;
