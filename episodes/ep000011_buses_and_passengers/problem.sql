/*

A bus stop is a constant flow of activity. Hopeful passengers show up to wait
for the next bus, and buses stop by to pick up the waiting passengers. On busy
days in a large city, the buses might be running at near capacity most of the
time, and may only have a couple available seats when they stop to pick up
new passengers at the bus stop. This is the scene in which our problem today unfolds.

You are given two pieces of information:
1. you know when each bus arrives, and how many empty seats it has
2. you know when each prospective passenger arrives

You need to write a SQL query that figures out how many passengers get
on each bus.

========================
buses
========================
+--------------+------+
| column       | type |
+--------------+------+
| bus_id       | int  |
| arrival_time | int  | <-- NOTE: to simplify things, times are represented as simple integers
| capacity     | int  |
+--------------+------+

========================
passengers
========================
+--------------+------+
| column       | type |
+--------------+------+
| passenger_id | int  |
| arrival_time | int  |
+--------------+------+

To better clarify how this process works, here is the sequence of events implied
by the provided sample data.

Time 1  : 2 passengers arrive (2 remaining at bust stop)
Time 2  : Bus 1 arrives with capacity 1 and takes 1 passenger (1 remaining at bus stop)
Time 4  : Bus 2 arrives with capacity 5 and takes 1 passenger (0 remaining at bus stop)
Time 5  : Bus 3 arrives with capacity 3 and takes 0 passengers (0 remaining at bus stop)
Time 7  : 4 passengers arrive (4 remaining at bust stop)
Time 8  : Bus 4 arrives with capacity 2 and takes 2 passengers (2 remaining at bus stop)
Time 9  : 1 passenger arrives (3 remaining at bust stop)
Time 11 : Bus 5 arrives with capacity 3 and takes 3 passengers (0 remaning at bus stop)


EXPECTED OUTPUT
================

bus_id|passengers_cnt|
------+--------------+
     1|             1|
     2|             1|
     3|             0|
     4|             2|
     5|             3|
*/



CREATE TEMP TABLE buses AS
SELECT *
FROM (
	VALUES
	(1, 2, 1),
	(2, 4, 5),
	(3, 5, 3),
	(4, 8, 2),
	(5, 11, 3)
) AS t(bus_id, arrival_time, capacity);



CREATE TEMP TABLE passengers AS
SELECT *
FROM (
	VALUES
	(1, 1),
	(2, 1),
	(3, 7),
	(4, 7),
	(5, 7),
	(6, 7),
	(7, 9)
) AS t(passenger_id, arrival_time);
