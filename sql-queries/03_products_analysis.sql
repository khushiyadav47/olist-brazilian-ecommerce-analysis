/* CREATING A TABLE FOR olist_products.csv*/
CREATE TABLE olist_products(
     product_id VARCHAR(50),
	 product_category VARCHAR(50)
)

/*total no of rows in the products*/
SELECT COUNT(*) FROM olist_products

/* hrr product category m kitne products hai?*/
SELECT product_category, COUNT(*) AS no_of_products
FROM olist_products
GROUP BY product_category
ORDER BY no_of_products DESC

/*top 10 categories jinme sbse jyda products hai ?*/
SELECT product_category, COUNT(*) AS no_of_products
FROM olist_products
GROUP BY product_category
ORDER BY no_of_products DESC
LIMIT 10

/*unknown category wale products kitne percentage hai?*/
SELECT COUNT(*) AS total_products,
       SUM(CASE WHEN product_category = 'unknown' THEN 1 ELSE 0 END) AS count_product,
	   ROUND(100.0 * SUM(CASE WHEN product_category = 'unknown' THEN 1 ELSE 0 END)/COUNT(*), 2)
FROM olist_products

/*konse yr m kitne orders hue ?*/
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year_number,
       COUNT(*) AS no_of_orders
FROM olist_orders
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY year_number

/* hafte k konse din sabse jyda orders aate h?*/
/* here 0 represents Sunday, 1 Monday, 2 Tuesday and ..... 6 Saturday*/
SELECT EXTRACT(DOW FROM order_purchase_timestamp) AS day_no,
       COUNT(*) AS no_of_orders
FROM olist_orders
GROUP BY EXTRACT(DOW FROM order_purchase_timestamp)

/*orders ko customer tak pahauchne m kitna time laga?*/
SELECT (order_estimated_delivery_date::date - order_delivered_customer_date::date) AS time_gap,
        COUNT(*) AS no_of_orders
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY (order_estimated_delivery_date::date - order_delivered_customer_date::date)
ORDER BY time_gap 

/* orders ko customers tak pahauchne ka avg time ?*/
SELECT ROUND(AVG(order_estimated_delivery_date::date - order_delivered_customer_date::date), 2) AS avg_time
FROM olist_orders
WHERE order_status = 'delivered'



/* CREATING A TABLE FOR olist_order_items_dataset.csv*/
CREATE TABLE olist_order_items(
     order_id VARCHAR(50),
	 order_item_id INT,
	 product_id VARCHAR(50),
	 seller_id VARCHAR(50),
	 shipping_limit_date TIMESTAMP,
	 price DECIMAL,
	 freight_value DECIMAL
)

/* total kitne orders hai ? (unique)*/
SELECT order_id ,
       COUNT(*) AS total_count
FROM olist_order_items
GROUP BY order_id

/*sabse costly item ka price ?*/
SELECT MAX(price) FROM olist_order_items

/*average price and average freight value kitni h?*/
SELECT ROUND(AVG(price), 2) AS avg_price,
       ROUND(AVG(freight_value), 2) AS avg_freight
FROM olist_order_items

/*hrr seller n kitne items sell kiye? top 10 sellers nikalo*/
SELECT seller_id,
       COUNT(*) AS total_items
FROM olist_order_items
GROUP BY seller_id
ORDER BY total_items DESC
LIMIT 10

/*harr product kitni baar bika? top 10 products btao*/
SELECT b.product_category,
       COUNT(*) AS items_count
FROM olist_order_items a
     JOIN olist_products b
	 ON a.product_id = b.product_id
GROUP BY b.product_category 
ORDER BY items_count DESC
LIMIT 10

/*kis seller ka total revenue sbse jyda hai?*/
SELECT seller_id,
       SUM(price) AS revenue
FROM olist_order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10

/*kaunsi product category ne sabse jyada revenue diya?*/
SELECT b.product_category,
       SUM(price) AS revenue
FROM olist_order_items a
     JOIN olist_products b
	 ON a.product_id = b.product_id
GROUP BY b.product_category
ORDER BY revenue DESC
LIMIT 5

/*kis month m kitna revenue aaya (month and year dono s group kro)? */
SELECT EXTRACT(MONTH FROM a.order_delivered_customer_date) AS month_number,
       EXTRACT(YEAR FROM a.order_delivered_customer_date) AS year_number,
       SUM(b.price) AS revenue
FROM olist_orders a
     JOIN olist_order_items b ON a.order_id = b.order_id
	 JOIN olist_products c ON b.product_id = c.product_id
WHERE a.order_status = 'delivered' AND a.order_delivered_customer_date IS NOT NULL
GROUP BY EXTRACT(MONTH FROM a.order_delivered_customer_date),
         EXTRACT(YEAR FROM a.order_delivered_customer_date)
ORDER BY year_number

/*kis category k reviews ka avg score sabse kam aaya (vo categories leni h jinme min 100 products toh ho) ?*/
SELECT c.product_category,
       COUNT(*) AS items_sold,
       ROUND(AVG(a.review_score), 2) AS avg_score
FROM olist_reviews a
     JOIN olist_order_items b ON a.order_id = b.order_id
	 JOIN olist_products c ON b.product_id = c.product_id
GROUP BY c.product_category
HAVING COUNT(*) >= 100
ORDER BY avg_score

/*kis state k customers sbse jyda spend krte h ? (find state wise revenue)*/
SELECT b.customer_state,
       SUM(c.price) AS revenue
FROM olist_orders a 
     JOIN olist_customers b ON a.customer_id = b.customer_id
	 JOIN olist_order_items c ON a.order_id = c.order_id
GROUP BY b.customer_state
ORDER BY revenue DESC

/*kis state m customers ka avg revenue sbse jyda hai?*/
SELECT b.customer_state,
       SUM(c.price) AS revenue,
       COUNT(DISTINCT b.customer_unique_id) AS total_customers,
	   ROUND(SUM(c.price)/COUNT(DISTINCT b.customer_unique_id) ,2) AS avg_revenue
FROM olist_orders a 
     JOIN olist_customers b ON a.customer_id = b.customer_id
	 JOIN olist_order_items c ON a.order_id = c.order_id
GROUP BY b.customer_state
HAVING COUNT(DISTINCT b.customer_unique_id) >= 100
ORDER BY avg_revenue DESC













	   