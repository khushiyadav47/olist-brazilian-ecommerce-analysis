CREATE TABLE olist_payments(
     order_id VARCHAR(50),
	 payment_sequential INT,
	 payment_type VARCHAR(50),
	 payment_installments INT,
	 payment_value DECIMAL
)

SELECT * FROM olist_payments 
LIMIT 5

/*total kitne unique orders hai?*/
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM olist_payments

/*kaunsa payment type kitni baar use hua and sbse jyda konsa payment type use hua?*/
SELECT payment_type,
       COUNT(*) AS total_count
FROM olist_payments
GROUP BY payment_type
ORDER BY total_count DESC

/*average payment value and sabse badi payment value kitni hai?*/
SELECT ROUND(AVG(payment_value), 2) AS avg_value,
       MAX(payment_value) AS max_value
FROM olist_payments

/*hrr payment type ki payment value kitni hai?*/
SELECT payment_type,
       SUM(payment_value) AS total_payment
FROM olist_payments
GROUP BY payment_type
ORDER BY total_payment DESC

/*kaunse payment installments sbse jyda use hote h?*/
SELECT payment_installments,
       COUNT(*) AS total_count
FROM olist_payments
GROUP BY payment_installments
ORDER BY total_count DESC

/*credit card payment_type me average installments kitni hai?*/
SELECT ROUND(AVG(payment_installments), 2) AS avvg_install
FROM olist_payments
WHERE payment_type = 'credit_card'

/*hrr month ka average payment kitna hai?*/
SELECT EXTRACT(MONTH FROM a.order_purchase_timestamp) AS month_no,
       EXTRACT(YEAR FROM a.order_purchase_timestamp) AS year_no,
	   SUM(b.payment_value) AS revenue
FROM olist_orders a
     JOIN olist_payments b
	 ON a.order_id = b.order_id
GROUP BY EXTRACT(MONTH FROM a.order_purchase_timestamp),
       EXTRACT(YEAR FROM a.order_purchase_timestamp)
ORDER BY year_no

/*kis order status me sbse jyda payments hui h ?*/
SELECT order_status,
       ROUND(SUM(payment_value), 2) AS revenue
FROM olist_orders a
     JOIN olist_payments b
	 ON a.order_id = b.order_id
GROUP BY order_status
ORDER BY revenue DESC

/*kis state k customers sabse jyda credit card use karte hai?*/
SELECT b.customer_state,
       COUNT(*) AS credit_count
FROM olist_orders a
     JOIN olist_customers b ON a.customer_id = b.customer_id
	 JOIN olist_payments c ON a.order_id = c.order_id
WHERE c.payment_type = 'credit_card'
GROUP BY b.customer_state
ORDER BY credit_count DESC

/*kaunsi product category me sabse jyda boleto payment type h?*/
SELECT b.product_category,
       COUNT(*) AS boleto_count
FROM olist_order_items a
     JOIN olist_products b ON a.product_id = b.product_id
	 JOIN olist_payments c ON a.order_id = c.order_id
WHERE payment_type = 'boleto'
GROUP BY b.product_category
ORDER BY boleto_count DESC

/*kitne orders ek se jyda payment type s hue?*/
SELECT order_id, 
       COUNT(DISTINCT payment_type) AS payment_types
FROM olist_payments 
GROUP BY order_id
HAVING COUNT(DISTINCT payment_type) > 1
ORDER BY payment_types DESC






