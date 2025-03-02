/*
The facilities manager at a prominent music conservatory has a logistics
problem. Toward the end of each academic year, graduating students must
each give a "graduation recital" as part of their degree requirements.
These recitals take place in one of two recital halls (dubbed Hall A and
Hall B), which must be booked in advance by the students' various
departments (e.g. piano, voice, brass, etc.). Each department can book
a hall for multiple days at a time, and multiple departments can book the
same hall on the same day.

On any day where a hall is in use *at all*, the facilities manager has to
perform certain preparatory steps to make sure the hall is ready to use (e.g.
put out chairs and stands, double-check the AV systems, etc.). So, the
manager needs to know when the hall is going to be in use. The manager
currently has access to a database table, recital_hall_bookings, with the
following structure:

========================
recital_hall_bookings
========================
+------------+-------------+
| column     | type        |
+------------+-------------+
| hall       | text        |
| department | text        |
| start_date | timestamp   |
| end_date   | text        |
+------------+-------------+

Each row contains the start and end dates of a reservation of a particular
hall by a particular department. While this data is helpful, it can be
complicated to read at times. Reservations can overlap with each other
in many different ways, and there can be "duplicate" reservations with the
same start and end dates as each other.

The facilities manager would really like a simplified report with only one
row per continuous period of use per hall. In other words, every time there
are duplicate or overlapping reservation time windows, the facilities manager
would like to "squash" them into a single row. We need to write a SQL query
to accomplish this "squashing" procedure.


EXPECTED OUTPUT
================

hall  |start_date|end_date  |
------+----------+----------+
Hall A|2025-03-15|2025-03-16|
Hall A|2025-03-17|2025-03-25|
Hall B|2025-03-14|2025-03-22|
Hall B|2025-03-25|2025-03-26|
Hall B|2025-03-27|2025-03-28|

*/




CREATE TEMP TABLE recital_hall_bookings AS
SELECT
	hall,
	department,
	start_date::date AS start_date,
	end_date::date AS end_date
FROM (
	VALUES
	('Hall A', 'Piano', '2025-03-15', '2025-03-16'),
	('Hall A', 'Voice', '2025-03-17', '2025-03-20'),
	('Hall A', 'Strings', '2025-03-18', '2025-03-19'),
	('Hall A', 'Brass', '2025-03-20', '2025-03-25'),
	('Hall B', 'Voice', '2025-03-14', '2025-03-19'),
	('Hall B', 'Woodwinds', '2025-03-17', '2025-03-22'),
	('Hall B', 'Strings', '2025-03-17', '2025-03-22'),
	('Hall B', 'Brass', '2025-03-25', '2025-03-26'),
	('Hall B', 'Piano', '2025-03-27', '2025-03-28')
) AS t(hall, department, start_date, end_date);
