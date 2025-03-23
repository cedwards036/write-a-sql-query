# All Ingredients Required

## Problem Statement
Hello everyone, my name is Chris Edwards and today we're going to write a SQL
query! Our problem today involves figuring out whether *all* values from one
set of data exist in another set of data. I've seen this kind of problem pop
up every now and again in my professional work, and I think it is useful to know
how to approach it.

*(read problem statement, make sure to discuss expected output)*

All right, that's all the set-up for today. If you want to have a crack at solving
this problem yourself, there are links in the video description to this full problem
statement and instructions on how to replicate this coding environment on your
local machine. Feel free to pause the video now, and come back later for a solution
walkthrough, coming right up.

## Solution Walkthrough

### Picking the correct join
Alright, welcome back everyone. We will now take a look at a possible solution
to this problem. Right off the bat, we have a problem asking us to reconcile the
contents of two tables, to check whether values in one table exist in the other.
So, immediately, you should think, "I have to join these tables". And specifically,
we are trying to reconcile the *ingredient* values from each table, so we should
probably join using the `ingredient` columns from each table. And, finally, we
need to decide what type of join we should use. Should it be an INNER JOIN or a
LEFT JOIN? Well, what's our ultimate goal here? We need our final output to *include*
recipes where all the ingredients match what's in the kitchen, and *exclude* recipes
with ingredients that don't match. That kind of sounds like an INNER JOIN: keeping
the records that match and discarding the records that don't. However, our situation
is a little more complicated than that, and unfortunately a simple inner join
will not suffice. Let's see what would happen if we used an inner join:
```sql
SELECT
	r.recipe,
	r.ingredient AS recipe_ingredient,
	k.ingredient AS kitchen_ingredient
FROM recipes r
JOIN kitchen_ingredients k
	ON r.ingredient = k.ingredient
ORDER BY recipe, recipe_ingredient;
```
As you can see, we get all the Omelette and Quiche recipe rows that we need for
our final output, but we also get some rows for the Chocolate Chip Cookie recipe.
And that's because, while we don't have *all* required ingredients to make cookies,
we do have *some* of the ingredients. So, instead of excluding the entire cookie
recipe like we want, a simple inner join will just include an *incomplete* cookie
recipe. So, it looks like an inner join is not what we need right now. Let's try
a LEFT JOIN, and see where that gets us:
```sql
SELECT
	r.recipe,
	r.ingredient AS recipe_ingredient,
	k.ingredient AS kitchen_ingredient
FROM recipes r
LEFT JOIN kitchen_ingredients k
	ON r.ingredient = k.ingredient
ORDER BY recipe, recipe_ingredient;
```
This represents a clear improvement over the previous query. While it might not
look like it at first glance, since now the output includes *more* cookie recipe
rows than before, we are now actually closer to our goal. And that is because
we now have something that differentiates the cookie recipe, which we want to exclude,
from the other recieps, which we want to keep. Namely, the cookie recipe occasionally
has NULLs in the kitchen_ingredient column, while the other recipes never do.

### Exploiting the NULLs to our advantage
The next question is, how can we use these NULLs to filter out *all* cookie recipe
rows, even the rows that don't have NULLs in them? It's clear that we can't purely
look at individual rows. Just because *one* ingredient, and therefore one row, matches
the list of kitchen ingredients, doesn't mean the entire recipe matches. We need
to look at the recipe as a whole, or, put another way, the recipe *in aggregate*.
If that isn't enough of a hint, we need to use aggregation of some kind. But what
can we aggregate? We have categorical data here--the names of ingredients--so we
can't use a SUM or other such numeric formula. But we can use a COUNT. So let's
try that, let's aggregate at the recipe grain, using the COUNT function and see
where we get:
```sql
SELECT
	r.recipe,
	COUNT(r.ingredient) AS recipe_ingredient_count,
	COUNT(k.ingredient) AS kitchen_ingredient_count
FROM recipes r
LEFT JOIN kitchen_ingredients k
	ON r.ingredient = k.ingredient
GROUP BY r.recipe
ORDER BY recipe;
```
Now this is very interesting. This has revealed another useful differentiator between
the cookie recipe and the other two recipes. For the recipes where *all* their
ingredients match the kitchen ingredient list, the recipe_ingredient_count and
the kitched_ingredient_count are the same. But for the cookie recipe, because
there are NULLs in the kitchen_ingredient column, and because the COUNT function
in SQL ignores NULLs, the recipe and kitchen ingredient counts are different! And
we can use this fact to filter out the chocolate chip cookies recipe. Just throw
in a HAVING clause, and voila:
```sql
SELECT
	r.recipe,
	COUNT(r.ingredient) AS recipe_ingredient_count,
	COUNT(k.ingredient) AS kitchen_ingredient_count
FROM recipes r
LEFT JOIN kitchen_ingredients k
	ON r.ingredient = k.ingredient
GROUP BY r.recipe
HAVING COUNT(r.ingredient) = COUNT(k.ingredient)
ORDER BY recipe;
```
We have successfully filtered down to just the two recipes, Quiche and Omelette,
for which our kitchen has *all* necessary ingredients. Except, we're not quite
done. Our home cook doesn't just want the *names* of the recipes that they can
cook, they want the full ingredient lists as well. So we need one extra step
here to pull back in the full contents of the recipe table for these two recipes.

### Two possible solutions
There are actually two ways that you can do this, and I'll briefly show you both
of them.
```sql
--using group by, having, and a join
WITH recipes_with_counts AS (
	SELECT
		r.recipe,
		COUNT(r.ingredient) AS recipe_ingredient_count,
		COUNT(k.ingredient) AS kitchen_ingredient_count
	FROM recipes r
	LEFT JOIN kitchen_ingredients k
		ON r.ingredient = k.ingredient
	GROUP BY r.recipe
	HAVING COUNT(r.ingredient) = COUNT(k.ingredient)
)
SELECT
	r.recipe,
	r.ingredient
FROM recipes_with_counts c
JOIN recipes r
	ON c.recipe = r.recipe
ORDER BY recipe, ingredient;


--using window functions
WITH recipes_with_counts AS (
	SELECT
		r.recipe,
		r.ingredient,
		COUNT(r.ingredient) OVER (PARTITION BY r.recipe) AS recipe_ingredient_count,
		COUNT(k.ingredient) OVER (PARTITION BY r.recipe) AS kitchen_ingredient_count
	FROM recipes r
	LEFT JOIN kitchen_ingredients k
		ON r.ingredient = k.ingredient
)
SELECT
	recipe,
	ingredient
FROM recipes_with_counts
WHERE recipe_ingredient_count = kitchen_ingredient_count
ORDER BY recipe, ingredient;
```
Option number one is just a slight extension of the query we had in the previous
step. We basically just wrap that existing query in a common table expression, or
CTE, and then join it on `recipe` back to the original recipe table. And as you can
see, that works; it returns our expected results as we hoped.

Option number 2 requires us to modify our previous query a bit If, instead of
standard aggregation using GROUP BY, we instead calculate the ingredient counts
as window functions, we can keep the grain of our dataset at the recipe-ingredient
grain, thereby allowing us to skip the join back to the original recipe table.
We still need the common table expression in order for us to filter on the output
of our window function COUNTs, but otherwise I think this version of the query
is slightly simpler and more elegant than the traditional aggregation strategy.

As an aside, I only need this common table expression because I am using Postgres,
a database that has not yet implemented the `QUALIFY` keyword. `QUALIFY` is a relatively
recent arrival in the SQL language space but it already has support in several major database
systems. `QUALIFY` is to window functions what `HAVING` is to aggregations. It allows
you to filter on the results of a window function in the same query, without using
a CTE or subquery. If Postgres supported `QUALIFY`, then our solution could be
even shorter, and look something like this:
```sql
	SELECT
		r.recipe,
		r.ingredient
	FROM recipes r
	LEFT JOIN kitchen_ingredients k
		ON r.ingredient = k.ingredient
	QUALIFY COUNT(r.ingredient) OVER (PARTITION BY r.recipe) = COUNT(k.ingredient) OVER (PARTITION BY r.recipe)
```
But for now, the classic strategy of sequestering the window functions in a CTE
and then filtering on them in a separate query works just fine.

## Outro
Alright well that's it for this video. Thank you all for watching. If you have any
further questions about this problem, or if you think of a different approach to the
solution that I may not have considered, please let me know in the comments. And
be sure to subscribe for more SQL query writing content in the future. Until next time,
happy querying!
