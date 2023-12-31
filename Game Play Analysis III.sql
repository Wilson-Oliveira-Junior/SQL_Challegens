'Table: Activity
+--------------+---------+
| Column Name | Type |
+--------------+---------+
| player_id | int |
| device_id | int |
| event_date | date |
| games_played | int |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some game.
Each row is a record of a player who logged in and played a number of games
(possibly 0) before logging out on some day using some device.
Write an SQL query that reports for each player and date, how many games played
so far by the player. That is, the total number of games played by the player
until that date. Check the example for clarity.
The query result format is in the following example:
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1 | 2 | 2016-03-01 | 5 |
| 1 | 2 | 2016-05-02 | 6 |
| 1 | 3 | 2017-06-25 | 1 |
| 3 | 1 | 2016-03-02 | 0 |
| 3 | 4 | 2018-07-03 | 5 |
+-----------+-----------+------------+--------------+
Result table:
+-----------+------------+---------------------+
| player_id | event_date | games_played_so_far |
+-----------+------------+---------------------+
| 1 | 2016-03-01 | 5 |
| 1 | 2016-05-02 | 11 |
| 1 | 2017-06-25 | 12 |
| 3 | 2016-03-02 | 0 |
| 3 | 2018-07-03 | 5 |
+-----------+------------+---------------------+
For the player with id 1, 5 + 6 = 11 games played by 2016-05-02, and 5 + 6 + 1 =
12 games played by 2017-06-25.
For the player with id 3, 0 + 5 = 5 games played by 2018-07-03.
Note that for each player we only care about the days when the player logged in.'

select player_id, event_date, games_played_so_far
from (
 select
 player_id, event_date,
 if(@player = (@player := player_id) and @mydate < (@mydate := event_date),
@games := @games + games_played, (@games := games_played))
 as games_played_so_far,
 @mydate := event_date
 from
 (select * from Activity order by player_id, event_date) as a,
 (
 select
 @player := (select player_id from Activity order by player_id,
event_date limit 1),
 @mydate := (select event_date from Activity order by player_id,
event_date limit 1),
 @games := (select games_played from Activity order by player_id,
event_date limit 1)
 ) as tmp
) as t;

select player_id, event_date, games_played_so_far
from (
 select
 player_id, event_date,
 @games := if(player_id = @player, @games + games_played, games_played)
 as games_played_so_far,
 @player := player_id
 from
 (select * from Activity order by player_id, event_date) as a,
 (select @player := -1, @games := 0) as tmp
) as t;