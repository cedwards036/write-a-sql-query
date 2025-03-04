# Squashing Recital Reservations

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today is a fairly tricky one involving the combination
of overlapping timespans.

*(read problem statement)*

Now, because this is a bit of a tricky concept, I want to walk through the expected
output in a bit more detail than usual. The first row in the output corresponds
to the Piano department's booking of Hall A, which doesn't overlap with any
other bookings in that hall.

The second row encompasses the next three bookings of Hall A. The first of these
bookings, from the Voice department, starts on the 17th and goes through the 20th.
The next booking, from the Strings department, overlaps completely with the Voice
department booking. Finally, the third booking, from the Brass department, *starts*
on the 20th, which just barely overlaps with the end of Voice department booking
mentioned earlier. Because of this chain of overlapping bookings, Hall A is in
continuous use from March 17th through March 25. And therefore, all of these
bookings get squashed together into the second row in our expected output here.

Moving on to Hall B. The first expected output for for Hall B combines the
overlapping Voice and Woodwinds bookings from March 13th through March 22nd. And
finally, the last two rows in the expected output map 1-to-1 onto the last two
bookings in Hall B, neither of which overlap with any other bookings in that hall.

All right, that's all the set-up for today. If you want to have a crack at solving
this problem yourself, there are links in the video description to this full problem
statement and instructions on how to replicate this coding environment on your
local machine. Feel free to pause the video now, and come back later for a solution
walkthrough, coming right up.

## Solution Walkthrough
Ideas for structuring walkthrough:
1. imagine having a group id, then we could easily write a groupby statement
   to solve the problem
2. but how to get the group id?
3. let's start with a simpler problem, how to tell when a new group has started?
4. Can we check if the current row's start date is <= the previous row's end date?
    - No, what if there's an earlier, but longer, event, like the Hall A voice
      booking
5. we need to check the current row's start date against the latest end date that
   has been seen so far (this leads to the ROWS BETWEEN statement)
6. from there, sum the change indicators to get group number, and then apply
   our groupby solution from step 1 and voila!

### Starting from the end with GROUP BY
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. So, as I said in the intro, I consider this a fairly tricky
problem, and some of you watching this may not have even known where to start
with this problem. And when I find myself in that situation, not knowing where to
start, I sometimes find it helpful to look at the desired end result, and slowly
work my way backward. Let's ask ourselves, what would be the easiest starting point
from which to get this expected output? What would our input need to look like in
order to make computing this final output straightforward?

Well, we essentially need to group multiple rows in our input together to produce
an output at a coarser granularity than the input, and that is a perfect situation
for a GROUP BY statement. It would be really great if we could just write a simple
GROUP BY statement to collapse the many overlapping bookings in our source data
into the "squashed" summary rows we see on the left here. So let's try writing one
and see how far we can get before we run into trouble.
```sql
SELECT
	hall,
	MIN(start_date) AS start_date,
	MAX(end_date) AS end_date
FROM recital_hall_bookings
GROUP BY
    hall,
    group_id --???
;
```
Now, this is about as far as I could get. I know we need `hall` in our output,
and I know that we will be constructing these "squashed" rows with the earliest
booking start time and the latest booking end time for each continuous period of
use, so I got that much down. Where we run into trouble is deciding what to
actually GROUP BY. What we need here is a column that has a different value for
each continous period of use for each hall. For example, let's say our source data
looked like this:
```
hall  |department|start_date|end_date  |group_id|
------+----------+----------+----------+--------+
Hall A|Piano     |2025-03-15|2025-03-16|       0|
Hall A|Voice     |2025-03-17|2025-03-20|       1|
Hall A|Strings   |2025-03-18|2025-03-19|       1|
Hall A|Brass     |2025-03-20|2025-03-25|       1|
Hall B|Voice     |2025-03-14|2025-03-19|       0|
Hall B|Woodwinds |2025-03-17|2025-03-22|       0|
Hall B|Strings   |2025-03-17|2025-03-22|       0|
Hall B|Brass     |2025-03-25|2025-03-26|       1|
Hall B|Piano     |2025-03-27|2025-03-28|       2|
```
If we had this `group_id` column here, we'd could just group by `hall` and `group_id`,
and we'd be done. The first booking of Hall A is the only Hall A booking with group_id
0, so it gets it own row in the output. The next three Hall A bookings all share
the group_id `1`, so they would all get "squashed" together into a single row
in the output, just like we want, and so on. Having this `group_id` column correctly
populated would solve all of our problems. But, unfortunately, we don't have this
column. So, we should ask ourselves, can we make this column? What SQL query
can we write that would assign unique group numbers to each "overlapping chain"
of bookings in each hall?

### Identifying when a new grouping starts
Well, that is itself a fairly tricky problem, so let's start smaller. Another trick
I like to use is to solve an simpler version of a problem first, and then build up
to the harder problem. What if instead of uniquely identifying each overlapping
booking group with its own id, we instead just try to identify when each new group
begins. In other words, we need to figure out what the criteria should be for when
a booking should join an existing group, versus when it should constitute the
start of a new group.

So let's consider some candidate logic. It helps here to think of the bookings in
chronological order. One possible rule would be: if the current booking's start
date is after the previous booking's end date, then the current booking is the
start of a new group. If we consider Hall B for a moment, this logic seems to work
pretty well. By this logic, the Voice, Woodwinds, and Strings bookings in Hall B
would all form a continuous overlapping group, and we would need to start new groups
for both the Brass and Piano bookings, since both of their start times are strictly
*later* than the end times of the immediately previous bookings.

However, this logic falls apart a bit when considering Hall A. Specifically, the
*Brass* booking in Hall A. By our current rule, this would constitute the start
of a new group, since the Brass's start date, March 20th, is strictly after the
previous booking's end date, March 19th. However, the Brass booking *does* overlap
with the Voice booking, *two* rows before. This overlapping group has different
structure than the one from Hall B, since we have one initial booking that overlaps
multiple subsequent bookings, which in turn *don't* overlap with each other.
So it's a little tricker.

We clearly need to evolve our rule slightly. It isn't enough to consider the end
date of the immediately preceding booking when deciding if there's an overlap
or not. We need to consider the end dates of *all* previous bookings. More specifically,
our new and improved rule should be: if the current booking's start date is on or after
the *latest* end date among all previous bookings in the current hall, then the
current booking is the start of new group. This rule works in every case, including
our tricky situation in Hall A.

So, now we have a decent rule, we need to translate it to SQL. We need to make a
new column that somehow indicates which rows are the start of new groupings, using
a comparison: we need to compare the current booking's start date against the latest
end date among all previous bookings. We have the current booking's start date,
that's just the `start_date` column in our source data. But how do we get the
latest end date among all previous bookings? There are a couple ways to do it,
including some gnarly self-joins, but there is a very elegant solution using
window functions. If you've seen my previous video about the Rolling Average
of Sisyphus, you know about window frames, and the ability that we have to
define custom frames if the situation calls for it. This is one of those times.

```sql
SELECT
    *,
    CASE
        WHEN start_date > MAX(end_date) OVER (
	            PARTITION BY hall ORDER BY start_date, end_date
	            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
	        ) THEN 1
	    ELSE 0
	    END AS group_change_indicator
FROM recital_hall_bookings;
```

We can define a custom window frame that encompasses all bookings in the current
hall *before* the current booking, and then use the MAX() function to get the
latest end_date from that window. You see here we get the MAX(end_date), we
partition by hall so that we only consider bookings in the same hall as the
current booking, and then we set our window to ROWS BETWEEN UNBOUNDED PRECEDING
(meaning from the beginning of the partition) AND 1 PRECEDING (meaning the window
stops just before the current row). And if we run this, you'll see we now have
a working indicator column that contains a 1 whenever a row constitutes the start of
a new group in the current hall.

### Creating the group_id column and finishing our query
So, now we have solved the easy version of our problem, we can return to the full
problem: how do we assign unique group numbers to each overlapping booking group?
This actually turns out to be a pretty easy add-on to what we've already done. We
have constructed this group_change_indicator column that contains a 1 whenever a
new group starts. So, if we just take a running total of this indicator column,
the running total will increment by 1 every time a new group starts, thereby giving
that group a new group_id.

```sql
WITH bookings_with_group_change_indicators AS (
    SELECT
        *,
        CASE
	        WHEN start_date > MAX(end_date) OVER (
		            PARTITION BY hall ORDER BY start_date, end_date
		            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
		        ) THEN 1
		    ELSE 0
		    END AS group_change_indicator
    FROM recital_hall_bookings
)
SELECT
    *,
    SUM(group_change_indicator) OVER (PARTITION BY hall ORDER BY start_date, end_date) AS group_id
FROM bookings_with_group_change_indicators;
```
We just need to wrap our change indicator query in a CTE, and apply a SUM window
window function on top of our `group_change_indicator` field, and, if we run this,
there we have it. We have come full circle and created the group_id column that
we wished we had in the beginning. And, we already know exactly what to do with it,
thanks to our stub query from earlier.

```sql
WITH bookings_with_group_change_indicators AS (
    SELECT
        *,
        CASE
	        WHEN start_date > MAX(end_date) OVER (
		            PARTITION BY hall ORDER BY start_date, end_date
		            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
		        ) THEN 1
		    ELSE 0
		    END AS group_change_indicator
    FROM recital_hall_bookings
), bookings_with_group_ids AS (
    SELECT
        *,
        SUM(group_change_indicator) OVER (PARTITION BY hall ORDER BY start_date, end_date) AS group_id
    FROM bookings_with_group_change_indicators
)
SELECT
    hall,
    MIN(start_date) AS start_date,
    MAX(end_date) AS end_date
FROM bookings_with_group_ids
GROUP BY
    hall,
    group_id
ORDER BY
    hall,
    start_date,
    end_date;
```

We just need to wrap our group_id dataset in one more common table expression, plug
it into our stub query, and we should be done! And sure enough, our output exactly
matches the expected results on the left, we are in fact done!

## Final thoughts: connected components
Before I leave you, I did want to bring up one other interesting way to think
about this problem. If you have studied academic computer science, or even if
you have done some data structures and algorithms study in preparation for interviews
and the like, you may be familiar with graph theory. And in graph theory, there
is the well-known problem of finding connected components in an undirected graph.
The problem we just solved is actually just a varient of the connected components
problem. You can construct a graph where the bookings are vertices, and there exists an
edge between two vertices if the two bookings' date ranges overlap each other in
the same hall. If you model the problem like this, finding the groups of overlapping
bookings is equivalent to finding the connected components in this graph.

Now, I tell you all this because I think it is interesting to conceptualize problems
in more than one way. But, from a practical perspective, I would reach for the
solution I've spent this whole video describing *well before* I would try to write
the connected components algorithm in SQL. I think you could do it,
probably using a gnarly recursive query of some kind, but I think the window-function-
based solution we've discussed today is a much nicer, more idiomatic way to tackle
this particular problem in SQL. And this solution is really only possible because
of the special constraints this problem has that differentiate it from a generic
connected components problem. Specifically, the chronological dimension, the
ability to meaningfully order the bookings by date and only consider bookings that
happened *before* the current one, all that lets us write a more efficient, more
elegant solution in SQL compared to what it would probably take to write the generic
connected components algorithm. To be perfectly honest, if I ever found myself
in a situation where I *did* have to solve a generic connected components problem,
I would almost certainly try to keep that in the application layer, using a programming
language like Python, I would *not* reach for SQL as my first choice there.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
