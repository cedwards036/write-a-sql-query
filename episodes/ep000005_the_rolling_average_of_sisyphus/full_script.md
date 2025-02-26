# The Rolling Average of Sisyphus

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today involves a useful kind of calculation that is a common
component of time series analyses and executive-level reports.

*(read problem statement)*

And just to give a better sense of exactly what we need to calculate, let's look
at a specific example, the rolling average for March 5th.

*(explain below calculation)*

```sql
-- example calculation for rolling average on 3/5
SELECT (27.75 + 26.91 + 26.72) / 3;
```

All right, that's all the set-up for today. If you want to have a crack at solving this
problem yourself, there are links in the video description to this full problem statement
and instructions on how to replicate this coding environment on your local machine. Feel
free to pause the video now, and come back later for a solution walkthrough, coming right
up.


## Solution Walkthrough

### We need a window function
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. Now, I have labeled this as an "advanced" SQL problem, but not because
it is particularly difficult. It's really quite an easy problem if you happen
to be familiar with the specific SQL language feature that makes it easy. However, that
feature itself is what I would consider "advanced" SQL functionality, the
type of thing that you probably won't need to use all that often outside of a few
specialized use cases like this one.

But before we get to the main "trick" to solving this problem, let's work our way
up to it a bit by analyzing what the problem is asking of us. We are being asked
to find an average of some kind, which may make you think of aggregation, of
GROUP BY statements. However, there are reasons to be skeptical of going that
direction. The rolling average report we are being asked to generate has the exact
same grain as the source data, in other words one row per date. Usually, though
not always, you use a GROUP BY statement when you want to roll up a finer-grained
source dataset into a coarser-grained summary dataset. But here, we aren't changing
the grain at all. Instead, we want to calculate an aggregation at the same grain
as the original table, incorporating some data from the surrounding rows.

And that's anothing hint: "the surrounding rows". Our aggregation depends on
combining data from rows that are adjacent to each other in the context of a
particular sort order, namely chronological order. The rolling average for each
date needs to incorporate the data from the day before and the day after. Put another
way, we need to use data from the *row* before and the *row* after, assuming the
data is sorted in chronological order by attempt_date.

These two big hints--aggregating without changing the grain, and the aggregation
being dependent on the order of the rows--point us very strongly toward one thing:
we need a window function. Specifically, we need to calculate the average of
the height_in_meters column over a window ordered by attempt_date. So, lets try
that real quick:
```sql
SELECT
	attempt_date,
	AVG(height_in_meters) OVER (ORDER BY attempt_date) AS rolling_average
FROM rolling_data;
```

### Controlling the window frame
This is a decent start, but as you can see, our numbers are not lining up with
the expected results on the left, and that shouldn't surprise us, because we
still haven't accounted for the most important requirement. Sisyphus wants a
rolling average for each date that includes *just* the current date, the day
before, and the day after. Right now, our window function is not respecting
that specialized rule.

To understand why, we need to introduce the concept of a **window frame**. The frame
is the set of rows over which the window function is computed. This frame can
be manually specified, or it can be implied. And if your SQL-writing career looks
anything like mine, the vast majority of window functions you write have
implicit frame definitions.

Generally, there are two main implicit window frames, and which one you get
depends on whether or not your window definition has an ORDER BY clause. If
it does, like our query here, then the window frame stretches from the first
row of current partition up through the current row, based on the order you
specify in the ORDER BY clause. So, for example, in our query results here,
the value currently shown next to the date of March 5th--27.574--is the average
height across the first five dates by chronological order, March 1st through March 5th.

If your window definition does *not* have an ORDER BY clause, then the implicit
window frame will be the entirety of the current partition. If you aren't doing
any partitioning in your definition, this means the window frame is simply the
entire table.

So, if we stick to implicit window frames, our options are fairly limited, but
we can also define our own window frame if the default ones don't suit our purposes.
In our case, for each row in our output, we want the window frame to extend
precicely from one row before, through one row after. And there happens to be a
straightforward way of expressing that in window frame definition syntax, like so:
```sql
SELECT
	attempt_date,
	AVG(height_in_meters) OVER (
		ORDER BY attempt_date
		ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
	) AS rolling_average
FROM rolling_data;
```
I've slightly reformatted the query to split this window definition over multiple
lines since it was getting very long, but hopefully it is still clear. After
the order by clause, we specify the window frame definition as "ROWS BETWEEN 1
PRECEDING AND 1 FOLLOWING". This is one of those nice cases where the syntax
for doing what we want looks very much like a straightforward description of what we want in
plain English. And if we run this, we get precisely the rolling averages
listed in our expected output on the left. And as you can see, the rolling averages
tell a slightly clearer story than the noisier raw data: Sisyphus starts off around
the 27-to-28 meter area, and seems to climb higher and higher, cresting above 29
meters, before his average falls back down to around where he started. Ah well,
maybe next time.


## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
