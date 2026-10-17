SELECT * FROM olist_sellers
LIMIT 5

---How many total sellers are there?
SELECT COUNT(DISTINCT seller_id) FROM olist_sellers

---how many unique states are there in which sellers are present?
SELECT COUNT(DISTINCT seller_state) 
FROM olist_sellers

---states and the count of sellers associated with that state
SELECT seller_state, 
       COUNT(*) AS total_sellers
FROM olist_sellers
GROUP BY seller_state
ORDER BY total_sellers DESC
LIMIT 5

---which city contains the most of the sellers? (find the top 10 cities)
SELECT seller_city, 
       seller_state,
       COUNT(*) AS total_sellers
FROM olist_sellers
GROUP BY seller_city,seller_state
ORDER BY total_sellers DESC
LIMIT 10

--which states have more than 50 sellers
SELECT seller_state, 
       COUNT(*) AS total_sellers
FROM olist_sellers
GROUP BY seller_state
HAVING COUNT(*) > 50
ORDER BY total_sellers DESC

--which seller and of which state sold the max number of items?
SELECT a.seller_id,
       a.seller_state,
	   COUNT(*) AS items_count
FROM olist_sellers a
     JOIN olist_order_items b 
	 ON a.seller_id = b.seller_id
GROUP BY a.seller_state, a.seller_id
ORDER BY items_count DESC
LIMIT 1

--sellers of which state have the max revenue?
SELECT a.seller_id,
       a.seller_state,
	   SUM(b.price) AS total_revenue
FROM olist_sellers a
     JOIN olist_order_items b 
	 ON a.seller_id = b.seller_id
/*WHERE a.seller_id = '6560211a19b47992c3666cc44a7e94c0'*/
GROUP BY a.seller_id, a.seller_state
ORDER BY total_revenue DESC
LIMIT 10

---avg revenue of sellers in each state?
SELECT a.seller_state,
       COUNT(DISTINCT a.seller_id) AS sellers_count,
       ROUND(SUM(b.price)/COUNT(DISTINCT a.seller_id), 2) AS avg_revenue_per_seller
FROM olist_sellers a
     JOIN olist_order_items b 
	 ON a.seller_id = b.seller_id
GROUP BY a.seller_state
HAVING COUNT(DISTINCT a.seller_id) > 10
ORDER BY avg_revenue_per_seller DESC

--which product category contains the max number of sellers?
SELECT a.product_category,
       COUNT(DISTINCT c.seller_id) AS total_sellers
FROM olist_products a
     JOIN olist_order_items b ON a.product_id = b.product_id
	 JOIN olist_sellers c ON b.seller_id = c.seller_id
GROUP BY a.product_category
ORDER BY total_sellers DESC

---kis state k sellers k reviews ka avg score sabse kam h 
SELECT a.seller_state,
       COUNT(DISTINCT a.seller_id),
       ROUND(AVG(c.review_score), 2) AS avg_review_score
FROM olist_sellers a
     JOIN olist_order_items b ON a.seller_id = b.seller_id
	 JOIN olist_reviews c ON b.order_id = c.order_id 
GROUP BY a.seller_state
HAVING COUNT(DISTINCT a.seller_id) > 10
ORDER BY avg_review_score 
LIMIT 5

---which sellers doesn't even sold 1 item?
SELECT a.seller_id
FROM olist_sellers a
     LEFT JOIN olist_order_items b 
	 ON a.seller_id = b.seller_id
WHERE b.order_id IS NULL 










