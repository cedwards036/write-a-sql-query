/*
Write a query that returns the student names and GPAs from the `grades` table
along with a new column, `student_rank`, that contains that student's GPA rank
per the headmaster's uncharitable ranking system.

In general, the student with the highest G.P.A. should be ranked #1, the student
with the second highest ranked #2, and so on.

In the case of a tie, if n students have the G.P.A. that would otherwise have been
given rank # x, then all n students instead receive rank # x + n - 1. For example, if
there is a three-way tie for second place then all three students should be
ranked #4 (2 + 3 - 1 = 4).

The results should be sorted in order of highest GPA to lowest GPA.
*/

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
