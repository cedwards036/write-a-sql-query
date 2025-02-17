# The Soft Cap

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

```sql
WITH ranked_guests AS (
	SELECT
		*,
	    RANK() OVER (ORDER BY entered_queue_at) AS guest_rank
	FROM reservation_queue
)
SELECT
	guest_party_id,
	guest_name,
	entered_queue_at
FROM ranked_guests
WHERE guest_rank <= 6
ORDER BY
	entered_queue_at,
	guest_name
;
```
TODO: somewhere in the end, mention the bin-packing problem, NP complete, etc

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!