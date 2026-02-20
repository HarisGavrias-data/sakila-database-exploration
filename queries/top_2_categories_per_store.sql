/*
Query: Top Revenue-Generating Film Categories per Store

Description:
This query calculates total revenue generated per film category for each store
and ranks them using a window function. It returns the top 2 categories per store
based on total payment revenue.

Skills Demonstrated:
- Multi-table joins
- Aggregations
- Window functions (DENSE_RANK)
- CTE structuring
- Analytical querying
*/
with format1 as (select s.store_id, c.category_id, c.name, sum(p.amount) as revenue
from store s 
join inventory i on i.store_id = s.store_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
join film f on f.film_id = i.film_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
group by  s.store_id, c.category_id, c.name),
final_table as( select *, rank() over(partition by store_id order by revenue desc) as category_rank from format1)
select store_id, category_id, name as category_name, revenue, category_rank 
from final_table
where category_rank <= 2
