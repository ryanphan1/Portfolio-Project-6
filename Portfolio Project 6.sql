SELECT *
FROM [Portfolio Project 6].[dbo].[RaysPitchingStats]
SELECT *
FROM [Portfolio Project 6].[dbo].[LastPitchRays]

--Question 1 AVG Pitches Per at Bat Analysis

--1a AVG Pitches Per At Bat (LastPitchRays)

SELECT avg(pitch_number) as avg_num_of_pitches
FROM [Portfolio Project 6].[dbo].[LastPitchRays]

--1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union

SELECT 
	'Home' as type_of_game,
	avg(pitch_number) as avg_num_of_pitches
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
WHERE home_team = 'TB'
UNION
SELECT 
	'Away' as type_of_game,
	avg(pitch_number) as avg_num_of_pitches
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
WHERE away_team = 'TB'

--1c AVG Pitches Per At Bat Lefty Vs Righty  -> Case Statement 

SELECT 
	avg(Case when batter_position = 'L' Then pitch_number end) as Lefty_at_bats,
	avg(Case when batter_position = 'R' Then pitch_number end) as Righty_at_bats
FROM [Portfolio Project 6].[dbo].[LastPitchRays]

--1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team -> Partition By

SELECT DISTINCT
	home_team,
	Pitcher_position,
	AVG(Pitch_number) OVER (Partition by home_team, Pitcher_position)
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
Where away_team = 'TB'

--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending (LastPitchRays + RaysPitchingStats)

SELECT 
	RPS.Name, 
	AVG(1.00 * Pitch_number) AS AVGPitches
FROM [Portfolio Project 6].[dbo].[LastPitchRays] LPR
JOIN [Portfolio Project 6].[dbo].[RaysPitchingStats] RPS 
	ON RPS.pitcher_id = LPR.pitcher
WHERE IP >= 20
group by RPS.Name
order by AVGPitches DESC

--Question 2 Last Pitch Analysis

--2a Count of the Last Pitches Thrown in Desc Order (LastPitchRays)

SELECT pitch_name, COUNT(*) as last_pitches
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
GROUP BY pitch_name
ORDER BY last_pitches desc

--2b Count of the different last pitches Fastball or Offspeed (LastPitchRays)

SELECT
	sum(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) Fastball,
	sum(case when pitch_name NOT in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) Offspeed
FROM [Portfolio Project 6].[dbo].[LastPitchRays]

--2c Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)


--2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher (LastPitchRays + RaysPitchingStats)
WITH TABLE1 AS(
SELECT 
	RPS.POS,
	LPR.pitch_name, 
	COUNT(LPR.PITCH_NAME) AS number_of_pitches,
	RANK() OVER (Partition by rps.POS order by lpr.pitch_name) PitchRank
FROM [Portfolio Project 6].[dbo].[RaysPitchingStats] RPS
JOIN [Portfolio Project 6].[dbo].[LastPitchRays] LPR
	ON RPS.pitcher_id = LPR.pitcher
GROUP BY RPS.POS, LPR.PITCH_NAME
)
SELECT *
FROM TABLE1
WHERE TABLE1.PitchRank < 6

--Question 3 Homerun analysis

--3a What pitchers have given up the most HRs (LastPitchRays) 

SELECT player_name, count(events) as HRS_given
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
WHERE events = 'home_run'
GROUP BY player_name, events
ORDER BY HRS_given desc

--3b Show HRs given up by zone and pitch, show top 5 most common

SELECT TOP 5 pitch_name, zone, count(events) as HRS_given
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
WHERE events = 'home_run'
GROUP BY zone, pitch_name, events
ORDER BY HRS_given desc

--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher

SELECT RPS.POS, LPR.balls,lpr.strikes, count(*) HRs
FROM [Portfolio Project 6].[dbo].[LastPitchRays] LPR
JOIN [Portfolio Project 6].[dbo].[RaysPitchingStats] RPS 
	ON RPS.pitcher_id = LPR.pitcher
where events = 'home_run'
group by RPS.POS, LPR.balls,lpr.strikes
order by count(*) desc

--3d Show different balls/strikes as well as frequency when someone is on base 
SELECT balls, strikes, count(*) frequency
FROM [Portfolio Project 6].[dbo].[LastPitchRays]
WHERE (on_3b is NOT NULL or on_2b is NOT NULL or on_1b is NOT NULL)
and player_name = 'McClanahan, Shane'
group by balls, strikes
order by count(*) desc
