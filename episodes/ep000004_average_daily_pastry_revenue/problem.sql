/*
The operator of a humble pastry stall at a weekly farmer's market wants to get
a financial picture of their fledgeling business. Specifically, they want to
know the average daily revenue per product in the month of February, to find out
which pastries are the best for business.

The young pastry chef has created two tables in a database with the following
structures:

=========
product
=========
+-------------------+---------+
| column            | type    |
+-------------------+---------+
| product_id        | int     |
| product_name      | text    |
| product_price_usd | float   |
+-------------------+---------+

=========
sales
=========
+-----------------------+-----------+
| column                | type      |
+-----------------------+-----------+
| transaction_timestamp | timestamp |
| product_id            | int       | <-- foreign key to product.product_id
| product_quantity      | int       |
+-----------------------+-----------+

The product table contains one record per product sold at the shop, along
with the product's current sale price in USD. The sales table contains
one record per product per transaction. If multiple different types of
products are purchased in a single transaction, each product type will
get its own row in this table, associated with the transaction's timestamp.
If a customer purchases multiple of the same product at one time (e.g. two
muffins), that will be indicated by the number in the product_quantity column.

Write a SQL query that returns the average daily revenue per product name
in the pastry chef's database.

A couple additional notes:
- the pastry stall is only open on Saturdays, so you *don't* need
  to somehow account for non-Saturdays in your analysis. You just need
  to find the average across the dates that appear in the data.
- you don't need to round or otherwise format the averages you compute,
  for example 3.1456 instead of $3.15 is fine.


EXPECTED RESULTS:

product_name|average_daily_revenue_usd|
------------+-------------------------+
Cookie      |                   2.8125|
Muffin      |                        6|
Scone       |                     2.25|

*/



CREATE OR REPLACE TEMP TABLE product AS
SELECT
    product_id,
    product_name,
    product_price_usd
FROM (
    VALUES
    (1, 'Muffin', 1.50),
    (2, 'Scone', 1.00),
    (3, 'Cookie', 0.75)
) AS t (product_id, product_name, product_price_usd);
SELECT *
FROM product;


CREATE OR REPLACE TEMP TABLE sales AS
SELECT
    transaction_timestamp::timestampntz AS transaction_timestamp,
    product_id,
    product_quantity
FROM (
    VALUES

    ('2025-02-01 09:01', 3, 5),
    ('2025-02-01 09:34', 1, 2),
    ('2025-02-01 10:05', 1, 4),
    ('2025-02-01 10:13', 2, 1),
    ('2025-02-01 10:17', 2, 1),

    ('2025-02-08 09:07', 1, 3),
    ('2025-02-08 09:15', 1, 1),
    ('2025-02-08 09:34', 2, 3),
    ('2025-02-08 10:02', 2, 1),
    ('2025-02-08 10:22', 3, 2),

    ('2025-02-15 10:21', 1, 3),
    ('2025-02-15 10:21', 3, 2),
    ('2025-02-15 10:30', 1, 1),
    ('2025-02-15 10:30', 2, 2),
    ('2025-02-15 10:45', 3, 1),

    ('2025-02-22 10:14', 1, 1),
    ('2025-02-22 10:15', 3, 4),
    ('2025-02-22 10:35', 1, 1),
    ('2025-02-22 10:36', 3, 1),
    ('2025-02-22 10:50', 2, 1)
) AS t (transaction_timestamp, product_id, product_quantity);
