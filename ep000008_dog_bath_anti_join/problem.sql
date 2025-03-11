/*
A local dog grooming salon offers two main services for its furry
clientele: bathing and nail trimming. A nail trim appointment lasts only
15 minutes and is relatively cheap, while a full-service bath appointment
lasts a full hour and is much more expensive. Currently, the cheaper nail
trim service is much more popular than the expensive bathing service, but
the salon manager wants to change that. The manager wants to run a special
promotion to try to convince current nail-only customers to try out the
premium bathing service. The salon's appointment booking system maintains
two database tables, bath_appointments and nail_appointments, with the
following structures:

========================
bath_appointments
========================
+----------------------+-----------+
| column               | type      |
+----------------------+-----------+
| dog_name             | text      |
| appointment_datetime | timestamp |
+----------------------+-----------+

========================
nail_appointments
========================
+----------------------+-----------+
| column               | type      |
+----------------------+-----------+
| dog_name             | text      |
| appointment_datetime | timestamp |
+----------------------+-----------+

To help the salon manager figure out which clients to include in the
promotional campaign, we need to write a SQL query that returns a list
of dog_names that have had at least one previous nail trim appointment,
but have *never* booked a bath appointment. The results should contain
no duplicate names and should be sorted in alphabetical order by name.

EXPECTED OUTPUT
================

dog_name|
--------+
Lizzie  |
Minnie  |
Rascal  |
Tucker  |

*/

CREATE TEMP TABLE bath_appointments AS
SELECT
    dog_name,
    appointment_datetime::timestamp AS appointment_datetime
FROM (
    VALUES
    ('Charles', '2025-04-01 09:00'),
    ('Pancake', '2025-04-01 10:00'),
    ('Lady', '2025-04-01 11:00'),
    ('Bagle', '2025-04-02 09:00'),
    ('Scout', '2025-04-02 10:00')
) AS t(dog_name, appointment_datetime);


CREATE TEMP TABLE nail_trim_appointments AS
SELECT
    dog_name,
    appointment_datetime::timestamp AS appointment_datetime
FROM (
    VALUES
    ('Lizzie', '2025-04-01 09:00'),
    ('Rascal', '2025-04-01 09:15'),
    ('Bagle', '2025-04-01 09:30'),
    ('Scout', '2025-04-01 09:45'),
    ('Tucker', '2025-04-01 10:00'),
    ('Lady', '2025-04-01 10:45'),
    ('Charles', '2025-04-02 10:00'),
    ('Minnie', '2025-04-02 10:15'),
    ('Rascal', '2025-04-08 09:00')
) AS t(dog_name, appointment_datetime);