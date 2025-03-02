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
department booking. Finally, the third booking, from the Brass department *starts*
on the 20th, which just barely overlaps with the end of Voice department booking
mentioned earlier. So these three all constitute one set of overlapping bookings,
and get squashed down to a single row in the output ranging from March 17th, the
start of the Voice department booking, through March 25th, the end of the Brass
department booking.

Moving on to Hall B. The first expected output for for Hall B combines the
overlapping Voice and Woodwinds bookings from March 13th through March 22nd. And
finally, the last two rows in the expected output map 1-to-1 onto the last two
bookings in Hall B, neither of which overlap with any other bookings in Hall B.

All right, that's all the set-up for today. If you want to have a crack at solving
this problem yourself, there are links in the video description to this full problem
statement and instructions on how to replicate this coding environment on your
local machine. Feel free to pause the video now, and come back later for a solution
walkthrough, coming right up.

## Solution Walkthrough
[TODO]

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

end-state of solution:
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

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
