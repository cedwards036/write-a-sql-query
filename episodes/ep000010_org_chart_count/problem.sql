/*
A small-town tech support company is performing an HR
audit of sorts. The CEO, Mira, wants to determine how many other
employees each employee is responsible for. Every employee is
responsible for themselves, as well as for all of their direct
and indirect reports.

            Mira
         /   |    \
        /    |     \
   Laura   Angela   Maria
    /  \
   /    \
James   Eddie

For example, using the org chart above, Angela is reponsible for
just one person--herself--while Laura is responsible for three
people--herself, James, and Eddie. Mira, as the CEO, is responsible
for everyone in the company.

The company maintains the following two tables, employees and
employee_managers:

========================
employees
========================
+----------------------+-----------+
| column               | type      |
+----------------------+-----------+
| employee_id          | int       |
| employee_name        | text      |
+----------------------+-----------+

========================
employee_managers
========================
+----------------------+-----------+
| column               | type      |
+----------------------+-----------+
| employee_id          | int       | <-- FK to employees
| manager_id           | int       | <-- FK to employees
+----------------------+-----------+

We need to write a SQL query using these tables that returns
the name of each employee along with the number of employees
they are responsible for.



EXPECTED OUTPUT
================

employee_name|responsible_for_count|
-------------+---------------------+
Mira         |6                    |
Laura        |3                    |
Angela       |1                    |
Eddie        |1                    |
James        |1                    |
Maria        |1                    |
*/





CREATE TEMP TABLE employees AS
SELECT *
FROM (
	VALUES
	(1, 'Laura'),
	(2, 'Angela'),
	(3, 'James'),
	(4, 'Maria'),
	(5, 'Eddie'),
	(6, 'Mira')
) AS t(employee_id, employee_name);

CREATE TEMP TABLE employee_managers AS
SELECT *
FROM (
	VALUES
	(1, 6),
	(2, 6),
	(3, 1),
	(4, 6),
	(5, 1)
) AS t(employee_id, manager_id);