SELECT * FROM customer
LIMIT 20

--Q1.What is the total revenue generated male vs female
SELECT gender, SUM(purchase_amount) AS Total_Revenue
FROM customer
GROUP BY gender;

--Q2.Which customers used a discount but still spent more than avg purchased amount
SELECT customer_id,purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select avg(purchase_amount) from customer)

--Q3.Which are the top 5 products with highest average review rating?
select item_purchased,
		ROUND(avg(review_rating :: numeric),2) as avg_rating
from customer
group by item_purchased
order by avg_rating desc
limit 5 


--Q4.Compare the average purchase amount between standard and express shipping
select round(avg(purchase_amount),2),shipping_type
from customer
where shipping_type in ('Standard','Express')
group by shipping_type


--Q5.Do subscribed customers spend more? Compare avg spend and total revenue between subcribers and non subscribers
SELECT subscription_status,
		COUNT(customer_id) AS Total_Customers,
		ROUND(AVG(purchase_amount),2) AS Avg_Cust_BySubscription,
		SUM(purchase_amount) AS Total_Revenue_BySubscription
FROM customer
GROUP BY subscription_status
ORDER BY Total_Revenue_BySubscription DESC;


--Q6. Which 5 products have the highest percentage of purchases with discount Applied?
select item_purchased,
	   round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5


--Q7. Segment customers into new, returning and loyal based on their
--total number of previous purchases and show the count of each segment
with customer_type as (
select customer_id,previous_purchases,
case
when previous_purchases = 1 then 'New'
when previous_purchases between 2 and 10 then 'Returning'
else 'Loyal'
end as customer_segment
from customer
)
select customer_segment,count(*) as "Number_of_customer"
from customer_type
group by customer_segment


--Q8. what are the top 3 most purchased products within each category
with item_counts as(
	select 
		category,
		item_purchased,
		count(customer_id) as total_orders,
		row_number()over(
			partition by category
			order by count(customer_id) desc
		) as item_rank
	from customer
	group by category,item_purchased
)
select item_rank,
	   category,
	   item_purchased,
	   total_orders
from item_counts
where item_rank <= 3;

--Q9. Are customers who are repeat buyers (more than  5 previous purchase) also likely to subscribe?
select subscription_status,
		count(customer_id) as repeat_customers
from customer
where previous_purchases > 5
group by subscription_status

--Q10. what is the revenue contribution of each age group
select age_group,
		sum(purchase_amount) as total_revenue_byAgeGroup
from customer
group by age_group
order by total_revenue_byAgeGroup desc