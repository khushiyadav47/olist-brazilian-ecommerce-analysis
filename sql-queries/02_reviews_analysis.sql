CREATE TABLE olist_reviews(
    review_id VARCHAR(50),
	order_id VARCHAR(50),
	review_score INT,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
)

SELECT COUNT(*) FROM olist_reviews

/* harr review score me kitne reviews hai?*/
SELECT review_score, COUNT(*) AS total_reviews
FROM olist_reviews
GROUP BY review_score
ORDER BY total_reviews DESC

/* what is the average review score*/
SELECT ROUND(AVG(review_score), 2) AS avg_review
FROM olist_reviews

/* hrr review score ka avg nikalo*/
SELECT review_score,
       COUNT(*) AS review_count,
       ROUND(100.0 * COUNT(*)/(SELECT COUNT(*) FROM olist_reviews), 2) AS avg_pct
FROM olist_reviews
GROUP BY review_score
ORDER BY avg_pct DESC

/*kitne percentage reviews 1 ya 2 star k h ?*/
SELECT review_score,
       COUNT(*) AS review_count,
       ROUND(100.0 * COUNT(*)/(SELECT COUNT(*) FROM olist_reviews), 2) AS avg_pct
FROM olist_reviews
WHERE review_score IN (1,2)
GROUP BY review_score
ORDER BY avg_pct DESC

/* joining reviews table and orders table*/
SELECT COUNT(*) AS row_total
FROM olist_orders a
     JOIN olist_reviews b
	 ON a.order_id = b.order_id

/*hrr delivery status ka average review score kya delivery time ka review p effect pdta h?*/
SELECT a.delivery_status, 
       ROUND(AVG(b.review_score), 2) AS avg_score
FROM olist_orders a
     JOIN olist_reviews b
	 ON a.order_id = b.order_id
WHERE a.delivery_status IS NOT NULL
GROUP BY a.delivery_status
ORDER BY avg_score DESC

/* harr delivery status me 1 ya 2 review score ka percentage*/
SELECT a.delivery_status ,
       COUNT(*) AS reviews,
	   ROUND(100.0 * SUM(CASE WHEN b.review_score <= 2 THEN 1 ELSE 0 END)/COUNT(*), 2) AS bad_review_pct
FROM olist_orders a 
     JOIN olist_reviews b
	 ON a.order_id = b.order_id 
WHERE a.delivery_status IS NOT NULL
GROUP BY a.delivery_status
ORDER BY bad_review_pct DESC

/* hrr state ka average review score*/
SELECT a.customer_state,
       ROUND(AVG(c.review_score), 2) AS avg_rating
FROM olist_customers a
     JOIN olist_orders b ON a.customer_id = b.customer_id
	 JOIN olist_reviews c ON b.order_id = c.order_id
GROUP BY a.customer_state
HAVING COUNT(*) > 1000
ORDER BY avg_rating DESC
	 


	  











