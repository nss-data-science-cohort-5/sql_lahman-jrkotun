-- Habeeb Kotun Jr.
-- Nashville Software School, DS5
-- February 8, 2022
-- SQL Lahman

/*
Question 1: Find all players in the database who played at Vanderbilt University. 
Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
*/
SELECT 
	DISTINCT namefirst || ' ' || namelast AS full_name,
	SUM(salary)::integer::money AS total_salary
FROM people
INNER JOIN salaries 
USING (playerid)
WHERE playerid IN (
	SELECT playerid
	FROM collegeplaying
	WHERE schoolid = 'vandy')
GROUP BY full_name
ORDER BY total_salary DESC;
-- Answer: David Price is the Vanderbilt player who has earned the most money in the majors.

/*
Question 2: Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.
*/
SELECT 
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos in ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos in ('P', 'C') THEN 'Battery'
		END AS position,
		SUM(po) AS number_of_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position
ORDER BY number_of_putouts DESC;

/*
Question 3: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?
*/
SELECT 
	TRUNC(yearid, -1) AS decade,
	ROUND(SUM(so) * 2.0 / SUM(G), 2) AS strikeouts_per_game,
	ROUND(SUM(hr) * 2.0 / SUM(G), 2) AS homeruns_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
-- Answer: Strikeouts and homeruns per game have increased over time. 

/*
Question 4: Find the player who had the most success stealing bases in 2016, 
where __success__ is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases. 
Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.
*/
WITH full_batting AS (
	SELECT 
		playerid,
		SUM(sb) AS sb,
		SUM(cs) AS cs,
		SUM(sb) + SUM(cs) AS attempts
	FROM batting
	WHERE yearid = 2016
	GROUP BY playerid
)
SELECT 
	namefirst || ' ' || namelast AS name,
	sb AS stolen_bases,
	attempts AS stolen_attempts,
	ROUND((sb * 100.00) / (sb + cs), 2) AS stolen_base_percentage
FROM full_batting
INNER JOIN people 
USING (playerid)
WHERE attempts >= 20
ORDER BY stolen_base_percentage DESC;
-- Answer: Chris Owings had the most success stealing bases in 2016.

-- Question 5a: From 1970 to 2016, what is the largest number of wins for a team that did not win the world series?
SELECT 
	name,
	yearid,
	w AS number_of_wins
FROM teams
WHERE wswin = 'N'
	AND yearid >= 1970
ORDER BY w DESC;
-- Answer: 116 is the largest number of wins for a team that did not win the world series.

/*
Question 5b: What is the smallest number of wins for a team that did win the world series? 
Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. 
Then redo your query, excluding the problem year.
*/
SELECT 
	name,
	yearid,
	w AS number_of_wins
FROM teams
WHERE wswin = 'Y'
	AND yearid >= 1970
ORDER BY w;
/* 
Answer: 63 wins is the smallest number of wins for a team that did win the world series.
This was due to a strike that happened in the 1981 season. Ignoring this season it would be 83 wins.
*/

/*
Question 5c: How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? 
What percentage of the time?
*/
WITH max_wins AS (
	SELECT
		yearid,
		MAX(w) AS max_wins
	FROM teams
	WHERE yearid >= 1970
	GROUP BY yearid
	ORDER BY yearid
),
team_with_most_wins AS (
	SELECT
		t.name,
		m.yearid, 
		m.max_wins,
		t.wswin
	FROM max_wins AS m
	INNER JOIN teams AS t
	ON m.max_wins = t.w
		AND m.yearid = t.yearid
)
SELECT
ROUND((SELECT COUNT(*)
FROM team_with_most_wins
WHERE wswin = 'Y') * 100.0 /
(SELECT COUNT(*)
FROM team_with_most_wins	
), 2)
-- Answer: 22.64% of the time the team with the most wins in the season would also win the world series.

/* 
Question 6: Which managers have won the TSN Manager of the Year award in both the National League (NL) 
and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
*/
WITH nl AS (
	SELECT
		playerid,
		yearid,
	 	lgid
	 FROM awardsmanagers
	 WHERE lgid = 'NL'
	 	AND awardid = 'TSN Manager of the Year'
	),
al AS (
	SELECT 
	 	playerid,
		yearid,
	 	lgid
	 FROM awardsmanagers
	 WHERE lgid = 'AL'
	 	AND awardid = 'TSN Manager of the Year'
	),
nl_al_winners AS (
	SELECT *
	FROM NL
	WHERE playerid IN
		(SELECT playerid
		 FROM AL)
	UNION 
	SELECT *
	FROM AL
	WHERE playerid IN
		(SELECT playerid
		 FROM NL)
),
people_join AS (
	SELECT *
	FROM nl_al_winners AS n
	INNER JOIN people AS p
	USING (playerid)
)
SELECT 
	p.namefirst || ' ' || p.namelast AS full_name,
	t.name,
	p.lgid,
	p.yearid
FROM people_join AS p
INNER JOIN managers AS m
ON p.playerid = m.playerid
	AND p.yearid = m.yearid
INNER JOIN teams AS t
ON m.teamid = t.teamid
	AND p.lgid = t.lgid
	AND p.yearid = t.yearid
ORDER BY full_name;
/* 
Answer: Davey Johnson and Jim Leyland have won the TSN Manager of the Year award in both 
the National League (NL) and the American League (AL).
*/
	
/* 
Question 7: Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? 
Only consider pitchers who started at least 10 games (across all teams).
*/
SELECT 
	p1.namefirst || ' ' || p1.namelast AS full_name,
	(AVG(s.salary) * 1.0 / SUM(p2.so))::numeric::MONEY AS salary_strikeout_ratio
FROM people AS p1
INNER JOIN pitching AS p2
USING (playerid)
INNER JOIN salaries AS s
USING (playerid)
WHERE p2.yearid = 2016 
	AND s.yearid = 2016
GROUP BY full_name
HAVING SUM(p2.gs) >= 10
ORDER BY salary_strikeout_ratio DESC;
-- Matt Cain was the least efficient pitcher in 2016 in terms of salary / strikeouts.

WITH full_pitching AS (
	SELECT 
		playerid, 
		SUM(so) AS so,
		SUM(g) AS g,
		SUM(gs) AS gs
	FROM pitching
	WHERE yearid = 2016
	GROUP BY playerid
),
full_salary AS (
	SELECT playerid, SUM(salary) AS salary
	FROM salaries
	WHERE yearid = 2016
	GROUP BY playerid
)
SELECT 
	namefirst || ' ' || namelast AS fullname,
	salary / so AS dollars_per_so
FROM full_pitching
INNER JOIN full_salary
USING(playerid)
INNER JOIN people
USING(playerid)
WHERE g >= 10
ORDER BY dollars_per_so DESC;


/*
Question 8: Find all players who have had at least 3000 career hits. Report those players' names, 
total number of hits, and the year they were inducted into the hall of fame 
(If they were not inducted into the hall of fame, put a null in that column.) 
Note that a player being inducted into the hall of fame is indicated by a 'Y' in the 
**inducted** column of the halloffame table.
*/
WITH hof AS (
	SELECT 
		h.playerid AS playerid, 
		p.namefirst || ' ' || p.namelast AS name,
		h.yearid AS yearid, 
		CASE
			WHEN h.inducted = 'Y' THEN h.yearid
			ELSE NULL
		END AS induction_year
 	FROM halloffame AS h
	INNER JOIN people AS p
	USING (playerid)
),
batting_total AS (
	SELECT
		playerid,
		SUM(b.h) AS batting_total
	FROM people
	INNER JOIN batting AS b
	USING (playerid)
	GROUP BY playerid
)
SELECT 
	h.name, 
	batting_total,
	h.induction_year
FROM hof AS h
INNER JOIN batting_total AS b
USING (playerid)
WHERE batting_total >= 3000
ORDER BY h.name


