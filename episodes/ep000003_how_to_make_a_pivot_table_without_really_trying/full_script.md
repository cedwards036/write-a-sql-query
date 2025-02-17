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
### Pivot tables
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. The way I see it, there are two main things that separate the
product_sales table from the final output we're looking for:

1. the product_sales table contains one row for each product type sold on
each date, whereas the requested report has one row per date, and separate columns
with the quantity sold on that date for each product type
2. the product_sales table only has data for days on which there were sales, whereas
our manager wants a report with rows for every day in the week, whether or not
there were sales on those days.

I'm going to go ahead and tackle difference #1 first, and then refine the solution
by addressing difference #2.

So, we have multiple rows per product type, and we want multiple columns instead.
Transposing rows to columns like this is a very common type of
data transformation that may be familiar to many of you, especially those versed in
Microsoft Excel. This kind of transformation is generally called a "pivot" or
"pivot table", and is a common requirement in stakeholder-facing, business intelligence
applications, dashboards, reports, etc.

While there are some database systems like
Snowflake that have first-class support for pivoting, with dedicated syntax and
everything, many databases do not. I use Postgres in these videos, and while
Postgres technically has an extension you can install called tablefunc that enables something like a
dedicated pivot "function", the base Postgres flavor of SQL does not have such
functionality. For that reason, and in order to make this solution more generally
applicable, I'm going to show you a way to produce a pivoted structure using
standard SQL, without using any special database-specific functionality.

### CASE statements
Ok, let's start by taking a look at the product sales table to
remind ourselves what we are dealing with. We have a sale_date column which we
want in the final output, so I'll just put that in our SELECT statement here.
Then we have these two columns for product_type and quantity. In the final output,
we want three separate quantity columns, each for the different product types, so
let's sketch out a skeleton of that right now.
```sql
SELECT
	sale_date,
	quantity AS toy_sales_quantity,
	quantity AS book_sales_quantity,
	quantity AS clothing_sales_quantity
FROM product_sales
ORDER BY sale_date;
```
So our final SELECT statement will need to look something like this, with these columns. But right now, all three quantity columns have the same data, and we *want* them
to each contain the quantity data for just that column's product type. So we need some
kind of conditional logic to tell the query to only pull the toy data into
the toy_sales_quantity column, the book data into the book column, etc.

Now, how do you write conditional logic in SQL? Generally, you use a CASE statement,
and that's what we're going to do here. So to write a CASE statement, you need,
at a minimum, a condition, and a value to return when that condition is true.
```sql
CASE WHEN ? THEN ? END
```
In our case, the value we want to return is the `quantity` column from product_sales,
and the condition needs to return true for any rows associated with the current
column's product type, in other words, `WHEN product_type = '<toy, book, etc>'`,
"toy" for the toy column, "book" for the book column, etc. Let's run this and see
how we're doing.
```sql
SELECT
	sale_date,
	CASE WHEN product_type = 'Toy' THEN quantity END AS toy_sales_quantity,
	CASE WHEN product_type = 'Book' THEN quantity END AS book_sales_quantity,
	CASE WHEN product_type = 'Clothing' THEN quantity END AS clothing_sales_quantity
FROM product_sales
ORDER BY sale_date;
```
### ELSE and SUM()
There's some definite progress here. We can see that each product-specific column
now only contains sale quantities for that product *(give examples)*. This still
isn't quite what we want because there are still multiple rows per date, instead
of all the quantities collapsing into one summary row. Also, when no units of a
particular product type were sold on a given date, the query is currently returning
NULL instead of 0 like we want.

Let's fix the second issue first. As you may know if you have used CASE statements
before, you can use the optional ELSE clause to define a "fallback", or default
return value if none of the conditions in your CASE statement are met. So let's give
all of our CASE statements a default of 0. And let's run that...
```sql
SELECT
	sale_date,
	CASE WHEN product_type = 'Toy' THEN quantity ELSE 0 END AS toy_sales_quantity,
	CASE WHEN product_type = 'Book' THEN quantity ELSE 0 END AS book_sales_quantity,
	CASE WHEN product_type = 'Clothing' THEN quantity ELSE 0 END AS clothing_sales_quantity
FROM product_sales
ORDER BY sale_date;
```
Ok, better, now we have 0s instead of nulls. Now we need to collapse the rows so
there is only one row per date. And what can you do in SQL when you want to keep
distinct values in one column while combining or consolidating the values in other columns?
You can aggregate using a GROUP BY statement. We want to GROUP BY sale_date to ensure
that the output contains exactly one row per date, and we need to use an aggregation
function on the other columns to combine their values in some way. This is kind of
an unusual situation, since the main goal of the aggregation is *not* to meaningfully aggregate multiple values. Instead, we have a situation where we know there is at
most *one* useful value per date in each column, and we just want to construct a single
row that has that useful value from each column, if it exists. So actually, there are
several aggregation functions that will work here, but probably the most obvious ones to
use are either SUM() or MAX(). I'm going to arbitrarily go with SUM(), and give this
a run...
```sql
SELECT
	sale_date,
	SUM(CASE WHEN product_type = 'Toy' THEN quantity ELSE 0 END) AS toy_sales_quantity,
	SUM(CASE WHEN product_type = 'Book' THEN quantity ELSE 0 END) AS book_sales_quantity,
	SUM(CASE WHEN product_type = 'Clothing' THEN quantity ELSE 0 END) AS clothing_sales_quantity
FROM product_sales
GROUP BY sale_date
ORDER BY sale_date;
```
Alright, this is great! We have succesfully consolidated down to one summary row
for each date that was in the original product_sales table. And as you can see,
for those dates, our output is exactly matching the expected output shown on the
left here.

### Date spine
The only thing left to do now is to include the missing dates, those dates on which
the store saw no sales. Luckily, there is an extremely useful design pattern
of sorts that can help us out here, and it is generally called a "spine". In our
specific case, you would call it a "date spine", but the same principle works with
any kind of categorical data that you are aggregating.

Basically, you are in a situation where you want to summarize *all* members
of some set, but you only have data for *some* of the members. The solution is to
simply create a new dataset consisting of *all* distinct members of the set you
are trying to summarize, and use *that* as your starting point for the analysis.
Typically, this looks like defining a CTE or temp table, and then LEFT JOINing
from that to the actual dataset you are analyzing.

This will be easier to understand in context, so let's give this a try with our
problem. I have prepared a version of the query that uses a simple date spine
I made using a VALUES clause.
```sql
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

As you can see, I created this simple helper dataset, called date_spine, and all
it contains is a single column with all the unique date values that I want to include
in my analysis. This can then serve as the "spine" on which the "body" of my
analysis depends. I SELECT from the *date_spine* CTE and then LEFT JOIN to my original
source table, product_sales, such that *all* dates from the date_spine will be included
in my output, as well as any sale quantities for those dates that had sales. Everything
we wrote previously with the CASE statements and whatnot still works, but now we
have rows in our output for all the dates we care about.

## Conclusion

And that's pretty much it. We've covered a general strategy for pivoting a table
using standard SQL, and shown the utility of defining a helper dataset called a spine
when source data that you want to summarize has missing values. Before we wrap up
for today I want to add a bit of additional commentary about each of these topics
for those who are interested.

First off, you may notice that in order to create our pivot table, we had to manually
list off columns and CASE statement logic for each value in the column we were pivoting.
This is not ideal because it requires us to know in advance which values to expect,
e.g. which products the store sells, and also is a bit of a pain. Imagine the store
sold 1,000 products, that would be a lot of columns to define manually.

Unfortunately, these are basically just limitations of this method of pivoting. There are various ways
to mitigate these issues, however. Some, but not all, database systems that give you dedicated
PIVOT syntax also have an option for a "dynamic pivot", where the database does
all that stuff in the background for you and you just tell it what columns to pivot
on. If you aren't using one of those databases, though, you can always handle that
yourself in application code. For example, you could write something in Python
that retrieved all unique values in the column you want to pivot, and then
used that to generate and run the appropriate SQL code to pivot on those values.

Lastly, on the subject of spines, I manually defined this date_spine using a VALUES
clause, but there are usually many other ways to do it. For example, sometimes the database system
has some kind of range generator function that lets you automatically generate all values
between a defined start and end point (Postgres does have one of those, but I didn't use
it here). Sometimes you are working with multiple tables that, combined, have all
the values you need, and you just need to UNION the corresponding columns from each
table to construct your spine, then LEFT JOIN from that to each of the aforementioned tables
to perform your analysis. And there are probably more ways besides, but the fundamental
concept is the same, of creating a net-new dataset with all the values you need for your
analysis. This is an extremely helpful technique that I have used many times in my
career.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
