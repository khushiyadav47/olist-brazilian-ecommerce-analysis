/*identify repeated customers using vouchers*/
SELECT b.customer_unique_id,
       COUNT(DISTINCT order_id)
FROM olist_orders a 
     JOIN olist_customers b
	 USING(customer_id)
WHERE b.customer_unique_id IN (
     SELECT DISTINCT c.customer_unique_id AS total_voucher_cust
     FROM olist_orders a
          JOIN olist_payments b USING(order_id)
	      JOIN olist_customers c USING(customer_id)
     WHERE payment_type = 'voucher'
)
GROUP BY b.customer_unique_id
HAVING COUNT(DISTINCT order_id) > 2

/*kya delivery charge repeat purchases affect krta h ?*/
WITH freight_data AS  (SELECT b.customer_unique_id,
	         CASE WHEN COUNT(DISTINCT a.order_id) > 1 THEN 'repeated'
			 ELSE 'one-time'
			 END AS customer_type,
             COUNT(DISTINCT a.order_id) AS order_count,
	         ROUND(AVG(c.freight_value), 2) AS avg_freight
      FROM olist_orders a
           JOIN olist_customers b USING(customer_id)
	       JOIN olist_order_items c USING(order_id)
      GROUP BY b.customer_unique_id
)
SELECT freight_data.customer_type AS cust_type,
       ROUND(AVG(freight_data.avg_freight), 2) AS avg_freight
FROM freight_data
GROUP BY freight_data.customer_type

/*Do customers who place only one order experience a different first-order
delivery time compared to customers who go on to make repeat purchases?*/
WITH x AS(SELECT b.customer_unique_id,
             a.order_id AS order_id,
			 a.order_purchase_timestamp AS purchase_date,
			 a.order_delivered_customer_date AS deliver_date,
             ROW_NUMBER() OVER(
                    PARTITION BY b.customer_unique_id
					ORDER BY a.order_purchase_timestamp ASC
			 ) AS earliest_order
             FROM olist_orders a
                  JOIN olist_customers b 
	              USING(customer_id)
			 WHERE a.order_status = 'delivered'
				  ),
y AS (
     SELECT b.customer_unique_id,
	        CASE WHEN COUNT(DISTINCT order_id) > 1 THEN 'repeated'
			ELSE 'one-time'
			END AS cust_type
	 FROM olist_orders a
          JOIN olist_customers b 
		  USING(customer_id)
	GROUP BY b.customer_unique_id
) 			  
SELECT y.cust_type,
       COUNT(*) AS total_cust_count,
	   ROUND(AVG(deliver_date::date - purchase_date::date), 2) AS avg_delivery_time
FROM x JOIN y USING(customer_unique_id)
WHERE x.earliest_order = 1
GROUP BY y.cust_type


/*Pehle order ka review score kitna tha? Kya one-time 
customers ka first review repeat customers se kam tha?*/
WITH X AS (SELECT b.customer_unique_id,
                   a.order_id,
	               c.review_score,
	               ROW_NUMBER() OVER(
                          PARTITION BY b.customer_unique_id
			              ORDER BY a.order_purchase_timestamp
	               ) AS order_no
           FROM olist_orders a
                JOIN olist_customers b USING(customer_id)
	            JOIN olist_reviews c USING(order_id)
),
y AS (
    SELECT b.customer_unique_id, 
	       CASE WHEN COUNT(DISTINCT a.order_id) > 1 THEN 'repeated'
		   ELSE 'one-time'
		   END AS customer_type
	FROM olist_orders a
	     JOIN olist_customers b USING(customer_id)
	GROUP BY b.customer_unique_id
)
SELECT y.customer_type,
       COUNT(*) AS total_cust,
	   ROUND(AVG(x.review_score), 2) AS avg_review
FROM x JOIN y USING(customer_unique_id)
WHERE x.order_no = 1
GROUP BY y.customer_type


/*How much of Olist’s total revenue comes from one-time customers, 
and how much more do repeat customers spend per head? If the repeat rate improved from about 3% to 5%, 
what additional revenue could the platform expect?*/
WITH x AS (SELECT a.customer_unique_id,
       c.price
FROM olist_customers a
     JOIN olist_orders b USING(customer_id)
	 JOIN olist_order_items c USING(order_id)
),
y AS (
    SELECT b.customer_unique_id,
	       CASE WHEN COUNT(DISTINCT a.order_id) > 1 THEN 'repeated'
		   ELSE 'one-time'
		   END AS customer_type
	FROM olist_orders a
	     JOIN olist_customers b
		 USING(customer_id)
	GROUP BY b.customer_unique_id
)
SELECT y.customer_type,
       COUNT(DISTINCT customer_unique_id) AS total_customers,
       SUM(x.price) AS total_revenue,
	   ROUND(SUM(x.price)/COUNT(DISTINCT customer_unique_id), 2) AS revenue_per_customer
FROM x JOIN y USING(customer_unique_id)
GROUP BY y.customer_type

/*Kaun si product categories se aaye customers sabse kam wapas aate hain?*/
/*data we need - Category
Us category se pehla order karne wale kitne customers
Unme se kitne wapas aaye (repeated)
Repeat rate (%)*/
WITH x AS (
       SELECT b.customer_unique_id,
              ROW_NUMBER() OVER(
                    PARTITION BY b.customer_unique_id
			        ORDER BY a.order_purchase_timestamp
	          ) AS order_no,
	          d.product_category
       FROM olist_orders a
            JOIN olist_customers b USING(customer_id)
	        JOIN olist_order_items c USING(order_id)
	        JOIN olist_products d USING(product_id)
       WHERE a.order_status = 'delivered'
),
y AS (
    SELECT b.customer_unique_id,
	       CASE WHEN COUNT(DISTINCT a.order_id) > 1 THEN 'repeated'
		   ELSE 'one-time'
		   END AS customer_type
	FROM olist_orders a
	     JOIN olist_customers b
		 USING(customer_id)
	GROUP BY b.customer_unique_id  
)
SELECT product_category,
       COUNT(*) AS total_customers,
	   SUM(CASE WHEN customer_type = 'repeated' THEN 1 ELSE 0 END) AS repeated_customers,
	   ROUND(100.0 * SUM(CASE WHEN customer_type = 'repeated' THEN 1 ELSE 0 END)/COUNT(*), 2) AS repeat_pct
FROM x JOIN Y USING(customer_unique_id)
WHERE x.order_no = 1
GROUP BY product_category
HAVING COUNT(*) >= 200
ORDER BY repeat_pct


/*How many days after their first order do repeat customers place their 
second order, and after what point does the chance of a return drop sharply?*/
WITH abc AS (
       WITH x AS (
             SELECT b.customer_unique_id,
	                ROW_NUMBER() OVER(
                           PARTITION BY b.customer_unique_id
				           ORDER BY a.order_purchase_timestamp
			         ) AS order_no,
			         a.order_purchase_timestamp
	          FROM olist_orders a 
	               JOIN olist_customers b 
		           USING(customer_id)
       ),
       y AS (
            SELECT b.customer_unique_id,
	               CASE WHEN COUNT(DISTINCT a.order_id) > 1 THEN 'repeated'
		           ELSE 'one-time'
		           END AS customer_type
	         FROM olist_orders a
	              JOIN olist_customers b
		          USING(customer_id)
	         GROUP BY b.customer_unique_id  
       )
       SELECT customer_unique_id,
              MAX(order_purchase_timestamp)::date - MIN(order_purchase_timestamp) ::date AS return_days
        FROM x JOIN y USING(customer_unique_id)
        WHERE x.order_no IN (1,2) AND y.customer_type = 'repeated'
        GROUP BY customer_unique_id
),
bucketed AS (
     SELECT abc.customer_unique_id,
	        abc.return_days,
			CASE WHEN return_days <= 30 THEN '0-30 days'
			WHEN return_days <= 60 THEN '31-60 days'
			WHEN return_days <= 90 THEN '61-90 days'
			ELSE '90+ days'
			END AS return_bucket
	  FROM abc
)
SELECT return_bucket,
       COUNT(*) AS total_count
FROM bucketed
GROUP BY return_bucket

/* Do customers who had a bad first experience (late delivery and a low review)
return less often than customers who had a good first experience?*/
WITH exp_data AS ( 
      WITH x AS (
             SELECT b.customer_unique_id,
                    ROW_NUMBER() OVER(
                           PARTITION BY b.customer_unique_id
			               ORDER BY a.order_purchase_timestamp
	                 ) AS order_no,
	                c.review_score,
	                a.delivery_status
             FROM olist_orders a
                  JOIN olist_customers b USING(customer_id)
	              JOIN olist_reviews c USING(order_id) 
	         WHERE order_status = 'delivered' 
     ),
     y AS (
            SELECT b.customer_unique_id,
	               CASE WHEN COUNT(DISTINCT a.order_id) > 1 THEN 'repeated'
		           ELSE 'one-time'
		           END AS customer_type
	        FROM olist_orders a
	             JOIN olist_customers b
		         USING(customer_id)
	        GROUP BY b.customer_unique_id 
    )
    SELECT *
    FROM x JOIN y USING(customer_unique_id)
    WHERE x.order_no = 1 
),
bucketed AS (
     SELECT exp_data.customer_unique_id,
	        CASE WHEN exp_data.delivery_status IN ('late','slightly-late') AND exp_data.review_score IN (1,2) THEN 'bad'
			WHEN exp_data.delivery_status IN ('early','on-time') AND exp_data.review_score IN (4,5) THEN 'good'
			ELSE 'moderate'
			END AS experience_group,
			exp_data.customer_type
	 FROM exp_data
)
SELECT experience_group,
       COUNT(*) AS total_customers,
	   ROUND(100.0 * SUM(CASE WHEN customer_type = 'repeated' THEN 1 ELSE 0 END)/COUNT(*), 2) AS repeat_pct
FROM bucketed
GROUP BY experience_group











