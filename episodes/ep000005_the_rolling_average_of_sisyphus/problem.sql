/*
A man named Sisyphus has been trying to roll a boulder up a large hill every day
for what feels like ~forever~. Every time he thinks he's getting close to the top
of the hill, something inevitably goes wrong, and the boulder ends up rolling all
the way back down to the bottom, forcing him to try again the next day.

One day, refusing to be discouraged, Sisyphus decides to start tracking his progress,
so that he can at least tell if his boulder-rolling ability is improving over time.
For two weeks, every time he loses control of the boulder and it goes rolling
back down the hill, Sisyphus records how far up the hill he got that day in a
simple database table with the following structure:

+-------------------+------------+
| column            | type       |
+-------------------+------------+
| attempt_date      | date       |
| height_in_meters  | float      |
+-------------------+------------+

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
described above. [TODO: finish the problem description, set up code, expected
results, etc]
*/