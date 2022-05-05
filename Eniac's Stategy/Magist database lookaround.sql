
# Number of orders
SELECT 
    COUNT(*)
FROM
    magist.orders;
 #99441 orders till date 
 
 
 #
 SELECT COUNT(product_id)
 FROM order_items;

#Number of orders delivered
SELECT 
    COUNT(*) AS orders_delivered
FROM
    orders
WHERE
    order_status = 'delivered';
#96478 orders delivered


SELECT 
    COUNT(*) AS orders_delivered
FROM
    orders
WHERE
    NOT order_status = 'delivered';
# 2963 orders not delivered


#Late deliveries
SELECT 
    COUNT(order_id)
FROM
    orders
WHERE
    order_delivered_customer_date > order_estimated_delivery_date
        AND order_status = 'delivered';
        

SELECT COUNT(*)
FROM orders
WHERE order_status = "delivered"
AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0;
#7826 orders were late delivered




#On time delivery

SELECT COUNT(*)
FROM orders
WHERE order_status = "delivered"
AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0;
#89805

#Orders cancelled
SELECT 
    COUNT(*) AS orders_cancelled
FROM
    orders
WHERE
     order_status = 'canceled';
#625 orders were cancelled



# Work on grouping by Month, so far Magist is gaining customers



#Number of orders per year and month
SELECT 
    YEAR(order_purchase_timestamp) AS year,
    MONTH(order_purchase_timestamp) AS month,
    COUNT(*) AS orders
FROM
    orders
GROUP BY 2 , 1
ORDER BY 1 , 2;


#Orders over the years
#Orders from 2016
SELECT 
	"2016" AS "YEAR",
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2016

UNION
#Orders from 2017
SELECT 
	"2017",
    COUNT(DISTINCT order_id) AS orders_2017
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2017

UNION
#Orders from 2018
SELECT 
	"2018",
    COUNT(DISTINCT order_id) AS orders_2018
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2018;


#Number of products by magist
SELECT 
    COUNT(DISTINCT product_id)
FROM
    products;
#32951 products


#Number of products by category
SELECT 
    COUNT(product_id) AS number_of_products,
    product_category_name
FROM
    products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;

#74 different product categories

#Number of orders per product category
SELECT COUNT(order_id),  product_category_name
FROM order_items ot
LEFT JOIN products p
ON ot.product_id = p.product_id
GROUP BY product_category_name
ORDER BY COUNT(order_id) DESC;





SELECT 
    COUNT(DISTINCT product_id)
FROM
    order_items;

#32952 products sold on orders. All products were sold atleast once. 

#Most expensive and cheapest products 
SELECT 
    MAX(price), MIN(price)
FROM
    order_items;


#Most expensive and cheapest orders
SELECT 
    MAX(payment_value), MIN(payment_value)
FROM
    order_payments;

#Number of customers in 2016
SELECT 
    COUNT(DISTINCT customer_id) AS customers_2016,
    "2016"
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2016

UNION

#Number of customers in 2017
SELECT 
    COUNT(DISTINCT customer_id) AS customers_2017,
    "2017"
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2017

UNION
#Number of customers in 2018
SELECT 
    COUNT(DISTINCT customer_id) AS customers_2018,
    "2018"
FROM
    orders
WHERE
    YEAR(order_purchase_timestamp) = 2018;



#Total customers till date
SELECT 
    COUNT(DISTINCT (customer_id))
FROM
    customers;


#Top selling product categories
SELECT 
    COUNT(order_id) AS "No of times ordered", product_category_name_english AS "Product Category"
FROM
    order_items o
        LEFT JOIN
    products p ON o.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pt ON p.product_category_name = pt.product_category_name
GROUP BY product_category_name_english
ORDER BY COUNT(order_id) DESC
LIMIT 10;

#Number of sellers
SELECT DISTINCT
    COUNT(seller_id)
FROM
    sellers
    
LEFT JOIN ;
#3095


#AVG monthly revenue (check again)
/*SELECT 
    seller_id, AVG(price)
FROM
    order_items
GROUP BY seller_id , MONTH(shipping_limit_date)
ORDER BY AVG(price) DESC;*/

SELECT 
    seller_id, AVG(monthly_rev) AS average
FROM
    (SELECT 
        seller_id,
             MONTH(shipping_limit_date),
            SUM(price) AS monthly_rev
    FROM
        order_items
    GROUP BY 1 , 2) AS monthly
GROUP BY seller_id
ORDER BY AVG(monthly_rev) DESC;

SELECT 
    seller_id, ROUND(AVG(total_rev), 2) AS avg_rev
FROM
    (SELECT 
        sellers.seller_id,
            YEAR(order_items.shipping_limit_date) AS year,
            MONTH(order_items.shipping_limit_date) AS month,
            ROUND(SUM(order_items.price), 2) AS total_rev
    FROM
        sellers
    LEFT JOIN order_items ON sellers.seller_id = order_items.seller_id
    GROUP BY sellers.seller_id , year , month
    ORDER BY year , month) AS monthly_rev
GROUP BY seller_id
ORDER BY avg_rev DESC;

select seller_id, round(avg(price + freight_value), 5) as revenue, month(shipping_limit_date), year(shipping_limit_date)
from order_items
group by  seller_id, month(shipping_limit_date) , year(shipping_limit_date) 
order by  shipping_limit_date desc;

#Classification of orders based on delay in delivery
SELECT 
    product_category_name_english, count(product_category_name_english)
    #order_delivered_customer_date,
    #order_estimated_delivery_date
FROM
    orders o
        LEFT JOIN
    order_items ot ON o.order_id = ot.order_id
        LEFT JOIN
    products p ON ot.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pt ON p.product_category_name = pt.product_category_name
WHERE
    order_delivered_customer_date > order_estimated_delivery_date
        AND order_status = 'delivered'
GROUP BY product_category_name_english
ORDER BY 2 DESC;
#ORDER BY (order_delivered_customer_date - order_estimated_delivery_date) DESC;

#Average delay in orders
SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date)) AS Average_delay_in_days
FROM
    orders;
    
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_del_time
FROM orders;
# 12.09 days



#Number of orders on tech categories
SELECT 
    product_category_name_english, COUNT(order_id)
FROM
    products p
        LEFT JOIN
    product_category_name_translation pt ON p.product_category_name = pt.product_category_name
        LEFT JOIN
    order_items ot ON p.product_id = ot.product_id
WHERE
    product_category_name_english IN ('consoles_games' , 'computer_accessories',
        'pc_gamer',
        'computer',
        'tablets_printing_image',
        'dvds_blu_ray')
GROUP BY product_category_name_english
ORDER BY COUNT(order_id) DESC;




SELECT 
    COUNT(pr.product_id),
    COUNT(oi.order_id),
    pr.product_category_name
FROM
    products pr
        LEFT JOIN
    order_items oi ON oi.product_id = pr.product_id
WHERE
    product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY product_category_name;

		SELECT COUNT(order_id),  product_category_name
		FROM order_items ot
		LEFT JOIN products p
		ON ot.product_id = p.product_id
        WHERE product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
		GROUP BY product_category_name
		ORDER BY COUNT(order_id) DESC ;



SELECT product_category_name
FROM products
WHERE product_category_name IN ("audio","eletronics", "pcs", "telefonia", "telefonia_fixa")
GROUP BY product_category_name;

SELECT products.product_category_name, COUNT(order_items.product_id) AS num_items_sold
FROM order_items
INNER JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY products.product_category_name
ORDER BY 2 DESC
;

SELECT  COUNT(pr.product_id), COUNT(oi.order_id), pr.product_category_name
FROM products pr LEFT JOIN order_items oi ON oi.product_id= pr.product_id
WHERE product_category_name IN ('informatica_acessorios','consoles_games','audio','eletronicos','pcs', 'pc_gamer', 'tablets_impressao_imagem')
GROUP BY product_category_name;




SELECT products.product_category_name, ROUND(AVG(order_items.price), 2)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY products.product_category_name;

#Average price of products
SELECT  AVG(oi.price)
FROM order_items oi
LEFT JOIN orders o ON o.order_id=oi.order_id
WHERE order_status="delivered";


SELECT COUNT(*)
FROM (
SELECT products.product_category_name, order_items.price,
    CASE
        WHEN price <= 100 THEN "very cheap"
        WHEN price <= 300 THEN "cheap"
        WHEN price <= 1000 THEN "moderate"
        WHEN price > 1000 THEN "expensive"
        END AS price_category        
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
ORDER BY order_items.price
) AS sales_table
WHERE price_category = "expensive";

SELECT products.product_category_name, order_items.price,
    CASE
        WHEN price <= 100 THEN "very cheap"
        WHEN price <= 300 THEN "cheap"
        WHEN price <= 1000 THEN "moderate"
        WHEN price > 1000 THEN "expensive"
        END AS price_category        
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
ORDER BY order_items.price;


#Total products under each category
SELECT price_category, COUNT(*)
FROM (
SELECT products.product_category_name, order_items.price,
    CASE
        WHEN price <= 100 THEN "very cheap"
        WHEN price <= 300 THEN "cheap"
        WHEN price <= 1000 THEN "moderate"
        WHEN price > 1000 THEN "expensive"
        END AS price_category        
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
ORDER BY order_items.price
) AS sales_table
GROUP BY price_category
ORDER BY COUNT(*) DESC;




SELECT COUNT(*)
FROM order_items o
LEFT JOIN products p
ON o.product_id = p.product_id
WHERE product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem") AND price >1000;


SELECT COUNT(*)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem");


SELECT AVG(avg_rev)
FROM
(
SELECT 
    seller_id, ROUND(AVG(total_rev), 2) AS avg_rev
FROM
    (SELECT 
        sellers.seller_id,
            YEAR(order_items.shipping_limit_date) AS year,
            MONTH(order_items.shipping_limit_date) AS month,
            ROUND(SUM(order_items.price), 2) AS total_rev
    FROM
        sellers
    LEFT JOIN order_items ON sellers.seller_id = order_items.seller_id
    LEFT JOIN products ON order_items.product_id = products.product_id
    WHERE
        products.product_category_name IN ('audio' , 'consoles_games', 'eletronicos', 'informatica_acessorios', 'pc_gamer', 'pcs', 'tablets_impressao_imagem')
    GROUP BY sellers.seller_id , year , month
    ORDER BY year , month) AS monthly_rev
GROUP BY seller_id
ORDER BY avg_rev DESC) AS average;

SELECT AVG(avg_rev)
FROM
(

SELECT seller_id, ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT sellers.seller_id, YEAR(order_items.shipping_limit_date) AS year,
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM sellers
LEFT JOIN order_items
ON sellers.seller_id = order_items.seller_id
GROUP BY sellers.seller_id, year, month
ORDER BY year, month
) AS monthly_rev
GROUP BY seller_id
ORDER BY avg_rev DESC) AS avg;

SELECT ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT order_items.seller_id, YEAR(order_items.shipping_limit_date) AS year, 
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM order_items
GROUP BY seller_id, year, month
) AS avg_monthly_rev;


SELECT order_items.seller_id, YEAR(order_items.shipping_limit_date) AS year, 
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY seller_id, year, month