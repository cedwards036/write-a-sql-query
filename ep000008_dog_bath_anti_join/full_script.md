# Squashing Recital Reservations

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today involves a special kind of join technique that is
an indespensible part of your SQL query writing toolkit.

*(read problem statement)*

All right, that's all the set-up for today. If you want to have a crack at solving
this problem yourself, there are links in the video description to this full problem
statement and instructions on how to replicate this coding environment on your
local machine. Feel free to pause the video now, and come back later for a solution
walkthrough, coming right up.

## Solution Walkthrough

### Anti-joins
Alright, welcome back everyone. We will now take a look at a few possible solutions
to this problem. I'm going to get right to the point with this one, since more
than any previous problem I've solved on this channel, this one was designed to
showcase a very specific SQL concept, specifically the **anti-join**.
If you think of a regular join as a way to bring together rows with *common* values
found in *both* tables, an anti-join is basically just the opposite of that--identifying
rows in one table that *do not* match any rows in the other table, based on some
specific condition. In our case today, the condition is a very simple one: an
equality match on the `dog_name` columns: "Does the dog name from the nail trim
table exist in the bath table?".

Now, once you've identified that a problem calls for an anti-join, you have at
least three options for how to implement it: using LEFT JOIN with a NULL check,
using a NOT IN clause, and using a NOT EXISTS clause. I'm going to briefly review
each of these possible solutions now.

### LEFT JOIN with NULL check
I'm going to start with the strategy I have personally used the most, the LEFT
JOIN with NULL check strategy. As the name implies, this strategy has two
components: a left join, and a NULL check. To better explain exactly how this
works, I'm going to start with just the left join part and build up from there.
```sql
SELECT DISTINCT
	n.dog_name AS left_dog_name,
	b.dog_name AS right_dog_name
FROM nail_trim_appointments n
LEFT JOIN bath_appointments b
	ON n.dog_name = b.dog_name
ORDER BY left_dog_name;
```
So all this query is doing is LEFT JOINing from the nail trim table to the bath
table, and to better illustrate the point here, I'm selecting the dog_name columns
from *both* the left and the right-hand tables in the join. As you would expect
from a LEFT JOIN, the results contain *all* dog
names from the left hand table, `nail_trim_appointments`, but only contain *matching*
dog_names from the right hand table, `batch_appointments`. For rows that couldn't
find a match, the query just returns NULL for any values sourced from the
right-hand table. And this gives us a very convenient way to identify values
that *only* exist in the left-hand table: we just need to filter *out* the records
that return non-null values from the right-hand table, in other words we need to
filter *to* rows where the key column from the right-hand table IS NULL.
```sql
SELECT DISTINCT
	n.dog_name
FROM nail_trim_appointments n
LEFT JOIN bath_appointments b
	ON n.dog_name = b.dog_name
WHERE b.dog_name IS NULL
ORDER BY dog_name;
```
And if we add in that filter, and clean up our output a little bit, you can see
we are now returning the expected results. And that is, in a nutshell, the LEFT
JOIN with NULL check strategy for anti-joins.

### NOT IN clause
Moving on to the next strategy, the NOT IN clause. A very natural way to describe
our current problem in plain english would be to say, "find all the dog_names
from the nail trim table that are NOT IN the bath table". And it turns out there
is SQL syntax that lets us write almost exactly that, and here it is:
```sql
SELECT DISTINCT
	dog_name
FROM nail_trim_appointments
WHERE dog_name NOT IN (
	SELECT dog_name
	FROM bath_appointments
)
ORDER BY dog_name;
```
As you can see here, we are selecting the list of dog names from the bath_appointments
table in a subquery, and passing the results to this NOT IN clause, and it works
pretty much the way you would expect. It filters the overall query results to only
those dog names that do not appear in the the selected dog_name column from the
bath_appointments table. There's honestly not too much more to say about this one,
so I will just move on to the third and final strategy, the NOT EXISTS clause.

### NOT EXISTS clause
```sql
SELECT DISTINCT
	n.dog_name
FROM nail_trim_appointments n
WHERE NOT EXISTS (
	SELECT *
	FROM bath_appointments b
	WHERE b.dog_name = n.dog_name
)
ORDER BY n.dog_name;
```
This one is kind of similar to the NOT IN clause strategy in that it uses special
syntax in the WHERE condition in conjunction with a subquery, but there are some
important differences. As you can see, the subquery used in this strategy is kind
of unusual in that it actually references a column from the outer query, here
in the WHERE condition *(b.dog_name = n.dog_name)*. This situation, a subquery
referencing values from the outer query, is referred to as a **correlated subquery**.

This correlated subquery is using a WHERE clause to effectively perform a standard INNER JOIN between
the nail table and the bath table, and therefore this subquery will return a value
every time a nail-trim dog name *matches* a bath dog name. That's the opposite
of what we want, we want the dog names that *don't* match, so we pass the subquery
results to a NOT EXISTS clause. This means that our *outer* query will be filtered
to only return a value when the *subquery* does not return a value, in other words
when the results of the subquery do not exist. I'll admit, I find this strategy
kind of convoluted, and I personally don't use it much if at all. But it is a perfectly
valid way to implement an anti-join in SQL, so I thought I should mention it.

### Comparisons
So, that's a quick overview of the three main strategies for performing an anti-join.
Your next question might quite reasonably be: which one should I use? Is one of them
better in certain situations than others, etc. And the most important takeaway here
is that, *it mostly depends on which database system you are using, and how these
three strategies are treated under the hood in that specific system*. Before deploying
one of these strategies in your production code, you should do some research and
potentially analyze some query plans to fully understand the implications each
of these strategies has for your database's query planner. It is quite possible
that the choice makes no difference, that your database translates all three of
these strategies into the exact same query plan under the hood. It is also possible
that the database treats one or more of them differently, which can have some
performance implications depending on which one you pick. So, in short, it depends,
you just gotta do your research.

That being said, beyond pure performance considerations, there are are few other
differences between the strategies. Notably, the NOT IN clause strategy is the most
restrictive, because it only works with equality comparison logic. It is also much
harder to use if you need to compare values across multiple columns, instead of
just one column like in our problem today. In contrast, the LEFT JOIN and NOT EXISTS
strategies can work with any comparison logic across any number of columns, since
they are just taking advantage of standard join functionality.

In general, *my* favorite strategy is the LEFT JOIN strategy since it works in
every situation, and I find it a little more straightforward than the NOT EXISTS
strategy. The one thing to keep in mind when using the LEFT JOIN strategy is, you
need to be careful picking the column from the right-hand table on which to perform
your NULL check. You need to pick a column that will *only* be NULL if no match was
found. If you perform the check against a column that actually has NULLs in it
already, then your anti-join logic will have a bug in it.You will run the risk of
returning rows that *do* match to rows in the right-hand table, if those rows
just happen to have NULLs in the column you are checking. You can usually avoid
this issue by doing the NULL check against the key column or columns that you are
joining on, since those wouldn't return a match anyway if the key column value
was NULL.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
