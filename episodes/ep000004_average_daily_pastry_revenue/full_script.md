# Average Daily Pastry Revenue

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today is typical of many real-world SQL problems you may encounter,
in that no one piece of it is particularly difficult, but parsing out what all
the pieces *are* and arranging them into a solution requires a bit of thought.

*(read problem statement)*

All right, that's all the set-up for today. If you want to have a crack at solving this problem
yourself, there are links in the video description to this full problem statement and
instructions on how to replicate this coding environment on your local machine. Feel free to
pause the video now, and come back later for a solution walkthrough, coming right up.


## Solution Walkthrough

### Breaking down the problem
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. As I mentioned before, I don't think this problem is particularly
difficult, but it has several components to it that you need to think through
in order to figure out what actually needs to be done. So I'm going to try to
walk through how to break down this problem.

We are being asked to calculate the **average daily revenue per product name**. Let's
break that down a bit. First off, we need to calculate an **average** of some kind,
which means we need to aggregate. More specifically, we need to get the average
of something *per product name*, so when we aggregate, we will want to `GROUP BY`
product_name.

```sql
SELECT
	AVG()
FROM
GROUP BY product_name;
```
Ok, good. Next step, *what* do we need to calculate the average *of*? What
metric do we need to feed into our `AVG()` function? Well, looking
back at the problem statement, we need "daily revenue".
Unfortunately for us, we don't have a column for daily revenue in our source tables,
so we need to construct one ourselves. So let's leave the "outer layer" of this
problem, the average calculation, alone for a bit and focus just on the problem
of getting *daily revenue* per product.

### Daily revenue

The concept of "daily revenue" has two components: the "daily" part, and the "revenue"
part. Let's zoom in a little further, and address each of these in turn. And let's
start with "revenue". Our sales table doesn't have a "revenue" column, but it *does*
have a quantity column. And if we join up to the product table, we can get price
data. And what is revenue but "quantity times price"? So let's use all of that
to create a revenue column for our transaction data. And let's bring in product_name
while we're at it, since we know we'll need that later.

```sql
SELECT
	p.product_name,
	s.transaction_timestamp,
	s.product_quantity * p.product_price_usd AS revenue_usd
FROM sales s
JOIN product p
	ON s.product_id = p.product_id;
```

Alright, we have solved the "revenue" half of the "daily revenue" problem, now let's
tackle the "daily" part. We currently have this transaction_timestamp column, which
is close to what we need, but not quite there. This column has date and time information,
but we want a coarser-grained column that just has date. So, we just need to convert
this transaction_timestamp column into a transaction_date column. There are multiple
ways you can do this, and the syntax for many of these ways will be highly
database-system-dependent. You could extract the date from the timestamp, you could
cast the column to a date type, etc. For simplicity's sake, I am just going to
cast the data type to date using this double-colon syntax which is supported in
a few different database systems at time of recording.

```sql
SELECT
	p.product_name,
	s.transaction_timestamp::date AS transaction_date,
	s.product_quantity * p.product_price_usd AS revenue_usd
FROM sales s
JOIN product p
	ON s.product_id = p.product_id;
```
Ok, now we have the necessary columns at our disposal to calculate daily revenue
per product name. All we need to do is aggregate by date and product_name, and compute
the total (also known as the `SUM()`) of the revenue. For that we can employ
a simple `GROUP BY` statement, and voila!

```sql
SELECT
	p.product_name,
	s.transaction_timestamp::date AS transaction_date,
	SUM(s.product_quantity * p.product_price_usd) AS daily_revenue_usd
FROM sales s
JOIN product p
	ON s.product_id = p.product_id
GROUP BY
	p.product_name,
	transaction_date
ORDER BY transaction_date, product_name;
```
As you can see, we have now constructed a column for "daily revenue". And just to be
safe, we can do a quick spot-check to make sure we are calculating this correctly.
Let's take muffins on February 1, for example. Muffins sell for $1.50 each, and
our sales table indicates we sold a total of 2 + 4 = 6 muffins, and 6 * 1.50
is indeed $9, which is what we see in our aggregate result here.

### Completing the query

Ok, so jumping back up a level, remember why were doing all this in the first place?
We needed to calculate the **average daily revenue per product name**, and back then
we didn't have a column for daily revenue, but now we do, so we essentially just
need to plug it in to the skeleton we previously created. To do that, we will
need to wrap our daily revenue calculation inside a common table expression, or CTE,
and then we can just reference our daily revenue column like so:


```sql
WITH daily_revenues_per_product AS (
	SELECT
		p.product_name,
		s.transaction_timestamp::date AS transaction_date,
		SUM(s.product_quantity * p.product_price_usd) AS daily_revenue_usd
	FROM sales s
	JOIN product p
		ON s.product_id = p.product_id
	GROUP BY
		p.product_name,
		transaction_date
)
SELECT
    product_name,
    AVG(daily_revenue_usd) AS average_daily_revenue_usd
FROM daily_revenues_per_product
GROUP BY product_name
ORDER BY product_name;
```

And there we have it: the average daily revenue per product name. Clearly muffins
are the big winner here.

## Appendix: Order of Operations
Now before I leave you for the day, I want to acknowledge that this is not the
only query that solves this problem. In fact, depending on the circumstances,
in a real-world situation I might want to do a bit of additional work on this
query in order to improve performance.

*(paste alternate query listed below)*

```sql
-- getting average daily quantity first, then joining to get the names for the report; more efficient for large datasets
WITH daily_quantities_sold_per_product AS (
    SELECT
        product_id,
        transaction_timestamp::date AS transaction_date,
        SUM(product_quantity) AS daily_quantity_sold
    FROM sales s
    GROUP BY product_id, transaction_date
), average_daily_quantities_sold_per_product AS (
    SELECT
        product_id,
        AVG(daily_quantity_sold) AS average_daily_quantity_sold
    FROM daily_quantities_sold_per_product
    GROUP BY product_id
)
SELECT
    p.product_name,
    q.average_daily_quantity_sold * p.product_price_usd AS average_daily_revenue_usd
FROM average_daily_quantities_sold_per_product q
JOIN product p
    ON q.product_id = p.product_id
ORDER BY p.product_name;
```
This is another query that returns exactly the same output as the query we arrived
at earlier, but it does so in a slightly different way, using a slightly different
order of operations. And there may be circumstances where you would prefer this
query over the other one. In our toy example here, the database only had 3 products
and 20 transactions. But what if the pastry chef made it big, went multi-national,
and now we are dealing with millions of products and billions of transactions.
If you are an analyst trying to perform this analysis on *that* dataset, you might
find that just attempting to join the billions of transactions to the millions
of products is a very expensive operation, even if the right indexes are in place.

However, what if you switch up the order of operations. What if you compute the average
daily *quantity* sold per product_id first, and only *then* join to the product
table to get product_name and price info to complete the calculation. Now, instead
of joining the product table to several billion transaction-grain records, you
are joining it to a pre-aggregated, product-grain dataset that is potentially several
orders of magnitude smaller. The cost of the aggregation is roughly the same
between the two strategies, but the cost of the join may be substantially improved
by the second strategy. Or not, that's the kind of thing you have to performance-test
for your specific circumstances and your specific data. But it is important to
always keep these kind of optimization strategies in mind. If you find yourself
with a slow query, you should ask yourself if you can reduce the size of the data
sooner in your pipeline, to make later steps more efficient.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!