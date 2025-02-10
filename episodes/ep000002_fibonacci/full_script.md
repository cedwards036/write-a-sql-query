# The Uncharitable Ranking

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today is probably familiar to many of you as a common toy problem
for traditional programming languages like Python or JavaScript. But today we're
going to have a go at it in SQL.

*(read problem statement)*

All right, that's all the set-up for today. If you want to have a crack at solving this problem
yourself, there are links in the video description to this full problem statement and
instructions on how to replicate this coding environment on your local machine. Feel free to
pause the video now, and come back later for a solution walkthrough, coming right up.


## Solution Walkthrough

### Recursive Queries
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. So, the first thing to recognize about the structure of the Fibonacci
sequence is that it is *recursive*. The nth Fibonacci number is defined as the
sum of the previous two; this is a recursive definition that requires you to compute
previous items in the sequence in order to compute later items in the sequence. And
this is therefore a perfect candidate for a recursive SQL query.

So first, a little review on how recursive functions work, in general. You have two main
elements: the base case, and the recurrence relation.
The recurrence relation part tells you how later members of the sequence are derived
from earlier members of the sequence. For Fibonacci numbers, the recurrence relation
is the rule that each number in the sequence is the sum of the previous two numbers
in the sequence.

However, the recurrence relation is *not* sufficient by itself to fully
define a sequence, because we need a way to get the sequence going in
the first place. Defining the next member of the sequence in terms of the previous
members is all well and good if you *have* previous members to work with, but how
does the whole thing start? That's where the base case comes in; the base case
is just a brute fact, of sorts, defining the beginning of the sequence. For a sequence like Fibonacci,
where each element depends on the previous *two* elements before it, we need a base
case that defines at least the first two elements of the sequence, so that the
recurrence relation has everything it needs to take things from there. And our
problem definition today gives us that base case: the standard form of Fibonacci
defines the first two elements to be 0 and 1.

So, we have our base case, and the logic for our recurrence relation, now how do
we translate that into SQL? The general form of a recursive SQL query looks
something like the following:

```sql
--pseudocode example
WITH RECURSIVE recursive_cte AS (
    --base case
    SELECT col1
    FROM existing_dataset
    WHERE <optionally some extra condition that defines the base case>

    UNION ALL

    --recurrence relation
    SELECT <some additional logic> AS col1
    FROM recursive_cte
    --may or may not join back to the base case table in some way
    JOIN existing_dataset
        ON <some join condition>
)
SELECT *
FROM recursive_cte;
```

We have a WITH clause, also called a common table expression or CTE, with the special
keyword `RECURSIVE` in its definition. That CTE is made up of two UNIONed parts: a non-recursive
query that effectively acts as our base case, and a recursive query that references
the CTE itself (this is where we define our recurrence relation). The base case is
usually a SELECT query that pulls a limited set of data from some existing table,
and the recurrence relation will often (but not always) join back to that same
existing table from the recursive CTE itself.

Just to drive this structure home, let's look at a simple, concrete example based on some
code from the PostgreSQL doc pages:

```sql
--based on official example from PostgreSQL docs https://www.postgresql.org/docs/current/queries-with.html
WITH RECURSIVE t(n) AS (
    --base case
    VALUES (1)

    UNION ALL

    --recurrence relation
    SELECT n + 1
    FROM t
    WHERE n < 100
)
SELECT n
FROM t
ORDER BY n;
```
This query recursively generates all of the integers from 1 to 100. The base case
is just the number 1, defined here using a `VALUES` clause, and the recurrence
relation is the simple fact that each positive integer is 1 more than the previous
positive integer. More specifically, the recursive part of this recursive CTE is
selecting the previously-generated ingeter, `n`, and adding 1 to it, to produce
the next integer in the sequence. And it keeps doing this as long as the
previously-generated integer is less than 100. The final "loop" of this recursion
will happen when `n` here is 99, and 99 + 1 is 100, so the final row *produced*
by the query will contain the number 100.

### From consecutive integers to Fibonacci
Now this query here, generating the first 100 positive integers, is actually
a decent starting point for constructing our Fibonacci query. There are three
main differences between this query and a query that can generate the first N
Fibonacci numbers:

1. the base case for Fibonacci has *two* numbers, 0 and 1
2. the recurrence relation for Fibonacci references the previous *two* numbers
in the sequence, not just the previous number
3. the "stop" conditions for the queries are subtly different. You could say that
this query generates *either* the first 100 positive integers, *or* all positive
integers less than or equal to 100. These happen to be equivalent statements because the
"index" of the positive integers is equal to the value of the integers.
For example, the 10th positive integer is the number 10, the 55th positive integer
is the number 55, and so on.
This is *not* the case with Fibonacci; the Nth Fibonacci number is *not* the literal
*value* N. In fact the *value* of each successive Fibonacci number
quickly gets a whole lot bigger than the *index* of the number, i.e. which position
in the sequence it occupies. For example, the 10th Fibonacci number is 34, and
the 15th number is 377. For our purposes today, we want our Fibonacci
query to stop based on the *index* of the number, not the value of the number.
The Nth Fibonacci number, *not* the Fibonacci number less than or equal to N.

So, now that we have identified the differences between this query and the query
we want, let's write some code. First of all, let's fix our base case to have both
0 and 1, and lets update the CTE definition accordingly.

```sql
WITH RECURSIVE t(prev_n, n) AS (
    --base case
    VALUES (0, 1)

    UNION ALL

    --recurrence relation
    SELECT n + 1
    FROM t
    WHERE n < 100
)
SELECT n
FROM t
ORDER BY n;
```
Okay, now lets try to fix the recurrence relation. Now, in order to provide the
necessary inputs for the next iteration of the recursion, and to make sure
this side of the UNION ALL lines up with the base case query column-wise, we
need to calculate values for *both* `prev_n` and `n` in the recurrence relation
query. To accomplish that, the old `n` becomes the new `prev_n`, and we get the new `n` by adding the old `n` and `prev_n` together. Its like we are shifting a window looking at the
sequence over by 1. Like, let's say our `prev_n` is 5 and our `n` is 8. On the next
run of the recursion, we shift over by 1, so now the new `n` is 13, and the old
`n`, 8, is now the `prev_n`, and so on.

```sql
WITH RECURSIVE t(prev_n, n) AS (
    --base case
    VALUES (0, 1)

    UNION ALL

    --recurrence relation
    SELECT
    	n AS prev_n,
    	prev_n + n AS n
    FROM t
    WHERE n < 100
)
SELECT n
FROM t
ORDER BY n;
```

Ok, we've addressed the base case and the recurrence relation, now we just need
to tell this query how to stop after the Nth Fibonacci number. We need to update
this `WHERE` clause somehow. But, currently, we don't have the right information
available for the `WHERE` clause to filter on. Remember, we essentially need to
filter on the *index* of the Fibonacci numbers, in other words what position in
the sequence the number has.

Right now, all we have to filter on are *values* in the sequence, which don't help us.
So, we essentially need to introduce another column,
that can track the sequence index for us. And just like with the values of the sequence,
we need to define a base case and a recurrence relation for this index. So what is the base case
of an index? Well, it depends on whether you are following 1-indexing
or 0-indexing. For simplicity's sake let's go with 1-indexing for now, such that
we can say "the *first* Fibonacci number is 0, the *second* number is 1, and so on".

So, we just add an index column to the CTE definition here. Now, for the base case,
since we are using 0 for `prev_n` and 1 for `n`, it seems fair to tie the base case index to the
1 rather than the 0. And since 1 is the second number in the sequence, our base
case index in this context is 2.

The recurrence relation is straightforward. The index of each subsequent Fibonacci
number is just one greater than the index of the previous number, by the definition
of "index", so we can encode that in the recursive query here. Finally, we need to
update our "stop" condition, the `WHERE` clause. We want to filter on index instead
of value, and let's try generating the first 15 Fibonacci numbers, and run the query!

Alright, as you can see, we are almost there, but we have some kind of off-by-one error.
Just as an artefact of the way this particular solution is designed, because 0
never actually gets to be `n`, it only ever appears as `prev_n`, SELECTing `n`
for our final result will always leave off 0. So we actually want to SELECT
`prev_n`, and to compensate for shifting all the values back by one, we need
to update the `WHERE` clause to have a less-than-or-equal sign instead of a plain
less-than sign. Let's run that, and voila! The first 15 Fibonacci numbers.

```sql
WITH RECURSIVE t(prev_n, n, idx) AS (
    --base case
    VALUES (0, 1, 2)

    UNION ALL

    --recurrence relation
    SELECT
    	n AS prev_n,
    	prev_n + n AS n,
    	idx + 1 AS idx
    FROM t
    WHERE idx <= 15
)
SELECT prev_n AS n
FROM t
ORDER BY n;
```

And, just because its always good to consider edge cases, we can check that
this works even for the base cases. Let's try getting just the first Fibonacci
number by updating the filter to 1. It returns 0 as expected. And now let's try
2; and it returns 0 and 1 as expected. So yeah, I think this is a solid solution
to our problem. It is by no means the only way to write this query, but it gets
the job done.

## Final Thoughts
Well, that's basically it for today's problem. As a fun little postscript, I do
want to mention another equally valid, but much, much less obvious way to solve this
problem. It turns out that the Fibonacci sequence has what is called a closed-form
solution, in other words a simple non-recursive formula capable of generating any
member of the sequence in more or less constant time. This is called Binet's formula,
and as you can see it is a fun bit of math that I sincerely hope no one would
expect you to come up with yourself in an interview setting. I have prepared a SQL version
of this calculation here, and we can see that is capable of spitting out the Nth
Fibonacci number with no recursion at all (though this formula produces 0-indexed
values, in other words shifted by 1 compared to our solution above; for example,
it consideres 377 to be the 14th Fibonacci number instead of the 15th).

Fun sidebar, Binet's formula is a closed-form solution:
```sql
WITH n(val) AS (
	VALUES (15)
)
SELECT 1/SQRT(5) * (((1 + SQRT(5))/2)^n.val - ((1 - SQRT(5))/2)^n.val)
FROM n;
```

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!