/*
"The Magic of Basket Weaving" is a small travelling exhibit with a collection
of artisan woven baskets from various cultures around the world. The exhibit
consists of a short educational experience in which guests walk through
a few corridors lined with exemplars of the basket-weaving tradition,
occasionally stopping to read information cards and to admire the
craftsmanship on display.

While there is no *hard* cap on the number of guests that can experience
the exhibit at any one time, there is a loosely-defined practical limit on the number
of people that can comfortably walk through the corridors together. In order
to ensure that all guests have a pleasant experience, the exhibit director
has recently instituted a queueing system that limits how many people can
enter the exhibit at any one time.

When guests arrive at the exhibit, they are put into an entry queue grouped
by "party". A "party" is a group of guests that came together, for example a
group of friends, a family, etc. Every half hour, a new set of guests are
taken off the queue and allowed entry to the exhibit. The number of guests
that are allowed in depends on two things: (1) an intended "soft" cap of
6 guests per half hour, and (2) the groupings of parties in the queue.
In general, at most 6 guests can enter the exhibit at once, *unless*
limiting entry to 6 would necessitate splitting up a party. The director
will allow more than 6 people to enter at once in order to ensure that
parties are never split up. For example, if a party of 4 and a party of 3
are both queued to enter at the next half hour, *both* will be allowed to
enter even though their numbers total to 7.


Given the reservation_queue table defined below, write a SQL query to select
the very next group of people to be admitted at 9:30, based on the rules described
above.

NOTE: while the director currently has the soft cap set at 6, she may change
her mind later, so the query should be written such that you may easily alter
the soft cap to another number with minimal changes to the query overall.


EXPECTED RESULT for a soft cap of 6:

guest_party_id|guest_name    |entered_queue_at|
--------------+--------------+----------------+
             1|Anne Thompson |2024-12-03 09:13|
             1|Billy Thompson|2024-12-03 09:13|
             1|John Thompson |2024-12-03 09:13|
             1|Suzie Thompson|2024-12-03 09:13|
             2|Bart Simpson  |2024-12-03 09:16|
             2|Homer Simpson |2024-12-03 09:16|
             2|Lisa Simpson  |2024-12-03 09:16|
             2|Maggie Simpson|2024-12-03 09:16|
             2|Marge Simpson |2024-12-03 09:16|


EXPECTED RESULT for a soft cap of 4:

guest_party_id|guest_name    |entered_queue_at|
--------------+--------------+----------------+
             1|Anne Thompson |2024-12-03 09:13|
             1|Billy Thompson|2024-12-03 09:13|
             1|John Thompson |2024-12-03 09:13|
             1|Suzie Thompson|2024-12-03 09:13|


EXPECTED RESULT for a soft cap of 10:

guest_party_id|guest_name     |entered_queue_at|
--------------+---------------+----------------+
             1|Anne Thompson  |2024-12-03 09:13|
             1|Billy Thompson |2024-12-03 09:13|
             1|John Thompson  |2024-12-03 09:13|
             1|Suzie Thompson |2024-12-03 09:13|
             2|Bart Simpson   |2024-12-03 09:16|
             2|Homer Simpson  |2024-12-03 09:16|
             2|Lisa Simpson   |2024-12-03 09:16|
             2|Maggie Simpson |2024-12-03 09:16|
             2|Marge Simpson  |2024-12-03 09:16|
             3|Alicia Chen    |2024-12-03 09:25|
             3|Grace Bell     |2024-12-03 09:25|
             3|Jennie Piper   |2024-12-03 09:25|
             3|Karen Nguyen   |2024-12-03 09:25|
             3|Naoko Tachibana|2024-12-03 09:25|
 */


CREATE TEMP TABLE IF NOT EXISTS reservation_queue AS
SELECT
    guest_party_id,
    guest_name,
    entered_queue_at
FROM (
    VALUES
    (1, 'Anne Thompson', '2024-12-03 09:13'),
    (1, 'John Thompson', '2024-12-03 09:13'),
    (1, 'Billy Thompson', '2024-12-03 09:13'),
    (1, 'Suzie Thompson', '2024-12-03 09:13'),

    (2, 'Bart Simpson', '2024-12-03 09:16'),
    (2, 'Lisa Simpson', '2024-12-03 09:16'),
    (2, 'Marge Simpson', '2024-12-03 09:16'),
    (2, 'Homer Simpson', '2024-12-03 09:16'),
    (2, 'Maggie Simpson', '2024-12-03 09:16'),


    (3, 'Alicia Chen', '2024-12-03 09:25'),
    (3, 'Grace Bell', '2024-12-03 09:25'),
    (3, 'Jennie Piper', '2024-12-03 09:25'),
    (3, 'Karen Nguyen', '2024-12-03 09:25'),
    (3, 'Naoko Tachibana', '2024-12-03 09:25'),

    (4, 'Harold Muller', '2024-12-03 09:26'),
    (4, 'Geoff Armand', '2024-12-03 09:26')
) AS t(guest_party_id, guest_name, entered_queue_at);
