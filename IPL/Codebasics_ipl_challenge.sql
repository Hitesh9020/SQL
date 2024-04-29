use codebasics;

select * from dim_match_summary;
select * from dim_players;
select * from fact_bating_summary;
select * from fact_bowling_summary;

drop table if exists fact_bating_summary_with_season;
create table fact_bating_summary_with_season as
(select *, case when year(date) = 2021 then 'Season 14'
when year(date) = 2022 then 'Season 15'
when year(date) = 2023 then 'Season 16' else 0 end as season from 
(select b.*, str_to_date(s.matchDate,'%b %d,%Y') as date
from fact_bating_summary b
left join dim_match_summary s on b.match_id = s.match_id) s );

drop table if exists fact_bowling_summary_with_season;
create table fact_bowling_summary_with_season as
(select *, (FLOOR(overs) * 6 + (overs - FLOOR(overs)) * 10) AS Delivered_Balls,
case when year(date) = 2021 then 'Season 14'
when year(date) = 2022 then 'Season 15'
when year(date) = 2023 then 'Season 16' else 0 end as season from 
(select b.*, str_to_date(s.matchDate,'%b %d,%Y') as date
from fact_bowling_summary b
left join dim_match_summary s on b.match_id = s.match_id) s );

-- Primary Insights

-- 1. Top 10 batsmen based on past 3 years total runs scored.
select batsmanName, sum(runs) as Runs_Scored, sum(balls) as From_balls from fact_bating_summary
group by batsmanName
order by Runs_Scored desc limit 10;

-- 2. Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in each season)
SELECT batsmanName, ROUND(SUM(runs) / SUM(CASE WHEN `out_or_not_out` = 'out' THEN 1 else 0 END), 2) AS batting_avg FROM fact_bating_summary_with_season 
WHERE season IN ('Season 14' and 'Season 15'and 'Season 16')
GROUP BY batsmanName
HAVING 
 SUM(CASE WHEN season = 'Season 14' THEN balls END) >= 60
 AND SUM(CASE WHEN season = 'Season 15' THEN balls END) >= 60
 AND SUM(CASE WHEN season = 'Season 16' THEN balls END) >= 60
ORDER BY batting_avg DESC LIMIT 10;


-- 3. Top 10 batsmen based on past 3 years strike rate (min 60 balls faced in each season)
select batsmanName, round((sum(runs) / sum(balls)) * 100,2)  as Strike_Rate from fact_bating_summary_with_season
where season in ('Season 14' and 'Season 15'and 'Season 16')
group by batsmanName
HAVING 
 SUM(CASE WHEN season = 'Season 14' THEN balls END) >= 60
 AND SUM(CASE WHEN season = 'Season 15' THEN balls END) >= 60
 AND SUM(CASE WHEN season = 'Season 16' THEN balls END) >= 60
order by Strike_Rate desc limit 10;

-- 4. Top 10 bowlers based on past 3 years total wickets taken.
select bowlerName, sum(wickets) as Total_Wickerts_Taken from fact_bowling_summary
group by bowlerName
order by Total_Wickerts_Taken desc limit 10;

-- 5. Top 10 bowlers based on past 3 years bowling average. (min 60 balls bowled in each season)
select bowlerName, round((sum(runs) / sum(wickets)),2) as bowling_average from fact_bowling_summary_with_season
group by bowlerName
having count(distinct season) = 3
order by bowling_average limit 10;

-- 6. Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)
select bowlerName,  round(avg(economy),2) as economy_rate from fact_bowling_summary_with_season
where season in ('Season 14' and 'Season 15'and 'Season 16')
group by bowlerName 
having count(distinct season) = 3 and sum(Delivered_balls) >= 180
order by economy_rate limit 10;

-- 7. Top 5 batsmen based on past 3 years boundary % (fours and sixes).
select batsmanName,  round(((sum(4s * 4) + sum(6s * 6)) / sum(runs)) * 100,2) as boundary from fact_bating_summary_with_season
where season in ('Season 14' and 'Season 15'and 'Season 16')
group by batsmanName
HAVING count(distinct season) = 3
order by boundary desc limit 5;

-- 8. Top 5 bowlers based on past 3 years dot ball %.
with dot_balls as
(select *, round((Total_Dot_balls / Total_Delivered_Balls) * 100,2) as Dot_Balls_Percentage from
(select bowlerName As Bowler_Name, sum(FLOOR(overs) * 6 + (overs - FLOOR(overs)) * 10) AS Total_Delivered_Balls, 
sum(0s) as Total_Dot_balls from 
(select b.*, STR_TO_DATE(s.matchDate, '%b %d, %Y')  as date from fact_bowling_summary b
join dim_match_summary s on b.match_id = s.match_id) j
group by bowlerName) dot_balls
where Total_Delivered_Balls > 500
group by Bowler_Name
order by Dot_Balls_Percentage desc limit 5)

select * from dot_balls;

-- 9. Top 4 teams based on past 3 years winning %.
SELECT team_name, (SUM(wins) / COUNT(*) * 100) AS winning_percentage FROM 
( SELECT team1 AS team_name, CASE WHEN winner = team1 THEN 1 ELSE 0 END AS wins FROM dim_match_summary
UNION ALL
SELECT team2 AS team_name, CASE WHEN winner = team2 THEN 1 ELSE 0 END AS wins FROM dim_match_summary ) AS all_matches
GROUP BY team_name
ORDER BY winning_percentage DESC limit 4;

-- 10.Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years
select winner, count(margin) as Total_wins_while_chasing from dim_match_summary 
where margin like "%wickets%"
group by winner
order by Total_wins_while_chasing desc limit 2;