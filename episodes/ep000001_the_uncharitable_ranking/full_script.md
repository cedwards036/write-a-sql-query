# The Uncharitable Ranking
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today involves an interesting little twist on rankings.

## Scenario
Now to set the scene, let's imagine an American private school with a particularly nasty headmaster. At the
end of each year, in flagrant violation of several academic privacy laws, the
headmaster posts a public "leaderboard" of sorts, ranking all of the students in
the school by their current grade point average, otherwise known as GPA**.

To further motivate and/or humiliate the students, this headmaster employs a
pecular ranking methodology. While some aspects of it are fairly standard (the best
student is ranked #1, second best is #2, etc.), something interesting happens when
there is a GPA *tie*. Let's say three students have the third-best GPA in the
school. A more charitable system would give all of them rank #3, skip ranks 4 and 5, and then proceed with rank #6 for the next lowest student. However, this
headmaster is not charitable. In his opinion, if any of these three students truly
deserved 3rd place, they should have been good enough to beat the other two
students. No, instead of giving them rank #3, the headmaster *skips* ranks 3 and
4, giving all three students rank #5. And,
in general, if multiple students share the same GPA, they are collectively given
the *lowest* possible rank among them.

This uncharitable headmaster happens to be preparing this year's rankings soon,
and he needs a bit of help querying the student database. That's where we come in...

**In the U.S., GPAs usually range from 0.0 (all F's) to 4.0 (all A's)

## Problem statement and set up

### Set up script
```sql
DROP TABLE IF EXISTS grades;

CREATE TABLE IF NOT EXISTS grades (
    student_name TEXT,
    gpa NUMERIC
);


INSERT INTO grades (student_name, gpa) (
    SELECT *
    FROM (
        VALUES
            ('Kyle Roth', 3.9),
            ('Karen Hill', 3.8),
            ('Jonathan Higgins', 3.8),
            ('Kimberly Peterson', 3.7),
            ('Casey Hammond', 3.5),
            ('Jonathan Griffin', 3.4),
            ('Brittany Crawford', 2.9),
            ('Ernest Hogan', 2.9),
            ('Rita Graham', 2.9),
            ('Mary Mcdaniel', 2.5),
            ('Carla Porter', 2.4),
            ('Michael Robertson', 2.3),
            ('Joseph Patterson', 2.3),
            ('Sierra Jordan', 2.3),
            ('Valerie May', 2.0)
    )
);
```
I'm going to go ahead and load up our database with a 15-row sample of the student data.
There is a single table, `grades`, with two columns: a text column called `student_name`
and a numeric column called `gpa`. We need to write a query that returns the student
names and GPAs from the `grades` table along with a new column, `student_rank`,
that contains that student's GPA rank per the headmaster's uncharitable ranking system.
The results should be sorted in order of highest GPA to lowest GPA.

### Expected result

|student_name      |gpa|student_rank|
|------------------|---|------------|
| Kyle Roth        |3.9|           1|
| Jonathan Higgins |3.8|           3|
| Karen Hill       |3.8|           3|
| Kimberly Peterson|3.7|           4|
| Casey Hammond    |3.5|           5|
| Jonathan Griffin |3.4|           6|
| Brittany Crawford|2.9|           9|
| Ernest Hogan     |2.9|           9|
| Rita Graham      |2.9|           9|
| Mary Mcdaniel    |2.5|          10|
| Carla Porter     |2.4|          11|
| Joseph Patterson |2.3|          14|
| Michael Robertson|2.3|          14|
| Sierra Jordan    |2.3|          14|
| Valerie May      |2.0|          15|

These are the expected results. As you can see, Kyle, the student with the highest GPA, has rank #1. However two students, Jonathan and Karen, have the second highest GPA, so they both get rank #3, due to the headmaster's uncharitable ranking system. The rankings continue consecutively for a bit until we get to what would be rank #7. Three students, Brittany, Earnest, and Rita, all have a 2.9 GPA, so we skip ranks 7 and 8 and they all get rank #9. Something similar happens a bit further down with the three students who get rank #14.

That concludes the set-up portion of this video. If you want to have a crack at solving this problem yourself, there are links in the video description to all of this set-up code and instructions on how to run it on your local machine. Feel free to pause the video now, and come back later for a solution walkthrough, coming right up.

## Solution

### Review: ROW_NUMBER(), RANK(), and DENSE_RANK()
Alright, welcome back everyone. We will now walkthrough how one might
approach this problem. So, the first thing that should jump out at you in
the problem statement is the word **rank**. This should immediately make
you think of the ranking functionality of window functions. Now, when dealing with problems
involving ranking, there are three similar functions you should consider:
`ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`. So, the first order of
business is deciding which of these functions is most useful to our present
situation.
```sql
--query demonstrating the behavior of the three main RANK-like functions
SELECT
    student_name,
    gpa,
    ROW_NUMBER() OVER (ORDER BY gpa) AS gpa_row_number,
    RANK() OVER (ORDER BY gpa) AS gpa_rank,
    DENSE_RANK() OVER (ORDER BY gpa) AS gpa_dense_rank
FROM grades
ORDER BY gpa_row_number;
```
Let's remind ourselves of the differences between these functions by
applying them to our current dataset. As you can see, `ROW_NUMBER()` always
outputs a distinct value per row, determined by the `ORDER BY` statement in
the window definition. If there is a tie in the order, `ROW_NUMBER()` just
makes up a sub-ordering at random to guarantee each row gets a distinct
value.

In contrast, both `RANK()` and `DENSE_RANK()` actually respect ties in the
ordering, and will give the same rank to all instances of a duplicated
value. However, the two functions differ in what they do *after* a set of
duplicate values. You can think of `RANK()` as keeping an internal counter
every time it processes a set of duplicate values, and when the duplicates
stop, `RANK()` continues on with the ranking value it would have used *had
the duplicates actually been distinct values*. You can see here, the
`gpa_rank` column goes 1, 2, 2, 2, 5. The "2"s repeat three times because
three students had the same GPA, but then the ranking continues on afterward
to 5 as if we had actually been counting up in the background 1, 2, 3, 4, and 5.

Now, that's how `RANK()` works. `DENSE_RANK()`, on the other hand, will
keep going after a duplicate with the next sequential rank number,
regardless of how many duplicates appear. As you can see, for the very same
rows, the `DENSE_RANK()` values go 1, 2, 2, 2, 3, because 3 comes after 2,
and it doesn't matter how many 2's there were before, `DENSE_RANK()` just
moves on to the next number. A good way to remember this
behavior difference just based on the function names is that, when a lot
of duplicates are present, the output of `DENSE_RANK()` is in a very real
sense much *denser* than the output for the regular `RANK()` function. With
`RANK()`, you can get these big gaps in the values, like 2 jumping straight
to 5, etc., but `DENSE_RANK()` only ever outputs repeated or sequential
numbers, densely packed together.

### Constructing the solution

#### Determining the right ranking function to use
Now, with that reminder, which function is best suited to our problem today?
Let's remind ourselves about the headmaster's ranking rules:
1. in general, the student with the highest GPA is ranked #1, the student
with the second highest is ranked #2 and so on
2. in case of a tie, all tied students receive the *lowest* possible rank
among them. For example, if three students have the second highest GPA, then
they all get rank #4, skipping over ranks 2 and 3.

Off the bat, we can eliminate `ROW_NUMBER()`, because the desired solution
involes tied students sharing the same rank, and `ROW_NUMBER()` always
outputs unique values for each row. The other important detail is that,
in the case of a tie, the headmaster expects a *gap* in the rankings.
That eliminates `DENSE_RANK()`, which never leaves gaps in rankings. So
we are left with good old `RANK()`.

Let's give `RANK()` a try and see how close that gets us out of the box.
Taking into account that the headmaster wants the *highest* GPA to be
ranked #1, your first thought might be to order the ranking window by `gpa DESC`.
Let's try that.
```sql
SELECT
    student_name,
    gpa,
    RANK() OVER (ORDER BY gpa DESC) AS student_rank
FROM grades
ORDER BY gpa DESC;
```
That looks pretty close! There's one issue though; this ranking is too nice
to the students who tied. It is giving them all the highest possible rank
among them instead of the lowest. For example, right now the rankings go 1, 2, 2, 4,
and we want them to go 1, 3, 3, 4.
We need the ranking gaps to be shifted
to appear between the duplicate values and the next *higher* value, rather
than the next *lower* value, like they are now.

For now, lets take a step back and try to get a bit closer to that desired structure.
Just to see what happens, lets try reversing the order of the ranking
window, in other words putting it back to a "normal" ascending rank. Note
that I'm keeping the overall query's ORDER BY clause the same, since
that is the order we will want for the final output. Okay, lets try running this.
```sql
SELECT
    student_name,
    gpa,
    RANK() OVER (ORDER BY gpa) AS student_rank
FROM grades
ORDER BY gpa DESC;
```
Now this is an interesting result. As you can see, we actually made some progress
in the structure of the rankings. The gaps now appear *before*
the duplicates instead of *after* them. It starts with the highest GPA at rank 15, we skip 14, and then
the tied students both get rank 13. This is great! The
issue now is that the actual ranking *values* are wrong--instead of ranking
the best GPA as #1, it is ranked #15 (in other words, dead last). Likewise, the worst
GPA is ranked as #1. It's almost like the rankings are the "opposite" of
what they should be, and we need to "invert" them somehow. But how can we do it?
And in what world is 1 the "inverse" of 15?

#### Fixing the rank numbers
Well, there are two ways to approach a problem like this: a practical way, and a
more math-y, theoretical way. I don't want this video to get overly long or off topic, so I
am mostly going to focus on the practical way I would go about figuring out this solution,
and just mention a few details about the theoretical backing at the end so as
to provide the more curious among you with some ideas for further study.

Fundamentally, we have one set of numbers (the correctly-spaced but incorrectly-
labelled rankings you see before you), and we need to convert them into a different
set of numbers, in other words the correct rankings. We essentially just need to
figure out the relationship between the numbers we have and the numbers we want,
and then enshrine that relationship in SQL code.

So let's take a look at some of the numbers we have, and compare them to
the numbers we want them to be.
```
15  <-->  1
13  <-->  3
12  <-->  4
11  <-->  5
...
2   <-->  14
1   <-->  15
```
Can you spot any interesting patterns here? Well, the first thing that jumps out
at me is that as the numbers on the left go down, the numbers on the right go up.
Having identified that pattern, we can then ask ourselves to quantify this
relationship: by *how much* are the numbers on the right going up as the numbers
on the left go down? It turns out, these two sets of numbers are moving in perfect lockstep
with each other, in opposite directions. If the left number goes down by some number *x*, the
right number goes up by precisely *x*, every time. This implies another interesting
feature of the relationship: if every decrease on one side is matched by a increase on the other side with the same magnitude, then the *sum* of the two numbers is always constant.
And in fact, we can easily check that in *every* case, the left number and the
right number add up to 16. 15 + 1 is 16, 13 + 3 is 16, 12 + 4 is 16, and so on.

How does that help us? Well, it gives us a formula. Specifically, `Left + Right = 16`. Now,
what was our original goal? To find a way to calculate the correct rankings, i.e.
the numbers on the right, given the current rankings, i.e. the numbers of the left.
And now we have a formula relating the two, so with a little bit of algebra we can
rearrange this formula to do exactly what we want. We just need to subtract the left
number from both sides, and get this:
```
Right = 16 - Left
```
Now we just need to encode that in SQL, and see what happens:
```sql
SELECT
    student_name,
    gpa,
    16 - RANK() OVER (ORDER BY gpa) AS student_rank
FROM grades
ORDER BY gpa DESC, student_name
;
```
It works! This produces exactly the rankings that the headmaster wanted. But, we
are not quite done. This solution works for this particular sample of student data,
but would not work for most other datasets because we have this hardcoded, magic
number in here, 16. We need to translate this literal number into a more generic
concept that will scale to any dataset. Now we must ask ourselves what is significant
about the number 16? Well, we are working with a data sample of 15 students, and
16 is just one more than that. So we need a way to write something like this
in SQL:
```sql
{the total number of rows in the table + 1} - RANK() OVER (ORDER BY gpa) AS student_rank
```
And how can we get the total number of rows in the table? Well, one way would be
to separately calculate a `COUNT(*)` across the table in a CTE or subquery,
and cross-join that back to our query here, but that is not the most idiomatic way
to do it. No, we can just use another window function:
```sql
SELECT
    student_name,
    gpa,
    COUNT(*) OVER () + 1 - RANK() OVER (ORDER BY gpa) AS student_rank
FROM grades
ORDER BY gpa DESC, student_name;
```
Leaving the window definition empty like that essentially defines the window to
be "the entire table", so every row in our results is able to reference an aggregation
across the entire table instead of across some particular ordered sub-window of the table.

And that's it, that is a general solution that will work just as well with our 15-student
sample as with the entire student body of the school. The uncharitable headmaster will be pleased.

#### Why the fix works

Now, before I leave you, I want to briefly point you toward some concepts that help
explain *why* the formula we used to fix the ranking numbers works. Earlier I posed
the question, "in what world is 1 the inverse of 15?" The answer to that is, the world of modular
arithmetic. Specifically, 1 is the *additive* inverse of 15, mod 16. And in general,
what we were doing with our solution was converting each incorrect ranking into its
additive inverse, mod "the total size of the table + 1". If you have an academic background
in computer science or mathematics, this concept may ring some bells, but if you don't, or even if you
are just rusty, I recommend reading up a bit on modular arithmetic, since it can
really come in handy every now and again working with code and data and the like.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
