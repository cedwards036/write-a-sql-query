/*
The Fibonacci sequence is a sequence of numbers in which each element is
the sum of the two elements that precede it. In the most common version of
the sequence, the first two numbers are defined to be 0 and 1, and
the rest of the sequence follows like so:

0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...etc

More formally, this standard version of the sequence can be defined by the following
equations:

F_0 = 0
F_1 = 1
F_n = F_n-1 + F_n-2, where n > 1

Write a SQL query that generates the first N fibonacci numbers, ordered from
smallest to largest.

NOTE: I'm not expecting a stored procedure, database function, etc, that takes
N as a parameter. Just a regular SELECT statement that has a hardcoded number
somewhere that represents N, such that changing that number directly informs
how many Fibonacci numbers the query returns. For example, setting that
number to 15 should make the query return the first 15 Fibonacci numbers.


EXPECTED RESULT WHEN N=15:

|fib_number|
------------
|0         |
|1         |
|1         |
|2         |
|3         |
|5         |
|8         |
|13        |
|21        |
|34        |
|55        |
|89        |
|144       |
|233       |
|377       |

*/

