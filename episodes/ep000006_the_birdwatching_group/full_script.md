# The Bird-watching Group

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today covers some common SQL functionality related to
aggregations.

*(read problem statement, make sure to call out Eva seeing the same bird multiple
times)*

All right, that's all the set-up for today. If you want to have a crack at solving
this problem yourself, there are links in the video description to this full problem
statement and instructions on how to replicate this coding environment on your
local machine. Feel free to pause the video now, and come back later for a solution
walkthrough, coming right up.

## Solution Walkthrough
### COUNT(DISTINCT)
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. As with any problem, the first thing you should do is try to
break it down into more manageable components. We need to create a report with
the names of each club member who saw at least 3 different bird species, along with
the number of species each of them saw. I am going to set aside the "at least 3
different species" part for now, we'll come back to that later. To start with,
I want to focus just on what columns need to be in the report and how to populate
them with the correct data. We need two columns in our output: club_member_name,
and lets call it species_count. Let's get that much down in a stub query, and then
we can build on it.

```sql
SELECT
	club_member_name,
	??? AS species_count
FROM bird_sightings
ORDER BY
    species_count DESC,
    club_member_name
;
```
So, we can get club_member_name easily enough from our bird_sightings table, but
what about species_count? For this column, we need the number of bird species
that each person saw. "The number of bird species" is an aggregate metric, and
the phrase "each person" implies an aggregation at the grain of "club_member_name".
Translated to SQL, this means we need to invoke some aggregate function while GROUPing
BY club_member_name, so let's add that to our query sketch here:

```sql
SELECT
	club_member_name,
	FUNC(???) AS species_count
FROM bird_sightings
GROUP BY club_member_name
ORDER BY
    species_count DESC,
    club_member_name
;
```

Ok, next up, we need to decide what aggregate function to use. We are trying to
calculate the number of bird species seen per club member. In other words, we need
to COUNT the number of SPECIES, so we probably want to use the COUNT function and
pass it the species column, like so:

```sql
SELECT
	club_member_name,
	COUNT(species) AS species_count
FROM bird_sightings
GROUP BY club_member_name
ORDER BY
    species_count DESC,
    club_member_name
;
```
This is now a syntactically-correct, runnable query, so lets run it and see where
we are. Ok, so the good news is we now have a report at the club-member grain
and a numeric column for species count. The bad news is, the counts are wrong.
If we look back at our source data, *(re-query bird_sightings)* we can see that,
for example, Eva had three total sightings, but she only actually saw two different
birds. Our current query is counting the number of *sightings* each person had,
*not* the number of bird species. We have a situation here where the grain of
our source data is different from the grain that we want to base our COUNT on.
Our source data is at the sighting grain, but we want a COUNT of bird species,
regardless of how many times each person saw them.

One way to resolve this would be to split our query up into multiple parts
using a CTE or subquery. In the first step, we could use a SELECT DISTINCT query
to get our source table to the grain we need, and then our COUNT function will
return the correct results. However, thanks to some nice syntax that I believe is
very widely supported across database systems, we don't have to do that. We can
just put a DISTINCT within our COUNT function itself, like so, *(update the query)*
and now we are truly counting the number *species* each person saw, instead of
the number of sightings they had.

```sql
SELECT
	club_member_name,
	COUNT(DISTINCT species) AS species_count
FROM bird_sightings
GROUP BY club_member_name
ORDER BY
    species_count DESC,
    club_member_name
;
```
If we run that, we can see the counts are now what we wanted, and specifically
the counts for James and Anna now match our expected output over there on the left.

### HAVING clause
So we're almost there. The only thing left is to finally account for that condition
in the problem statement, to only list club members who saw *at least 3 different
species of bird*. Well, we have calculated the species_count for each club member,
why don't we just put that in a WHERE clause and call it a day?

```sql
SELECT
	club_member_name,
	COUNT(DISTINCT species) AS species_count
FROM bird_sightings
WHERE COUNT(DISTINCT species) >= 3
GROUP BY club_member_name
ORDER BY
    species_count DESC,
    club_member_name
;
```
*(run bad query)* That's why! We get an error: aggregate functions are not allowed
in WHERE. Similar to our previous situation with COUNTing distinct values, this
problem can be surmounted by splitting the query up into multiple stages, calculating
the species_counts in a CTE or subquery, and then filtering on that computed column
in a subsequent query. But, yet again, we don't have to do that thanks to some nice,
pretty universally-supported syntax called a HAVING clause. I'll show you what that
looks like first, and then I'll explain it a bit.

```sql
SELECT
    club_member_name,
    COUNT(DISTINCT species) AS species_count
FROM bird_sightings
GROUP BY club_member_name
HAVING COUNT(DISTINCT species) >= 3
ORDER BY
    species_count DESC,
    club_member_name
;
```
So, to start off, this query works, we're done. This produces precisely the data
that is listed in our expected output on the left here. But I want to take a moment
to explain why this worked, but the version we just tried with the WHERE clause
didn't work. There's really very little difference between WHERE and HAVING, except
that HAVING allows you to filter on the result of aggregations, and WHERE does not.
And the reason for that has to do with the under-the-hood execution order of SQL
queries.

When you submit a SQL query to your database, internally it parses that SQL query
into several steps that always execute in a specific order, and this is that order:
```
FROM/JOIN
WHERE
GROUP BY
HAVING
SELECT
DISTINCT (i.e. the DISTINCT in "SELECT DISTINCT")
ORDER BY
LIMIT/OFFSET
```
First, it parses the FROM and JOIN clauses to figure out what tables are involved
in your query. Next, it uses any WHERE conditions to filter out rows from those
tables. After that, it parses any GROUP BY clauses and performs aggregations. Now
this is the key reason why we can't use a WHERE clause to filter on the result
of an aggregation: at the time that the database is executing the WHERE clause,
it hasn't done the aggregations yet! That data is not yet available to filter
on. And that's where HAVING comes in. As you can see, in the execution order,
HAVING is right *after* GROUP BY, and therefore the results of aggregation *are*
available for filtering.

Now you might ask, what's the point of SQL using *both* WHERE and HAVING? Why not
have just one way to filter that always works? Well, I can't speak to the history
of SQL language development, but I can say from a practical perspective, it makes
sense to have the option to filter before aggregation, or after aggregation. You
need an "after aggregation" option if you want to be able to filter on aggregates
at all. But having a "before aggregation" filtering option is very useful from
a performance perspective at least, since it lets you filter out unneeded data
before performing a potentially expensive aggregation.

So, that's the SQL execution order, or at least as much of it as you need to know
to understand the difference between WHERE and HAVING. As an aside, you may notice
that SELECT is pretty far down the list, *after* WHERE, GROUP BY, and HAVING. This
is the reason I had to write `HAVING COUNT(DISTINCT species) >= 3` instead of
`HAVING species_count >= 3`. Because the SELECT clause hasn't run yet, the column
alias we defined, species_count, is not yet known to the query processor at the time
we are running our HAVING logic. You may also notice that ORDER BY comes *after*
SELECT in the execution order, and that is why, in contrast, we *can* use our
species_count alias in the ORDER BY clause. Just a few more fun tidbits about
SQL execution order.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
