RENAME TABLE `abd_results`.`all-states-history` TO `abd_results`.`covid`;
SHOW TABLES IN `abd_results`;

SELECT * FROM abd_results.covid;

-- practicing everthing learned so far:
SELECT * 
FROM abd_results.covid WHERE state="OH"; -- filter and records from OH

SELECT SUM(deathConfirmed) 
FROM abd_results.covid WHERE state="OH";

-- 1. How many total records are in the dataset?
SELECT COUNT(*) 
FROM abd_results.covid; -- 19858

-- 2. How many unique states are there?
SELECT COUNT(DISTINCT state) -- print out unique states 
FROM abd_results.covid; -- 56

-- 3. Show all data for California (CA) ordered by date descending.
SELECT * 
FROM abd_results.covid WHERE state="CA"
ORDER BY date;

-- total number of death in OH:
SELECT COUNT(*)
FROM abd_results.covid WHERE state = "OH"; -- 353

-- 4. What are the earliest and latest dates in the dataset?
SELECT MIN(date)
FROM abd_results.covid; -- 2020-02-26

-- 5. Show all columns but only for records where deathIncrease > 500.
SELECT * 
FROM abd_results.covid WHERE deathIncrease > 500;

-- 6. What is the total deathIncrease for each state?
SELECT state, SUM(deathIncrease) AS total_deaths -- grab the state column + add up all values in the deathIncrease column + rename that sum as total_deaths
FROM abd_results.covid
GROUP BY state
ORDER BY total_deaths DESC; -- like cooking order, get sth from a fridge and then do sth with it.

-- 7. What is the average hospitalizedCurrently per state?
SELECT state, AVG(hospitalizedCurrently) as avg_hos_state
FROM abd_results.covid
GROUP BY state
ORDER BY avg_hos_state DESC;

-- 8. How many records exist per state?
SELECT state, COUNT(*) as count_state
FROM abd_results.covid
GROUP BY state
ORDER BY count_state; -- Ascending order instead 

-- 9. What is the total deathIncrease nationwide for each month?
SELECT 
LEFT(date, 7) as month, -- left - take the first 7 words in date AND take sum of deathIncrease
SUM(deathIncrease) as death
FROM abd_results.covid
GROUP BY month
ORDER BY death;

-- 10. Which states never reported any hospitalization data (NULL)?
SELECT state 
FROM abd_results.covid 
WHERE hospitalized IS NULL 
AND hospitalizedCumulative IS NULL
AND hospitalizedCurrently IS NULL
AND hospitalizedIncrease IS NULL;

-- 11. Find records where deathIncrease was negative (data corrections).
SELECT * 
FROM abd_results.covid 
WHERE deathIncrease < 0;

-- 12. Show all data for NY and CA side by side for January 2021.
SELECT *
FROM abd_results.covid 
WHERE state IN ("CA", "NY") AND DATE LIKE "2021-01%"
ORDER BY state, date;

-- 13. Which states had more than 1,000 deaths in a single day?
SELECT * 
FROM abd_results.covid 
WHERE death > 1000 
ORDER BY date;

-- 14. Rank states by total deaths — who had the most?
SELECT state, SUM(death) AS death_total
FROM abd_results.covid
GROUP BY state
ORDER BY death_total DESC;

-- 15. Calculate the 7-day rolling average of deathIncrease for Texas.
SELECT 
date,
deathIncrease,
state,
AVG(deathIncrease) OVER (
PARTITION BY state
ORDER BY date
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7day
FROM abd_results.covid WHERE state="TX"
ORDER BY date;


-- 16. Find the peak hospitalization day for each state.
SELECT state, sum(hospitalized) as sum_hos
FROM abd_results.covid
GROUP BY state
ORDER BY sum_hos DESC;

-- 17. Compare total deaths in Q1 2021 vs Q4 2020 by state.
-- 18. Which state had the highest death rate relative to its peak hospitalizations?

SELECT 
state, 
max(hospitalized) as peak_hospital, 
max(death) as peak_death, 
max(hospitalized)/max(death) as res
FROM abd_results.covid
GROUP BY state
ORDER BY res DESC;

-- 19. What is the total positiveIncrease nationwide?
SELECT sum(positiveIncrease)
FROM abd_results.covid; -- 28751117

-- 20. Find the day each state hit its all-time highest hospitalizedCurrently.
-- step 1: find peak values of hospitalizedCurrrently per state:
CREATE TEMPORARY TABLE peak_hos_df AS 
SELECT state,
MAX(hospitalizedCurrently) AS max_hos
FROM abd_results.covid
GROUP BY state
ORDER BY max_hos DESC;

-- step 2: merged into the date of those peak:
SELECT * FROM peak_hos_df;
SELECT abd_results.covid.state,
abd_results.covid.date
FROM abd_results.covid
INNER JOIN peak_hos_df
ON abd_results.covid.state = peak_hos_df.state
AND abd_results.covid.hospitalizedCurrently = peak_hos_df.max_hos;

-- OR a way to combine step 1 and step 2 into a big aggregated query - to wrap step 1 inside INNER JOIN of step 2:
SELECT c.state, c.date,
c.hospitalizedCurrently -- c is alias of abd_results.covid
FROM abd_results.covid c
INNER JOIN ( -- creating peak_hos_df step goes in here
  SELECT state, 
  MAX(hospitalizedCurrently) AS max_hos
  FROM abd_results.covid
  GROUP BY state 
) AS peak
ON c.state = peak.state
AND c.hospitalizedCurrently = peak.max_hos
ORDER BY peak.max_hos DESC;

-- 21. How many records does each state have?
SELECT 
DISTINCT state,
COUNT(*) as cstate
FROM abd_results.covid
GROUP BY state
ORDER BY cstate;

-- 20. Calculate week-over-week change in hospitalizations per state.
-- Which 5 states had the steepest increase in deaths over any 7-day window?
-- Find states where death data was revised downward (cumulative deaths decreased day over day).
-- Build a summary table: total deaths, peak single-day deaths, peak hospitalizations, and date of peak for every state.
-- Calculate the 7-day rolling average of deathIncrease for California.
-- Rank all states by total deaths using RANK().
-- Find the peak hospitalizedCurrently day for each state.
-- Compare total deaths between 2020 and 2021 for each state.


-- Which state recovered fastest (biggest drop in hospitalizedCurrently over 30 days)?
-- Calculate the death rate as SUM(deathIncrease) / COUNT(date) per state.

SELECT 
state, 
SUM(deathIncrease) as sum_death, 
COUNT(date) as count_date,
SUM(deathIncrease)/COUNT(date) as death_sum_per_day
FROM abd_results.covid
GROUP BY state
ORDER BY death_sum_per_day DESC;

-- Find the first date each state reported a death.
DESCRIBE abd_results.covid;

SELECT MIN(date) AS first_date,
state,
COUNT(death) AS count_death -- When you use GROUP BY, SQL collapses multiple rows into one row per group. For every column you SELECT, SQL needs to know: "Which single value should I show for this group?
FROM abd_results.covid
GROUP BY state
ORDER BY first_date;

-- Which states had a second wave (hospitalizations dropped then rose again above the first peak)?
-- Show the top 3 deadliest months for each state.
-- Find the 7-day period with the highest nationwide deaths.
-- Using a CTE, calculate each state's % share of total nationwide deaths.
-- Find states where deaths were undercounted (probable deaths > confirmed deaths).
-- Using a window function, show each state's cumulative deaths over time.
-- Calculate week-over-week % change in hospitalizations per state.
-- Find the correlation between hospitalizedCurrently and deathIncrease by state.

-- Using LEAD() or LAG(), find the day-over-day change in death for each state.
-- Build a pivot table showing total deaths per state per quarter.
-- Find states where the 7-day average of deaths never exceeded 10.
-- Identify the top 5 states with the most volatile deathIncrease (highest standard deviation).

SELECT
state,
STDDEV_SAMP(deathIncrease) AS avg_death_incre
FROM abd_results.covid
GROUP BY state
ORDER BY avg_death_incre DESC
LIMIT 5;

-- Write a query that flags potential data errors — negative increases, cumulative drops, or ICU > hospitalized.
SELECT * 
FROM abd_results.covid 
WHERE deathIncrease < 0 OR inIcuCumulative < 0 OR inIcuCumulative > hospitalizedCumulative; 

-- Print out all the colnames:
DESCRIBE abd_results.covid;

-- What is the average daily deathIncrease per state?
SELECT 
state,
AVG(deathIncrease) as avg_death
FROM abd_results.covid
GROUP BY state
ORDER BY avg_death DESC;

-- Which state had the highest total hospitalizedCumulative?
SELECT 
state,
MAX(hospitalizedCumulative) as max_res
FROM abd_results.covid
GROUP BY state
ORDER BY max_res DESC
LIMIT 1;

-- What is the total deathIncrease for just the year 2020?
SELECT
SUM(deathIncrease)
FROM abd_results.covid WHERE LEFT(date, 4)='2020'; -- 336783

-- Which month across all years had the most deaths nationwide?
-- What is the max single-day deathIncrease for each state?
-- How many days did each state report data?
-- Which state had the lowest average hospitalizedCurrently?
SELECT state,
AVG(hospitalizedCurrently) as mu_hos
FROM abd_results.covid 
GROUP BY state
ORDER BY mu_hos ASC;

-- What is the total deaths for Q1 (Jan–Mar) across all years?
-- Find the average deathIncrease per day of the week (Mon, Tue…).
-- How many states reported more than 10,000 total deaths?
CREATE TEMPORARY TABLE high_death_states AS -- add this as beginning assign everything as a var
SELECT
state,
SUM(death) as s_death
FROM abd_results.covid 
GROUP BY state
HAVING s_death > 10000; -- having is like WHERE but use after group by on groups and along with sum, max, min, avg, etc..

SELECT COUNT(*)
FROM high_death_states; -- then count num of row = number of states

SELECT * FROM high_death_states;

-- Find all days where hospitalizedCurrently dropped by more than 1,000 from the previous day (use self-join or subquery).
-- Which states had zero deaths recorded for an entire month?
-- Find records where cumulative death decreased day over day (data corrections).
-- Show all records from winter months (Dec, Jan, Feb) only.
SELECT * FROM abd_results.covid;

CREATE TEMPORARY TABLE temp AS
SELECT *
FROM abd_results.covid
WHERE date LIKE '2021-12%'
   OR date LIKE '2021-01%'
   OR date LIKE '2021-02%';

SELECT * FROM temp;

-- FROM temp
-- WHERE date LIKE ""

-- Find states where deathIncrease was above their own average more than 50 times.
-- Which states reported hospitalization data for every single day in the dataset?
-- Find the top 5 deadliest days nationwide.
SELECT date, MAX(death) AS max_death
FROM abd_results.covid
GROUP BY date
ORDER BY max_death DESC
LIMIT 5;

-- Show all records where inIcuCurrently exceeded hospitalizedCurrently (data anomalies).
SELECT hospitalizedCurrently, inIcuCurrently
FROM abd_results.covid
WHERE hospitalizedCurrently > inIcuCurrently;

-- Show all state where inIcuCurrently exceeded hospitalizedCurrently (data anomalies)
SELECT state,
hospitalizedCurrently,
inIcuCurrently
FROM abd_results.covid WHERE hospitalizedCurrently > inIcuCurrently;

-- Find states that had at least one day with 0 hospitalizations but nonzero deaths.
SELECT state, hospitalized, deathConfirmed
FROM abd_results.covid 
WHERE hospitalized = 0 AND
      deathConfirmed > 0;

-- Which states have complete data (no NULLs) across all columns? 
SELECT state
FROM abd_results.covid 
GROUP BY state
HAVING SUM(deathConfirmed IS NULL) = 0 AND
       SUM(hospitalized IS NULL) = 0 AND
       SUM(hospitalizedCumulative IS NULL) = 0 AND
       SUM(inIcuCumulative IS NULL) = 0;
       
-- split the dataset into 3 different datasets:
-- df 1: test-related
CREATE TEMPORARY TABLE daily_stats AS
SELECT
date,
state, 
deathIncrease,
positiveIncrease,
hospitalizedCurrently
FROM abd_results.covid;


-- df 2: hospital-data
CREATE TEMPORARY TABLE hospital_data AS
SELECT
date,
state,
hospitalized,
inIcuCurrently,
onVentilatorCurrently
FROM abd_results.covid;

-- df 3: population-based:
CREATE TABLE population (
state VARCHAR(5) PRIMARY KEY,
region VARCHAR(50)
);

INSERT INTO population VALUES
('CA', 'West'), ('NY', 'Northeast'), ('TX', 'South'),
('FL', 'South'), ('OH', 'Midwest'), ('IL', 'Midwest'),
('PA', 'Northeast'), ('GA', 'South'), ('NC', 'South'),
('MI', 'Midwest'), ('AZ', 'West'), ('WA', 'West'),
('MA', 'Northeast'), ('NJ', 'Northeast'), ('TN', 'South'),
('MN', 'Midwest'), ('CO', 'West'), ('AL', 'South'),
('LA', 'South'), ('OR', 'West');

DESCRIBE population;
SELECT * FROM population;

-- INNER JOIN
-- 1. Show daily stats only for states that have hospital data on the same date
SELECT * FROM hospital_data;
SELECT * FROM daily_stats;

SELECT hospital_data.date, hospital_data.state
FROM hospital_data
INNER JOIN daily_stats
ON hospital_data.date = daily_stats.date
AND hospital_data.state = daily_stats.state;

-- 2. Find days where both daily_stats and hospital_data reported data for CA.
SELECT hospital_data.date, hospital_data.state
FROM hospital_data
INNER JOIN daily_stats
ON hospital_data.date = daily_stats.date
WHERE hospital_data.state = "CA";

-- 3. Show state region alongside their total deaths.
SELECT 
abd_results.covid.death,
abd_results.covid.state
FROM abd_results.covid
INNER JOIN population
ON abd_results.covid.state = population.state;

-- 4. Which states in the South region had the highest positiveIncrease?
SELECT 
population.state
FROM population
INNER JOIN daily_stats
ON population.state = daily_stats.state
WHERE population.region = 'South'
ORDER BY daily_stats.positiveIncrease DESC;

SELECT p.state, -- p = population --> select state in population
SUM(d.positiveIncrease) AS pos_inc -- d = daily_stats 
FROM population p        -- define p here
INNER JOIN daily_stats d -- define d here 
ON p.state = d.state
WHERE p.region = 'South'
GROUP BY p.state
ORDER BY pos_inc DESC;

-- 5. Join daily_stats and hospital_data — show dates where ICU was above 500.
SELECT * FROM daily_stats;
SELECT * FROM hospital_data; -- icu is here

SELECT d.date, -- d = daily_stats
SUM(h.inIcuCurrently) AS icu_sum -- h = hospital_data
FROM daily_stats d
INNER JOIN hospital_data h
ON d.date = h.date
GROUP BY d.date
HAVING icu_sum > 500;

SELECT daily_stats.date
FROM daily_stats
INNER JOIN hospital_data
ON daily_stats.date = hospital_data.date
WHERE inIcuCurrently > 500;

-- 1. Show total deathIncrease for each region (not state).
--    Hint: JOIN states + daily_stats, GROUP BY region
SELECT * FROM daily_stats;
SELECT * FROM population;
SELECT * FROM hospital_data;

SELECT SUM(d.deathIncrease) AS sum_death,
p.region             -- d is alias of daily_stats
FROM daily_stats d
INNER JOIN population p
ON d.state = p.state
GROUP BY p.region
ORDER BY sum_death;

-- 2. Find all dates where Southern states had more than 1000 positiveIncrease.
SELECT 
d.date, -- d = daily_stats
p.state, -- p = population
d.positiveIncrease 
FROM daily_stats d
INNER JOIN population p 
ON d.state = p.state
WHERE p.region = "South" AND d.positiveIncrease > 1000;

-- 3. Show the peak inIcuCurrently for each state along with its region.
SELECT * FROM hospital_data; -- it does have state

SELECT 
MAX(h.inIcuCurrently) AS peak_icu, -- h = hospital_data
p.region                           -- p = population
FROM hospital_data h
INNER JOIN population p
ON h.state = p.state
GROUP BY p.state
ORDER BY peak_icu DESC;


-- 4. Find dates where both positiveIncrease > 500 AND inIcuCurrently > 100 
SELECT d.positiveIncrease, -- d = daily.stats
d.date,
h.inIcuCurrently 
FROM daily_stats d
INNER JOIN hospital_data h
WHERE d.positiveIncrease > 500 
AND h.inIcuCurrently >100;

-- 5. Which region had the highest average hospitalizedCurrently?
SELECT p.region,                       
AVG(h.hospitalized) AS avg_hos 
FROM hospital_data h                   
INNER JOIN population p                 
ON h.state = p.state                    
GROUP BY p.region                      
ORDER BY avg_hos;                       

-- LEFT JOIN
-- 6. Show all states from daily_stats and their hospital data — include states even if hospital data is missing.
-- left join daily_stats and hospital_data
SELECT DISTINCT d.state,
d.date,
h.hospitalized,
h.inIcuCurrently,
h.onVentilatorCurrently
FROM daily_stats d
LEFT JOIN hospital_data h
ON d.state = h.state
AND h.state = d.state;

-- 7. Find states that have daily stats but NO hospital data at all.
SELECT DISTINCT d.state,
h.date,
h.hospitalized,
h.inIcuCurrently,
h.onVentilatorCurrently
FROM daily_stats d
LEFT JOIN hospital_data h
ON d.state = h.state 
WHERE h.state IS NULL;

-- 8. Show all dates for TX with hospital data if it exists, NULL if not.
-- left join daily stats with hospital data
SELECT d.date,
d.state,
h.hospitalized,
h.inIcuCurrently,
h.onVentilatorCurrently
FROM daily_stats d
LEFT JOIN hospital_data h
ON d.state = h.state
AND h.date = d.date
WHERE d.state = "TX" 
ORDER BY d.date DESC;

-- 9. Which states have population data but never reported ICU numbers?
-- left join population with hospital_data (inIcuCurrently IS NULL)
SELECT * FROM population;
SELECT DISTINCT p.state,
p.region,
h.inIcuCurrently
FROM population p
LEFT JOIN hospital_data h
ON p.state = h.state
WHERE h.inIcuCurrently IS NULL; 

-- 10. Show all daily stats with region info — keep rows even if region is unknown.
-- left join daily_stats with population (region + state):
SELECT d.state,
d.state,
d.deathIncrease,
d.positiveIncrease,
d.hospitalizedCurrently,
p.region
FROM daily_stats d
LEFT JOIN population p
ON d.state = p.state;

-- RIGHT JOIN
-- 11. Show all hospital records and match daily stats where available.
-- right join hospital with daily_stats (hospital at the right)

SELECT d.date,
d.state, 
d.deathIncrease,
d.positiveIncrease,
d.hospitalizedCurrently,
h.hospitalized,
h.inIcuCurrently,
h.onVentilatorCurrently
FROM daily_stats d
RIGHT JOIN hospital_data h
ON d.state = h.state
AND d.date = h.date;

-- 12. Find dates that exist in hospital_data but not in daily_stats.
-- hospital_data on the right:
SELECT h.date
FROM daily_stats d
RIGHT JOIN hospital_data h
ON d.date = h.date
WHERE d.state = 0 OR d.state IS NULL;

-- 13. Show all states from the states table even if they never reported deaths.
-- population at the right, daily_stats deathIncrease
SELECT DISTINCT p.state, 
SUM(d.deathIncrease) AS sum_death
FROM daily_stats d
RIGHT JOIN population p
ON d.state = p.state
GROUP BY p.state
ORDER BY sum_death DESC;

-- 14. Which states have population data but zero daily stats records?
-- population data on the right
DESCRIBE daily_stats;
DESCRIBE hospital_data;

SELECT DISTINCT p.state,
d.date,
d.deathIncrease,
d.positiveIncrease,
d.hospitalizedCurrently
FROM daily_stats d
RIGHT JOIN population p
ON d.state = p.state
WHERE d.deathIncrease = 0 OR 
d.positiveIncrease = 0 OR 
d.hospitalizedCurrently = 0;

-- 15. Show all ICU data with matching death data — keep ICU rows even without death data.
-- icu (hospital_data) at the right, death data (daily_stats)
SELECT d.deathIncrease,
h.inIcuCurrently
FROM daily_stats d
RIGHT JOIN hospital_data h
ON d.state = h.state
ORDER BY d.deathIncrease DESC;

-- SELF JOIN
-- 16. Find dates where CA had higher positiveIncrease than NY on the same day.
DESCRIBE daily_stats;

CREATE TEMPORARY TABLE temp_daily_stats AS -- might use this moving forward for selfjoin, just 
SELECT deathIncrease, date, state
FROM daily_stats;

SELECT 
  a.deathIncrease AS death_increase_ca,
  b.deathIncrease AS death_increase_ny,
  a.date
FROM temp_daily_stats a
JOIN daily_stats b
  ON a.date = b.date
WHERE a.state = 'CA'
  AND b.state = 'NY'
  AND a.deathIncrease > b.deathIncrease
ORDER BY a.date;

-- 17. Find all states that had more deaths than CA on any given day.
DESCRIBE temp_daily_stats; -- this will be a

SELECT b.state,
b.deathIncrease
FROM daily_stats b
JOIN temp_daily_stats a
ON a.date = b.date
WHERE a.state = "CA" AND
a.deathIncrease < b.deathIncrease
ORDER BY b.deathIncrease DESC;

-- 18. Compare each state's hospitalizedCurrently to the national average on the same date.
DESCRIBE hospital_data;
SELECT * FROM temp_hospital;

CREATE TEMPORARY TABLE temp_hospital AS 
SELECT AVG(hospitalized) AS nation_avg_hospitalized, date
FROM abd_results.covid
GROUP BY date;

CREATE TEMPORARY TABLE avg_state AS
SELECT MAX(date) AS max_day,
AVG(hospitalized) AS avg_hos_state,
state
FROM hospital_data
GROUP BY state
ORDER BY avg_hos_state;

SELECT 
a.max_day,
a.state,
a.avg_hos_state,
b.nation_avg_hospitalized
FROM avg_state a
JOIN temp_hospital b
ON a.max_day = b.date;

-- 19. Find days where a state's deathIncrease was higher than the previous day.

-- 20. Which states always had fewer ICU patients than their total hospitalized on every single day?



