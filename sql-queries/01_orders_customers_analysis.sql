CREATE TABLE olist_orders(
order_id VARCHAR(50),
customer_id VARCHAR(50),
order_status VARCHAR(50),
order_purchase_timestamp TIMESTAMP,
order_approved_at TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP,
delivery_status VARCHAR(20)
)

CREATE TABLE olist_customers(
customer_id VARCHAR(50),
customer_unique_id VARCHAR(50),
customer_zip_code_prefix VARCHAR(5),
customer_city VARCHAR(100),
customer_state VARCHAR(2)
)

SELECT COUNT(*) FROM olist_customers
SELECT * FROM olist_orders

/* delivery status and unki value counts */
SELECT delivery_status, COUNT(*) AS total 
FROM olist_orders
GROUP BY delivery_status
ORDER BY COUNT(*) DESC

/* order status and unki value counts*/
SELECT order_status, COUNT(*) AS total
FROM olist_orders
GROUP BY order_status
ORDER BY COUNT(*) DESC

/* cancelled orders dekhna, kahi unme koi delivery date filled to nhi h */
SELECT order_status, order_delivered_customer_date , delivery_status
FROM olist_orders
WHERE order_status = 'canceled' 
      AND 
	  delivery_status IS NOT NUll

/* jo cancelled orders me b data fill tha delivery ka , unn cols ko null krna */
UPDATE olist_orders
SET order_delivered_customer_date = NULL,
    delivery_status = NULL
WHERE order_status = 'canceled' 
      AND 
	  delivery_status IS NOT NUll

/* sirf delivered orders dekho kahi unme koi date ya value null to nhi h ?*/
SELECT order_status, order_delivered_customer_date, delivery_status, order_delivered_carrier_date
FROM olist_orders
WHERE order_status = 'delivered'
      AND
	  order_delivered_customer_date IS NULL

/* kitne orders ka delivery status late h ?*/
SELECT  COUNT(*) AS total_count
FROM olist_orders
WHERE delivery_status = 'late'

/* customer table me kon kon si alag alag states hai and unme total unique customers?*/
SELECT  customer_state, COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers
GROUP BY customer_state
ORDER BY COUNT(DISTINCT customer_unique_id) DESC

/* sabse naye 5 orders dikhao ?*/
SELECT order_id, customer_id
FROM olist_orders
ORDER BY order_purchase_timestamp
LIMIT 5


/* hrr month m kitne orders hue ?*/
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month_name, COUNT(*)
FROM olist_orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', order_purchase_timestamp) DESC

/* sirf vahi states dikhao jinme 1000 s jyda customers h */
SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS total_orders
FROM olist_customers
GROUP BY customer_state
HAVING COUNT(DISTINCT customer_unique_id) > 1000
ORDER BY COUNT(DISTINCT customer_unique_id) DESC

                                                /* JOINS */

/* normal join of both the tables*/
SELECT a.order_id, b.customer_state
FROM olist_orders a
     JOIN olist_customers b
	 ON a.customer_id = b.customer_id

/*harr state k delivered orders ki count ? */
SELECT b.customer_state, COUNT(*) AS total_orders
FROM olist_orders a 
     JOIN olist_customers b 
	 ON a.customer_id = b.customer_id
WHERE a.order_status = 'delivered'
GROUP BY b.customer_state
ORDER BY COUNT(*) DESC

/* harr state m kitne orders late the ?*/
SELECT b.customer_state, COUNT(*) AS late_orders
FROM olist_orders a
     JOIN olist_customers b
	 ON a.customer_id = b.customer_id
WHERE a.delivery_status = 'late'
GROUP BY b.customer_state
ORDER BY COUNT(*) DESC

/*percentage nikalo hrr state m late orders ki*/
SELECT b.customer_state,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN a.delivery_status = 'late' THEN 1 ELSE 0 END) AS late_orders,
	   ROUND(100.0* SUM(CASE WHEN a.delivery_status = 'late' THEN 1 ELSE 0 END)/COUNT(*), 2) AS late_pct
FROM olist_orders a
     JOIN olist_customers b
	 ON a.customer_id = b.customer_id
WHERE a.delivery_status IS NOT NULL
GROUP BY b.customer_state
HAVING COUNT(*) > 1000
       AND ROUND(100.0* SUM(CASE WHEN a.delivery_status = 'late' THEN 1 ELSE 0 END)/COUNT(*), 2) < 5.00
ORDER BY late_pct DESC

/*kitne customers repurchase krte h store se?*/
SELECT COUNT(*) 
FROM (SELECT b.customer_unique_id AS customer_id,
             COUNT(DISTINCT a.order_id) AS orders
     FROM olist_orders a
     JOIN olist_customers b
	 ON a.customer_id = b.customer_id 
     WHERE a.order_status = 'delivered'
     GROUP BY b.customer_unique_id
     /*HAVING COUNT(DISTINCT a.order_id) > 1*/
) AS total_repeated_customers












	  
    
