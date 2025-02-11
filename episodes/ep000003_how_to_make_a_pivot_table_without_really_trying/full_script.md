# How to Make a Pivot Table Without Really Trying

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today involves a relatively common data transformation
technique that you can employ when you need data that is split across
multiple rows to instead be split across multiple *columns* in the same row.

*(read problem statement)*

All right, that's all the set-up for today. If you want to have a crack at solving this problem
yourself, there are links in the video description to this full problem statement and
instructions on how to replicate this coding environment on your local machine. Feel free to
pause the video now, and come back later for a solution walkthrough, coming right up.


## Solution Walkthrough
TODO write the rest of the script

TODO https://stackoverflow.com/a/14113580 < see how you can generate the date spine

```sql
--using date spine and multiple filtered CTEs
WITH date_spine AS (
    SELECT
        sale_date::date AS sale_date
    FROM (VALUES
        ('2025-02-16'),
        ('2025-02-17'),
        ('2025-02-18'),
        ('2025-02-19'),
        ('2025-02-20'),
        ('2025-02-21'),
        ('2025-02-22')) AS d(sale_date)
), toy_sales AS (
    SELECT *
    FROM product_sales
    WHERE product_type = 'Toy'
), book_sales AS (
    SELECT *
    FROM product_sales
    WHERE product_type = 'Book'
), clothing_sales AS (
    SELECT *
    FROM product_sales
    WHERE product_type = 'Clothing'
)
SELECT
    d.sale_date,
    COALESCE(t.quantity, 0) AS toy_sales_quantity,
    COALESCE(b.quantity, 0) AS book_sales_quantity,
    COALESCE(c.quantity, 0) AS clothing_sales_quantity
FROM date_spine d
LEFT JOIN toy_sales t
    ON d.sale_date = t.sale_date
LEFT JOIN book_sales b
    ON d.sale_date = b.sale_date
LEFT JOIN clothing_sales c
    ON d.sale_date = c.sale_date
ORDER BY d.sale_date;
```


```sql
--using date spine and case statements
WITH date_spine AS (
    SELECT
        sale_date::date AS sale_date
    FROM (VALUES
        ('2025-02-16'),
        ('2025-02-17'),
        ('2025-02-18'),
        ('2025-02-19'),
        ('2025-02-20'),
        ('2025-02-21'),
        ('2025-02-22')) AS d(sale_date)
)
SELECT
    d.sale_date,
    SUM(CASE WHEN product_type = 'Toy' THEN quantity ELSE 0 END) AS toy_sales_quantity,
    SUM(CASE WHEN product_type = 'Book' THEN quantity ELSE 0 END) AS book_sales_quantity,
    SUM(CASE WHEN product_type = 'Clothing' THEN quantity ELSE 0 END) AS clothing_sales_quantity
FROM date_spine d
LEFT JOIN product_sales p
    ON d.sale_date = p.sale_date
GROUP BY d.sale_date
ORDER BY d.sale_date;
```

```sql
--using date spine and PIVOT statement in Snowflake syntax
 WITH date_spine AS (
    SELECT
        sale_date::date AS sale_date
    FROM (VALUES
        ('2025-02-16'),
        ('2025-02-17'),
        ('2025-02-18'),
        ('2025-02-19'),
        ('2025-02-20'),
        ('2025-02-21'),
        ('2025-02-22')) AS d(sale_date)
), pivoted_sales AS (
    SELECT *
    FROM product_sales
    PIVOT(
        SUM(quantity) FOR product_type IN (
            'Toy',
            'Book',
            'Clothing'
        )
    ) AS p(
        sale_date,
        toy_sales_quantity,
        book_sales_quantity,
        clothing_sales_quantity
    )
)
SELECT
    d.sale_date,
    COALESCE(p.toy_sales_quantity, 0) AS toy_sales_quantity,
    COALESCE(p.book_sales_quantity, 0) AS book_sales_quantity,
    COALESCE(p.clothing_sales_quantity, 0) AS clothing_sales_quantity
FROM date_spine d
LEFT JOIN pivoted_sales p
    ON d.sale_date = p.sale_date
ORDER BY d.sale_date;
```