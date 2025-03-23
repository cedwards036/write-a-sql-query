/*
A fastidious home cook maintains a simple database table, kitchen_ingredients,
containing a list of the ingredients that they currently have on hand in their
kitchen. They also maintain a separate table, recipes, that stores the recipes
that this cook knows along with their required ingredients.

========================
kitchen_ingredients
========================
+----------------------+-----------+
| column               | type      |
+----------------------+-----------+
| ingredient           | text      |
+----------------------+-----------+

========================
recipes
========================
+----------------------+-----------+
| column               | type      |
+----------------------+-----------+
| recipe               | text      |
| ingredient           | timestamp |
+----------------------+-----------+

We need to write a SQL query to help this cook figure out which recipes they
can make using *only* the ingredients that they have in the kitchen right now.
The query should return the recipe names and full lists of ingredients for all
recipes for which the cook currently has *all* required ingredients.

Note: we are not concerned with the *amounts* of ingredients needed for each
recipe, just whether each ingredient is in the kitchen or not. This home cook
always buys ingredients in bulk from their favorite wholesale bargain store, and
if they have *any* of an ingredient, they tend to have a whole lot of it, so
quantity is not a concern.

EXPECTED OUTPUT
================

recipe  |ingredient      |
--------+----------------+
Omelette|Butter          |
Omelette|Cheese          |
Omelette|Egg             |
Omelette|Salt            |
Quiche  |Butter          |
Quiche  |Cheese          |
Quiche  |Egg             |
Quiche  |Frozen Pie Crust|
Quiche  |Salt            |
Quiche  |Spinach         |

*/


CREATE TEMP TABLE kitchen_ingredients AS
SELECT
    ingredient
FROM (
    VALUES
    ('Egg'),
    ('Salt'),
    ('Butter'),
    ('Cheese'),
    ('Spinach'),
    ('Frozen Pie Crust'),
    ('Sugar')
) AS t(ingredient);


CREATE TEMP TABLE recipes AS
SELECT
    recipe,
    ingredient
FROM (
    VALUES
    ('Quiche', 'Egg'),
    ('Quiche', 'Salt'),
    ('Quiche', 'Butter'),
    ('Quiche', 'Cheese'),
    ('Quiche', 'Spinach'),
    ('Quiche', 'Frozen Pie Crust'),

    ('Chocolate Chip Cookies', 'Flour'),
    ('Chocolate Chip Cookies', 'Egg'),
    ('Chocolate Chip Cookies', 'Butter'),
    ('Chocolate Chip Cookies', 'Sugar'),
    ('Chocolate Chip Cookies', 'Chocolate Chips'),
    ('Chocolate Chip Cookies', 'Salt'),

    ('Omelette', 'Egg'),
    ('Omelette', 'Salt'),
    ('Omelette', 'Butter'),
    ('Omelette', 'Cheese')
) AS t(recipe, ingredient);