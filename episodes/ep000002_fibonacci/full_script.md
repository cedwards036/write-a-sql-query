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
{TODO}

```sql
--my favorite solution
WITH RECURSIVE fib(fib_index, cur_value, prev_value) AS (
    SELECT
        1 AS fib_index,
        1 AS cur_value,
        0 AS prev_value

    UNION ALL

	SELECT
        fib_index + 1 AS fib_index,
        cur_value + prev_value AS cur_value,
        cur_value AS prev_value
    FROM fib
    WHERE fib_index <= 15  --just change this filter to change N
)
SELECT
    prev_value AS fib_number
FROM fib
ORDER BY fib_index;
```