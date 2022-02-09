-- Habeeb Kotun Jr.
-- Nashville Software School, DS5
-- February 8, 2022
-- SQL Lahman

-- Question 1
SELECT DISTINCT (NAMEFIRST || ' ' || NAMELAST) AS NAME,
	SUM(SALARY) AS TOTAL_SALARY
FROM PEOPLE
INNER JOIN SALARIES USING (PLAYERID)
INNER JOIN COLLEGEPLAYING USING (PLAYERID)
INNER JOIN SCHOOLS USING (SCHOOLID)
WHERE SCHOOLNAME = 'Vanderbilt University'
GROUP BY NAME
ORDER BY TOTAL_SALARY DESC;
-- Answer: David Price is the Vanderbilt player who has earned the most money in the majors.

-- Question 2
SELECT 
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos in ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos in ('P', 'C') THEN 'Battery'
		END AS position,
		COUNT(po) AS number_of_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position;

-- Question 3?
SELECT TRUNC(YEARID, -1) AS DECADE,
	ROUND(AVG(SO), 2) AS STRIKEOUTS_PER_GAME,
	ROUND(AVG(HR), 2) AS HOMERUNS_PER_GAME
FROM BATTING
WHERE YEARID >= 1920
GROUP BY DECADE
ORDER BY DECADE;
-- Answer: As the average number of strikeouts increase so do the average number of homeruns.

-- Question 4
SELECT (NAMEFIRST || ' ' || NAMELAST) AS NAME,
	SB AS STOLEN_BASES,
	CS AS STOLEN_ATTEMPTS,
	ROUND((SB * 100.00) / (SB + CS), 2) AS STOLEN_BASE_PERCENTAGE
FROM BATTING
INNER JOIN PEOPLE USING (PLAYERID)
WHERE SB + CS >= 20
	AND YEARID = 2016
ORDER BY STOLEN_BASE_PERCENTAGE DESC;
-- Answer: Chris Owings had the most success stealing bases in 2016.

-- Question 5
SELECT * 
FROM TEAMS



