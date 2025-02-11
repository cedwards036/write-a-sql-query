/*
A retail store manager wants to get a summary of how many
products of each product type the store sold during the week
of February 16, 2025. The store's central database has an existing
summary table called product_sales with the following structure:

sale_date |product_type|quantity|
----------+------------+--------+
2025-02-16|Toy         |      14|
2025-02-16|Book        |       5|
2025-02-17|Book        |      10|
2025-02-19|Clothing    |      20|
2025-02-20|Clothing    |      10|
2025-02-20|Toy         |      10|
2025-02-21|Clothing    |      15|

Each row in the table tells you the total quantity sold of
the given product type on the given date. While this is helpful,
the manager would really like this report to have a different structure.
Specifically, the manager wants the following structure, where each
date during the week of 2025-02-16 - 2025-02-22 appears in precisely
one row, and each product type's sales quantities are summarized
in a dedicated column for that product type.

sale_date |toy_sales_quantity|book_sales_quantity|clothing_sales_quantity|
----------+------------------+-------------------+-----------------------+
2025-02-16|                14|                  5|                      0|
2025-02-17|                 0|                 10|                      0|
2025-02-18|                 0|                  0|                      0|
2025-02-19|                 0|                  0|                     20|
2025-02-20|                10|                  0|                     10|
2025-02-21|                 0|                  0|                     15|
2025-02-22|                 0|                  0|                      0|

Write a SQL query that selects from the product_sales table and produces
the report shown above for the week of 2025-02-16 - 2025-02-22.

Additional info/constraints:
- The report should contain *all* dates from the week in question, even dates on
  which the store saw no sales.
- if the store saw no sales of a given product type on a given date, then
  the report should return 0 for that entry.
- You can assume that the store only sells the product types "Toy",
  "Book", and "Clothing".
- The results should be returned sorted chronologically by sale date.

*/





/*
Set up code
*/
CREATE TEMP TABLE product_sales AS
SELECT
    sale_date::date AS sale_date,
    product_type,
    quantity
FROM (VALUES
    ('2025-02-16', 'Toy', 14),
    ('2025-02-16', 'Book', 5),
    ('2025-02-17', 'Book', 10),
    ('2025-02-19', 'Clothing', 20),
    ('2025-02-20', 'Clothing', 10),
    ('2025-02-20', 'Toy', 10),
    ('2025-02-21', 'Clothing', 15)
) AS t(sale_date, product_type, quantity)
;