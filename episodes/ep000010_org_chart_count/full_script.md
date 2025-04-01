# Org Chart Count

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today involves a common fixture of toy SQL problems, a company
org chart.

*(read problem statement, make sure to discuss expected output)*

All right, that's all the set-up for today. If you want to have a crack at solving
this problem yourself, there are links in the video description to this full problem
statement and instructions on how to replicate this coding environment on your
local machine. Feel free to pause the video now, and come back later for a solution
walkthrough, coming right up.

## Solution Walkthrough

### Deciding on a strategy
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. What we have here is a classic org chart problem, requiring us
to traverse the tree structure of the org chart in order to produce some kind
of per-employee summary. These kinds of problems are generally designed to demonstrate
one very specific type of query, and this problem is no exception. If you've seen
this kind of thing before, you are probably way ahead of me, but for those who
haven't, I want to take a second to explore how you might figure out what you
need to do by analyzing the problem.

Ok, so to solve this problem, at a basic level, we need to somehow associate each
employee with all of their direct and indirect reports, in other words all people
below them in the org chart. The first thing you might think to try is joining
the `employees` table to the `employee_managers` table to get a list of each
employee's *direct* reports. Let's try that now:
```sql
SELECT
	e.employee_name,
	m.employee_id AS responsible_for_employee_id,
	reports.employee_name AS responsible_for_employee_name
FROM employees e
LEFT JOIN employee_managers m
	ON m.manager_id = e.employee_id
LEFT JOIN employees reports
	ON m.employee_id = reports.employee_id
ORDER BY
	employee_name,
	responsible_for_employee_name;
```
So, as we would expect from the org chart on the left here, we can see Mira has
three direct reports, Angela, Laura, and Maria; Laura has two direct reports; and
everyone else has no direct reports. This is a good start! Already, with this query,
we could pretty easily return the number of *direct* reports each person has. But
a full solution to this problem also needs the indirect reports, in other words
the direct reports *of* the direct reports, and the direct reports of *them*,
and so on. For each employee, we need *everyone* below them in the org chart,
not just the first layer below them. So how can we get that?

Well, you might try adding more joins, joining from the `employee_managers` table
to itself a few more times to get to successively lower "layers" of the org chart.
And that strategy would technically work if you could know for sure in advance how
many layers the org chart has, and that the org chart was never expected to change
in the future. But there is a much better way to go about it, that will flexibly
adapt to practically any org chart size and shape.

We have a situation here where we need to join a dataset back to itself some unknown
number of times, until the chain of joins "runs out of fuel", in other words runs
out of employees to join to. This is a perfect example, some may even say *the*
canonical example, of when you should use a *recursive sql query*.

### Building the recursive query
I've discussed how recursive queries work in some detail in my earlier Fibonacci
episode, but for a quick refresher, a recursive query needs two things: a base case,
and a recurrence relation. The base case is a static dataset that is used to get
the recursion going, and the recurrence relation defines how to recursively construct
the rest of the output from there.

So, what is our base case? If we look back at the problem statement, we can see
this key statement here: "Every employee is responsible for themselves, as well
as for all of their direct and indirect reports." The simplest part of this definition,
the part that doesn't rely on any kind of joining or recursive logic, is the first
part: that "every employee is responsible for themselves". That sounds like a pretty
good base case to me, so lets note that down.
```sql
WITH RECURSIVE recursive_org_chart AS (
	--base case
	SELECT
		employee_name,
		employee_id AS responsible_for_employee_id
	FROM employees

	UNION ALL

	--recurrence relation
	--???
)
SELECT *
FROM recursive_org_chart;
```

Ok, next, we need the recurrence relation. This can often be tricky to figure out,
but I find it helps to try to state what you want in as plain and non-technical
of language as possible, and that can often point you in the right direction. For
each employee, we want to start with the employee themselves, then get all of their
direct reports, then get all of those people's direct reports, and so on. This is
describing a flow *from* managers *to* their direct reports. So we probably want
a solution that goes from the top down, using the `employee_managers` table to
get *from* managers *to* their employees, recursively. This query should do it:
```sql
WITH RECURSIVE recursive_org_chart AS (
	--base case
	SELECT
		employee_name,
		employee_id AS responsible_for_employee_id
	FROM employees

	UNION ALL

	--recurrence relation
	SELECT
		r.employee_name,
		m.employee_id AS responsible_for_employee_id
	FROM recursive_org_chart r
	JOIN employee_managers m
		ON r.responsible_for_employee_id = m.manager_id
)
SELECT *
FROM recursive_org_chart
ORDER BY employee_name;
```
In the first run of this recursion, the `responsible_for_employee_id`s are just
the ids of the employees themselves (that's the base case). When the recurrence
relation half of the query executes, these IDs are treated as manager_ids, and
joined to the `employee_managers` table to find those employees' direct reports, if they have any. The direct reports' IDs then become the `responsible_for_employee_id`s fueling
the next run of the recursion. Those ids are then treated as manager ids, and joined to the
`employee_managers` table to find *their* direct reports, and so on. Because we
are doing an INNER JOIN, the recurrence query here only returns records when there
are indeed direct reports to be found. And therefore the whole recursion ends once
we have exhausted the entire org chart, and there are no more employee-manager
relationships yet to be found.

### Finishing the solution
So, that's how this query works in a nutshell. We are not quite done with the solution,
but we are really close. Right now we have employee names and the *ids* of all of
the employees they are responsible for, and we just need to turn that enumeration
into a count. We can use a GROUP BY statement to perform an aggregation at the
employee_name grain, get the count of ids associated with each employee, and
we should be good to go.

```sql
WITH RECURSIVE recursive_org_chart AS (
	SELECT
		employee_name,
		employee_id AS responsible_for_employee_id
	FROM employees

	UNION ALL

	SELECT
		r.employee_name,
		m.employee_id AS responsible_for_employee_id
	FROM recursive_org_chart r
	JOIN employee_managers m
		ON r.responsible_for_employee_id = m.manager_id
)
SELECT
	employee_name,
	COUNT(responsible_for_employee_id) AS responsible_for_count
FROM recursive_org_chart
GROUP BY employee_name
ORDER BY
	responsible_for_count DESC,
	employee_name;
```
And sure enough, we get out expected output, and we are done.

## Final thoughts
Just a couple final thoughts before I leave you. One of the reasons that an org
chart is such a useful device for exploring recursive queries is the fact that
it is usually a tree structure. And, in graph theory, a tree can be defined as a
connected acyclic graph. The important part of that definition for our purposes
today is the "acyclic" part. This means the graph has no cycles; in other words, there
are no loops that allow you to travel from a node back to itself without any
backtracking. Using the org chart example, a cycle, or loop, would look something
like the CEO somehow reporting to the mail room intern, or someone being their
own direct report, or some other such nonesense.

It is actually the fact that org charts have no cycles that make them great fodder
for recursive SQL queries. If, for example, the CEO *did* report to the mail room intern,
your recursive query would start at the CEO, go down the org chart all the way
until it reached the mail room staff, then suddenly find itself back at the CEO
again, with no choice but to go all the way around again, and again, and again,
for every and ever. You would have an infinite loop, and your query wouldn't work.

While there usually some ways to protect against getting stuck in infinite loops,
it requires some extra care and it complicates the logic a bit, so when you just
want to demonstrate the core functionality of recursive SQL queries, it is a lot
easier to just start with a scenario that will never have loops in it. And an org
chart fits that bill.

Once last caveat about recursive queries: earlier I claimed that they would
"flexibly adapt to practically any org chart size and shape". That is true up
to a point, but there are practical system limitations. Many database systems
have the concept of a "maximum recursion depth", and if your recursive query
recurses too many times, even if it isn't technically an infinite loop, the database
will just error out to be safe. Sometimes you can tweak this limit in the system
settings, but, regardless, there usually is *some* limit beyond which recursive queries
become impractical or impossible, and you should keep that in mind when writing a recursive
query that could potentially perform an enormous number of recursive calls. As always,
results will vary depending on the exact database you are using, your hardware limitations,
etc.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
