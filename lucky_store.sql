/* 1. Business Requirement: Calculate the average transaction amount for each payment
method, including the total number of transactions and the total amount collected. */

SELECT pm.payment_method,
COUNT(t.transaction_id) AS total_transactions,
SUM(pm.payment_amount) AS total_amount_collected,
AVG(pm.payment_amount) AS avg_transaction_amount
FROM PaymentMethod pm
LEFT JOIN Transactions t ON pm.payment_method = t.payment_method
GROUP BY pm.payment_method;

/* 2. Business Requirement: Retrieve the top 5 items with the highest sales and their
corresponding categories. */

SELECT i.item_name, c.category, SUM(isales.items_sold) AS total_sales
FROM Items i
INNER JOIN Category c ON i.category_id = c.category_id
LEFT JOIN item_sales isales ON i.SKU = isales.SKU
GROUP BY i.item_name, c.category
ORDER BY total_sales DESC
LIMIT 5;

/* 3. Business Requirement: Find the customers who made transactions using more than one
payment method.*/

SELECT CONCAT(c.customer_first_name, ' ', c.customer_last_name) AS customer_name
FROM Customer c
JOIN Transactions t ON c.customer_reference_id = t.customer_reference_id
JOIN PaymentMethod pm ON t.payment_method = pm.payment_method
GROUP BY c.customer_reference_id
HAVING COUNT(DISTINCT t.payment_method) > 1;

/* 4. Business Requirement: Calculate the total refunds issued for each item category. */

SELECT c.category, SUM(pm.refund_amount) AS total_refunds
FROM Category c
LEFT JOIN Items i ON c.category_id = i.category_id
LEFT JOIN item_sales isales ON i.SKU = isales.SKU
LEFT JOIN Transactions t ON isales.transaction_id = t.transaction_id
LEFT JOIN PaymentMethod pm ON t.payment_method = pm.payment_method
GROUP BY c.category;

/* 5. Business Requirement: Identify customers who have made purchases in all available item
categories. */

SELECT CONCAT(c.customer_first_name, ' ', c.customer_last_name) AS customer_name
FROM Customer c
JOIN Transactions t ON c.customer_reference_id = t.customer_reference_id
JOIN item_sales isales ON t.transaction_id = isales.transaction_id
JOIN Items i ON isales.SKU = i.SKU
JOIN Category cat ON i.category_id = cat.category_id
GROUP BY c.customer_reference_id
HAVING COUNT(DISTINCT cat.category_id) = (SELECT COUNT(DISTINCT category_id) FROM
Category);

/* 6. Business Requirement: Calculate the total net sales and taxes for each category, including
only categories with positive net sales. */

SELECT c.category,
SUM(c.net_sales) AS total_net_sales,
SUM(c.taxes) AS total_taxes
FROM Category c
GROUP BY c.category
HAVING SUM(c.net_sales) > 0;

/* 7. Business Requirement: Find the items with the highest average price within each category. */

SELECT c.category, i.item_name, AVG(i.item_price) AS avg_item_price
FROM Category c
JOIN Items i ON c.category_id = i.category_id
GROUP BY c.category, i.item_name
HAVING AVG(i.item_price) = (SELECT MAX(avg_price) FROM (SELECT c2.category,
AVG(i2.item_price) AS avg_price
FROM Category c2
JOIN Items i2 ON c2.category_id = i2.category_id
GROUP BY c2.category, i2.item_name) AS avg_prices);

/* 8. Business Requirement: Retrieve the customers who have not made any purchases. */

SELECT CONCAT(c.customer_first_name, ' ', c.customer_last_name) AS customer_name
FROM Customer c
LEFT JOIN Transactions t ON c.customer_reference_id = t.customer_reference_id
WHERE t.transaction_id IS NULL;

/* 9. Business Requirement: Calculate the total number of items sold for each payment method. */

SELECT pm.payment_method, SUM(isales.items_sold) AS total_items_sold
FROM PaymentMethod pm
LEFT JOIN Transactions t ON pm.payment_method = t.payment_method
LEFT JOIN item_sales isales ON t.transaction_id = isales.transaction_id
GROUP BY pm.payment_method;

/* 10. Business Requirement: Identify the categories with the highest ratio of refunds to gross
sales. */

SELECT c.category,
SUM(pm.refunds) / SUM(c.gross_sales) AS refund_to_gross_ratio
FROM Category c
LEFT JOIN Transactions t ON c.category_id = t.category_id
LEFT JOIN PaymentMethod pm ON t.payment_method = pm.payment_method
GROUP BY c.category
ORDER BY refund_to_gross_ratio DESC;