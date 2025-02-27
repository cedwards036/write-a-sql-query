/*
The Avian Adventurers Club is a group of nature enthusiasts who frequently
go bird-watching together. In order to spice things up, and to motivate some
of the newer members, the club leaders decide to award a small prize to
anyone who spots at least 3 different species of bird during the next club
outing.

In order to track progress toward this goal, every time a club member
spots a bird, they use an app to record the species of bird and the time
of the sighting in a database table, bird_sightings, with the following structure:

========================
bird_sightings
========================
+----------------------+-------------+
| column               | type        |
+----------------------+-------------+
| club_member_name     | text        |
| sighting_timestamp   | timestamp   |
| species              | text        |
+----------------------+-------------+

We need to write a SQL query that returns the "winners" of this little
bird-watching game. Specifically, the query should return the names of all
club members who saw at least 3 different species of bird, along with the
total number of species they each saw.

A couple additional notes:
- if someone saw the same species of bird multiple times that day, that
  will be represented by multiple rows with the same club_member_name and
  species values, but different sighting_timestamps
- the results should be sorted by species_count from greatest to least
- to get the most benefit from this exercise, you should try to solve this
  with just a single SELECT statement; no CTEs or subqueries.

EXPECTED OUTPUT
================

club_member_name|species_count|
----------------+-------------+
James           |            4|
Anna            |            3|

*/



CREATE TEMP TABLE bird_sightings AS
SELECT
    club_member_name,
    sighting_timestamp::timestamp AS sighting_timestamp,
    species
FROM (
    VALUES
        ('James', '2025-03-10 09:22', 'Bird A'),
        ('Anna', '2025-03-10 09:24', 'Bird A'),
        ('James', '2025-03-10 09:38', 'Bird B'),
        ('James', '2025-03-10 09:38', 'Bird D'),
        ('Eva', '2025-03-10 09:45', 'Bird A'),
        ('Martin', '2025-03-10 09:46', 'Bird C'),
        ('Eva', '2025-03-10 09:59', 'Bird C'),
        ('James', '2025-03-10 10:13', 'Bird A'),
        ('Anna', '2025-03-10 10:17', 'Bird B'),
        ('James', '2025-03-10 10:26', 'Bird C'),
        ('Eva', '2025-03-10 10:31', 'Bird A'),
        ('Martin', '2025-03-10 10:32', 'Bird B'),
        ('Anna', '2025-03-10 10:42', 'Bird C')
) AS t(club_member_name, sighting_timestamp, species);

