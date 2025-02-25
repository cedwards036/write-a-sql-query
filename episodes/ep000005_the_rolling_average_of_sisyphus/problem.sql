/*
A man named Sisyphus has been trying to roll a boulder up a large hill every day
for what feels like ~forever~. Every time he thinks he's getting close to the top
of the hill, something inevitably goes wrong, and the boulder ends up rolling all
the way back down to the bottom, forcing him to try again the next day.

One day, refusing to be discouraged, Sisyphus decides to start tracking his progress,
so that he can at least tell if his boulder-rolling ability is improving over time.
For two weeks, every time he loses control of the boulder and it goes rolling
back down the hill, Sisyphus records how far up the hill he got that day in a
simple database table, rolling_data, with the following structure:

==============
rolling_data
==============
+-------------------+------------+
| column            | type       |
+-------------------+------------+
| attempt_date      | date       |
| height_in_meters  | float      |
+-------------------+------------+

In each row, Sisyphus records the highest point of his ascent on the given attempt_date.
This raw data is a good start, but, as an experienced data practitioner, Sisyphus
is wary of the effects that random fluctuations from day to day might have on the
overall picture. For example, if he sees that he got farther one day than the day
before, does that mean that he is actually getting better at rolling over time, or
did he just have a particularly good day by accident?

In order to better see the overall trends in his boulder-rolling performance, Sisyphus
would like to calculate a rolling average for each date. Specifically, for each
date in the data, he wants to see the average height_in_meters across three
days: the date itself, the day before, and the day after.

We need to write a SQL query that helps Sisyphus get the rolling average data
described above.

EXPECTED OUTPUT
================

attempt_date|rolling_average    |
------------+-------------------+
  2025-03-01|             27.545|
  2025-03-02|27.7366666666666667|
  2025-03-03|27.6066666666666667|
  2025-03-04|27.5933333333333333|
  2025-03-05|27.1266666666666667|
  2025-03-06|27.4266666666666667|
  2025-03-07|28.2466666666666667|
  2025-03-08|              28.94|
  2025-03-09|29.1966666666666667|
  2025-03-10|29.2633333333333333|
  2025-03-11|29.3566666666666667|
  2025-03-12|              28.34|
  2025-03-13|              27.29|
  2025-03-14|             26.395|

*/


CREATE TEMP TABLE rolling_data AS
SELECT
	attempt_date::date AS attempt_date,
	height_in_meters
FROM (
	VALUES
	('2025-03-01', 28.14),
	('2025-03-02', 26.95),
	('2025-03-03', 28.12),
	('2025-03-04', 27.75),
	('2025-03-05', 26.91),
	('2025-03-06', 26.72),
	('2025-03-07', 28.65),
	('2025-03-08', 29.37),
	('2025-03-09', 28.80),
	('2025-03-10', 29.42),
	('2025-03-11', 29.57),
	('2025-03-12', 29.08),
	('2025-03-13', 26.37),
	('2025-03-14', 26.42)
) AS t(attempt_date, height_in_meters);
