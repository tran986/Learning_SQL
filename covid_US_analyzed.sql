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
CREATE TABLE daily_stats AS
SELECT
date,
state, 
deathIncrease,
positiveIncrease,
hospitalizedCurrently
FROM abd_results.covid;


-- df 2: hospital-data
CREATE TABLE hospital_data AS
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
-- step 1: group by state, find total hospitalized on every single day?
CREATE TABLE hospital_info AS
SELECT state,
SUM(hospitalized) AS total_hos,
date
FROM hospital_data
GROUP BY state, date;

-- step 2: group by state, find total ICU patients on every single day?
CREATE TEMPORARY TABLE icu_info AS
SELECT state,
date,
SUM(inIcuCurrently) AS total_icu
FROM hospital_data
GROUP BY state, date;


-- step 3: merge 2 pieces of info:
SELECT * FROM icu_info;
SELECT * FROM hospital_info;

SELECT i.total_icu,
i.date,
h.total_hos,
i.state
FROM icu_info i
JOIN hospital_info h
ON i.state = h.state AND
i.date = h.date
WHERE i.total_icu < h.total_hos;

-- ============================================
-- UNION (removes duplicates)
-- ============================================
-- 1. Show all unique states from both daily_stats and hospital_data combined.
SELECT state FROM daily_stats
UNION 
SELECT state from hospital_data;

-- 2. Show states from daily_stats where totalTestResultsIncrease > 10000
SELECT * FROM daily_stats;
DESCRIBE abd_results.covid;

SELECT state, SUM(positiveIncrease) AS total_res_increase
FROM abd_results.covid
GROUP BY state
UNION
SELECT state, SUM(positiveIncrease) AS total_res_increase 
FROM daily_stats 
GROUP BY state
HAVING total_res_increase > 1000
ORDER BY total_res_increase DESC; -- number of columns of 2 tables before UNION have to be the same
 
--    UNION states from hospital_data where inIcuCurrently > 500.
SELECT * FROM hospital_data;

SELECT state, SUM(inIcuCurrently) AS sum_icu
FROM hospital_data
GROUP BY state
UNION
SELECT state, SUM(inIcuCurrently) AS sum_icu
FROM abd_results.covid
GROUP BY state 
HAVING sum_icu > 500;

-- 3. Create a combined list of dates from daily_stats and hospital_data with no duplicates.
SELECT date FROM hospital_data
UNION 
SELECT date
FROM daily_stats;

-- 4. Show states with total deathIncrease > 5000 from daily_stats
--    UNION states with peak inIcuCurrently > 1000 from hospital_data.
SELECT * FROM daily_stats;
SELECT * FROM hospital_data;

SELECT state
FROM daily_stats
GROUP BY state
HAVING SUM(deathIncrease) > 5000
UNION 
SELECT state
FROM hospital_data
GROUP BY state
HAVING MAX(inIcuCurrently) > 1000;

-- 5. UNION daily_stats and hospital_data — show only state and date from both tables.
SELECT state, date
FROM daily_stats
UNION
SELECT state, date
FROM hospital_data;

-- ============================================
-- UNION ALL (keeps duplicates)
-- ============================================

-- 6. Show all states from both daily_stats and hospital_data including duplicates.
--    How many more rows does UNION ALL return vs UNION?
CREATE TEMPORARY TABLE union_all_state AS
SELECT state FROM daily_stats
UNION ALL 
SELECT state FROM hospital_data;

CREATE TEMPORARY TABLE union_state AS
SELECT state FROM daily_stats
UNION 
SELECT state FROM hospital_data;

SELECT COUNT(*) FROM union_all_state;
SELECT COUNT(*) FROM union_state;

DROP TABLE union_all_state;
DROP TABLE union_state;

-- 7. Combine deathIncrease from daily_stats and hospitalizedIncrease from hospital_data
--    into one column called "daily_increase" using UNION ALL.

SELECT deathIncrease AS daily_increase
FROM daily_stats
UNION ALL
SELECT hospitalized AS daily_increase 
FROM hospital_data
ORDER BY daily_increase DESC;

-- 8. Stack all CA rows from daily_stats on top of all CA rows from hospital_data using UNION ALL.
SELECT state 
FROM daily_stats WHERE state = "CA"
UNION ALL 
SELECT state
FROM hospital_data WHERE state = "CA";

-- 9. Use UNION ALL to count total records across both daily_stats and hospital_data combined.
CREATE TEMPORARY TABLE total_record AS
SELECT state, date 
FROM daily_stats
UNION ALL
SELECT state, date
FROM hospital_data;

SELECT COUNT(*) FROM total_record; -- 39716
DROP TABLE total_record;

-- ============================================
-- HAVING
-- ============================================

-- 11. Find states where average deathIncrease was more than 30 per day.
SELECT state, AVG(deathIncrease) AS avg_death, date
FROM abd_results.covid
GROUP BY state, date
HAVING avg_death > 30;

-- 12. Which states reported more than 300 days of data?
SELECT state, COUNT(date) AS date_count
FROM abd_results.covid
GROUP BY state
HAVING date_count > 300; -- 22 states

-- 13. Find regions where total positiveIncrease exceeded 2,000,000.
SELECT * FROM population;
SELECT * FROM daily_stats;

SELECT SUM(d.positiveIncrease) AS total_increase,
p.region
FROM daily_stats d
LEFT JOIN population p
ON d.state = p.state
GROUP BY p.region
HAVING total_increase > 200000;

--     Hint: JOIN states + daily_stats, GROUP BY region, HAVING SUM
-- 14. Which states had MAX inIcuCurrently above 2000?
SELECT * FROM hospital_data;
SELECT state, MAX(inIcuCurrently) as max_icu
FROM hospital_data
GROUP BY state
HAVING max_icu > 900
ORDER BY max_icu DESC;

-- 15. Find states where SUM(deathIncrease) was more than 3x their SUM(hospitalizedIncrease).
SELECT state,
SUM(deathIncrease) AS sum_death,
SUM(hospitalizedIncrease) AS sum_hos
FROM abd_results.covid
GROUP BY state
HAVING sum_death > 3*sum_hos;

-- ============================================
-- EXISTS
-- ============================================

-- 16. Find all states in daily_stats that also exist in hospital_data.
--     Hint: SELECT state FROM daily_stats WHERE EXISTS (SELECT 1 FROM hospital_data WHERE...)
SELECT state
FROM daily_stats
WHERE EXISTS (
  SELECT state
  FROM hospital_data
  WHERE daily_stats.state = hospital_data.state
);

-- 17. Find states in daily_stats where there EXISTS at least one day with deathIncrease > 500.
SELECT DISTINCT state
FROM daily_stats
WHERE EXISTS (
  SELECT state,
  deathIncrease
  FROM abd_results.covid
  WHERE daily_stats.state = abd_results.covid.state AND daily_stats.deathIncrease > 500
);

-- another way to do it using JOIN:
SELECT DISTINCT d.state,
a.deathIncrease
FROM daily_stats d
LEFT JOIN abd_results.covid a
ON d.state = a.state
WHERE a.deathIncrease > 0;

-- 18. Find all dates in daily_stats where there EXISTS a matching record in hospital_data
--     with inIcuCurrently > 1000.
SELECT DISTINCT date
FROM daily_stats
WHERE EXISTS (
  SELECT date, inIcuCurrently
  FROM hospital_data 
  WHERE daily_stats.date = hospital_data.date AND hospital_data.inIcuCurrently > 2000
);

-- another way to do it using join:
SELECT DISTINCT d.date, 
h.inIcuCurrently
FROM daily_stats d
LEFT JOIN hospital_data h
ON d.date = h.date
WHERE h.inIcuCurrently > 2000
ORDER BY h.inIcuCurrently DESC;

-- 19. Find states in the states table that EXISTS in daily_stats with total deaths > 10000.
SELECT * FROM abd_results.covid;

SELECT DISTINCT state
FROM daily_stats
WHERE EXISTS (
  SELECT SUM(death) as sum_death
  FROM abd_results.covid
  GROUP BY state
  HAVING sum_death > 10000
);

-- using join:
SELECT d.state,
SUM(a.death) AS sum_death
FROM daily_stats d
LEFT JOIN abd_results.covid a
ON d.state = a.state
GROUP BY d.state
HAVING sum_death >10000;

-- 20. Find states where EXISTS a day with both positiveIncrease > 5000
--     AND deathIncrease > 100 on the same date.

SELECT DISTINCT state
FROM hospital_data
WHERE EXISTS (
 SELECT date
 FROM daily_stats
 WHERE daily_stats.positiveIncrease > 100 AND positiveIncrease > 5000
);

-- using join:
SELECT DISTINCT d.state
FROM daily_stats d
RIGHT JOIN  hospital_data h
ON d.state = h.state
WHERE d.positiveIncrease > 100 AND d.positiveIncrease > 5000;

-- ============================================
-- ANY / ALL
-- ============================================
-- 21. Find states where deathIncrease was greater than ANY single day in California.
--     (greater than CA's minimum daily death)

SELECT DISTINCT state
FROM abd_results.covid
WHERE deathIncrease > ANY (
  SELECT MIN(deathIncrease)
  FROM daily_stats
  WHERE state = "CA"
  GROUP BY date
);

-- 22. Find states where average deathIncrease was greater than ALL states in the Northeast.
--     Hint: AVG(deathIncrease) > ALL (SELECT AVG... WHERE region = 'Northeast')
SELECT state, AVG(deathIncrease)
FROM abd_results.covid
GROUP BY state
HAVING AVG(deathIncrease) > ALL (
  SELECT AVG(a.deathIncrease) 
  FROM population p
  INNER JOIN abd_results.covid a
  ON p.state = a.state
  WHERE p.region = "Northeast"
  GROUP BY p.state
);

-- 23. Find dates where NY's positiveIncrease was greater than ANY day recorded by FL.
SELECT positiveIncrease, date
FROM abd_results.covid 
WHERE state = "NY" AND 
positiveIncrease > ANY (
  SELECT SUM(positiveIncrease)
  FROM daily_stats
  WHERE state = "FL"
  GROUP BY date);

-- 24. Find states where MAX(hospitalizedIncrease) is less than ALL values recorded by TX.

SELECT state,
MAX(hospitalizedIncrease)
FROM abd_results.covid
GROUP BY state 
HAVING MAX(hospitalizedIncrease) < ALL (
SELECT hospitalizedIncrease
FROM abd_results.covid
WHERE state = "TX"
);

-- 25. Find states where every single day's deathIncrease was greater than ALL days in Alaska (AK).

SELECT DISTINCT state
FROM abd_results.covid
WHERE state != "AK"
GROUP BY state
HAVING MIN(deathIncrease) > ALL(
SELECT MAX(deathIncrease)
FROM abd_results.covid
WHERE state = "AK"
GROUP BY date);

-- ============================================
-- INSERT INTO SELECT / SELECT INTO
-- ============================================
-- 26. Create a new table called "south_states_stats" containing all daily_stats
--     for Southern states only.
--     Hint: CREATE TABLE south_states_stats AS SELECT ... JOIN ... WHERE region = 'South'
CREATE TABLE south_states_stats AS
SELECT d.* 
FROM daily_stats d
LEFT JOIN population p
ON d.state = p.state
WHERE p.region = "South";

DROP TABLE south_states_stats;

-- 27. Insert into a new table "high_death_days" all rows from daily_stats
--     where deathIncrease > 500.
CREATE TABLE high_death_days AS
SELECT *
FROM daily_stats
WHERE deathIncrease > 500; 

DROP TABLE high_death_days;

-- 28. Create a summary table called "state_summary" with columns:
--     state, total_deaths, avg_daily_deaths, peak_deaths, total_positive.
--     Hint: CREATE TABLE state_summary AS SELECT ... GROUP BY state

CREATE TABLE state_summary AS
SELECT state,
MAX(death) AS peak_death,
SUM(death) AS total_deaths,
SUM(positive) AS total_positive,
AVG(death) AS avg_daily_deaths
FROM abd_results.covid
GROUP BY state;

SELECT * FROM state_summary;
DROP TABLE state_summary;

-- 29. Create a new table "icu_peaks" containing each state and their peak inIcuCurrently date.
--     Hint: use the subquery + JOIN pattern we practiced earlier
-- find max_icu --> merge to their date --> make a new table out of it:
CREATE TABLE icu_peaks AS 
SELECT a.date,
i.max_icu,
i.state
FROM abd_results.covid a
RIGHT JOIN (
SELECT state, 
MAX(inIcuCurrently) AS max_icu
FROM abd_results.covid
GROUP BY state
HAVING max(inIcuCurrently) != 0
) i
ON a.inIcuCurrently = i.max_icu;

DROP TABLE icu_peaks;

-- 30. Insert into a new table "monthly_summary" the total deathIncrease and
--     positiveIncrease per state per month.
--     Hint: CREATE TABLE monthly_summary AS SELECT state, LEFT(date,7)... GROUP BY state, month

CREATE TABLE monthly_summary AS
SELECT state,
LEFT(date,7) AS month,
SUM(deathIncrease) AS total_death,
SUM(positiveIncrease) AS total_pos
FROM daily_stats
GROUP BY month, state;

DROP TABLE monthly_summary;

-- ============================================
-- UNION + JOINS
-- ============================================

-- 1. Show a combined list of states and their total deathIncrease from daily_stats
--    UNION states and their peak inIcuCurrently from hospital_data.
--    Only include Southern states.
--    Hint: two separate SELECT + JOIN with states table, UNION them together

-- Option 2:Alternative to union: LOL
SELECT p.state,
a.total_death,
a.max_icu
FROM population p
RIGHT JOIN (SELECT state,
SUM(deathIncrease) AS total_death,
MAX(inIcuCurrently) AS max_icu
FROM abd_results.covid 
GROUP BY state) a
ON a.state = p.state
WHERE p.region = "South";

-- ============================================
-- HAVING + JOINS
-- ============================================

-- 3. JOIN daily_stats and states table, GROUP BY region,
--    find regions where AVG(deathIncrease) > 20
--    AND total positiveIncrease > 1,000,000.
--    Hint: two conditions in HAVING with AND
SELECT
p.region,
AVG(d.deathIncrease) AS avg_death,
SUM(d.positiveIncrease) AS sum_pos
FROM daily_stats d
LEFT JOIN population p
ON d.state = p.state
GROUP BY p.region
HAVING avg_death > 20 AND sum_pos > 1000000;

-- 4. JOIN all 3 tables (daily_stats, hospital_data, states),
--    GROUP BY state, HAVING MAX(inIcuCurrently) > 1000
--    AND SUM(deathIncrease) > 5000.

SELECT MAX(h.inIcuCurrently) AS max_icu,
SUM(d.deathIncrease) AS sum_death
FROM hospital_data h
INNER JOIN daily_stats d
ON h.state = d.state
GROUP BY d.state
HAVING max_icu > 1000 AND
sum_death > 5000;


-- ============================================
-- EXISTS + JOINS
-- ============================================

-- 5. Find all states from the states table WHERE EXISTS
--    a record in daily_stats with deathIncrease > 200
--    AND the state is in the South region.
--    Hint: JOIN inside the EXISTS subquery

SELECT state
FROM population
WHERE EXISTS (
  SELECT deathIncrease 
  FROM daily_stats
  WHERE deathIncrease >200
) AND region = "South";

-- 6. Find all dates in daily_stats WHERE EXISTS a matching row
--    in hospital_data (same state AND date) with inIcuCurrently > 500
--    AND the state is in the Northeast region.
--    Hint: EXISTS subquery + JOIN states table

SELECT date, state
FROM daily_stats
WHERE EXISTS (
  SELECT h.date, h.state
  FROM hospital_data h
  LEFT JOIN population p
  ON h.state = p.state 
  WHERE p.region = "Northeast"  
);


-- ============================================
-- ANY / ALL + JOINS
-- ============================================

-- 7. JOIN daily_stats and states table, find states where
--    SUM(deathIncrease) > ANY (SELECT SUM(deathIncrease) 
--    FROM daily_stats JOIN states WHERE region = 'West' GROUP BY state).
--    Which states had more total deaths than at least one Western state?

SELECT SUM(deathIncrease),
state
FROM daily_stats
GROUP BY state
HAVING SUM(deathIncrease) > ANY (
SELECT
SUM(d.deathIncrease) 
FROM daily_stats d
LEFT JOIN population p
ON p.state = d.state
WHERE p.region = "West"
GROUP BY d.state
);

-- 8. JOIN daily_stats and states, find states where
--    AVG(deathIncrease) > ALL (SELECT AVG(deathIncrease)
--    FROM daily_stats JOIN states WHERE region = 'Northeast' GROUP BY state).
--    Which states beat every single Northeast state in avg daily deaths?

SELECT AVG(deathIncrease),
state
FROM daily_stats
GROUP BY state
HAVING AVG(deathIncrease) > ALL (
SELECT 
AVG(d.deathIncrease)
FROM daily_stats d
LEFT JOIN population p
ON d.state = p.state
WHERE p.region = "Northeast"
GROUP BY d.state)
;

-- ============================================
-- INSERT INTO SELECT + JOINS
-- ============================================

-- 9. Create a new table "region_summary" by joining daily_stats and states,
--    GROUP BY region containing:
--    region, total_deaths, avg_daily_deaths, peak_single_day_deaths, total_positive.
--    Hint: CREATE TABLE region_summary AS SELECT ... JOIN ... GROUP BY region
CREATE TEMPORARY TABLE region_summary AS
SELECT
SUM(d.deathIncrease) AS total_deaths,
SUM(d.positiveIncrease) AS total_positive,
p.region,
AVG(d.deathIncrease) AS avg_daily_death,
MAX(d.deathIncrease) AS peak_single_day_deaths
FROM daily_stats d
LEFT JOIN population p
ON p.state = d.state
GROUP BY p.region;

-- 10. Create a new table "full_summary" by joining ALL 3 tables
--     (daily_stats, hospital_data, states) containing:
--     state, region, total_deaths, peak_icu, avg_hospitalized, total_positive
--     only for states where total_deaths > 10000.

SELECT * FROM daily_stats;
SELECT * FROM hospital_data;
SELECT * FROM population;





--     Hint: JOIN all 3 tables + GROUP BY state, region + HAVING SUM(deathIncrease) > 10000
-- =============================================================
-- 50 Intermediate SQL Questions
-- Dataset: all-states-history (COVID-19 US States)
-- Table name assumed: covid_history
-- Columns: date, state, death, deathConfirmed, deathIncrease,
--   deathProbable, hospitalized, hospitalizedCumulative,
--   hospitalizedCurrently, hospitalizedIncrease, inIcuCumulative,
--   inIcuCurrently, negative, negativeIncrease, onVentilatorCumulative,
--   onVentilatorCurrently, positive, positiveCasesViral,
--   positiveIncrease, recovered, totalTestResults,
--   totalTestResultsIncrease, totalTestsViral, ... (and more)
-- =============================================================


-- =============================================================
-- AGGREGATION
-- =============================================================

-- 1. Find the total number of deaths (death column) for each state,
--    ordered from highest to lowest.


-- 2. How many records exist for each state in the dataset?
--    List only states that have more than 300 records.


-- 3. What is the maximum number of hospitalized patients currently
--    (hospitalizedCurrently) recorded for each state?


-- 4. Calculate the average daily positive increase (positiveIncrease)
--    per state, and return only states where the average exceeds 1000.


-- 5. Find the 5 states with the highest total cumulative positive cases.


-- =============================================================
-- FILTERING (WHERE, IN, BETWEEN, LIMIT)
-- =============================================================

-- 6. Return all rows where hospitalizedCurrently is greater than 5000
--    and the state is in ('CA', 'TX', 'FL', 'NY').


-- 7. Find all records where deathIncrease is negative (data corrections).
--    How many such records exist per state?


-- 8. List all distinct dates where at least one state reported more than
--    10,000 new positive cases in a single day.


-- 9. Return records from January 2021 only, sorted by positiveIncrease
--    descending.


-- 10. Find states where the recovered column is NULL across all their
--     records (i.e. no recovery data was ever reported).


-- =============================================================
-- WINDOW FUNCTIONS
-- =============================================================

-- 11. Using a window function, calculate the 7-day rolling average of
--     positiveIncrease for California (CA).


-- 12. Rank all states by their total death count using RANK().
--     Show the top 10.


-- 13. For each state, calculate the cumulative sum of positiveIncrease
--     ordered by date.


-- 14. Using LAG(), find the previous day's positiveIncrease for each
--     state and compute the day-over-day change.


-- 15. Using LEAD(), identify records where the next day's deathIncrease
--     was more than double the current day's value.


-- 16. For each state, find the date when it recorded its highest
--     single-day positive increase using ROW_NUMBER().


-- 17. Calculate a 3-day rolling sum of deathIncrease for New York (NY).


-- 18. Using NTILE(4), divide each state's daily records into quartiles
--     based on positiveIncrease, and count how many days fall in each
--     quartile per state.


-- 19. Using FIRST_VALUE() and LAST_VALUE(), find each state's first and
--     last recorded hospitalizedCurrently value.


-- 20. Find the date each state crossed 100,000 cumulative positive cases
--     for the first time.


-- =============================================================
-- DATE FUNCTIONS (DATEDIFF, EXTRACT, DATE_FORMAT, WEEK, DAYOFWEEK)
-- =============================================================

-- 21. Calculate the number of days between the first and last recorded
--     date for each state.


-- 22. Find all records where the date falls on a weekend
--     (Saturday or Sunday).
--     Hint: DAYOFWEEK() returns 1=Sunday, 7=Saturday in MySQL.


-- 23. For each state, calculate the number of days since their last
--     reported deathIncrease greater than 0
--     (measured from the overall max date in the dataset).


-- 24. Group records by month and year, and return the total
--     positiveIncrease nationwide per month.


-- 25. Find the week number and year for each record, and aggregate
--     total deaths nationwide by week.


-- =============================================================
-- SUBQUERIES
-- =============================================================

-- 26. Which state had the highest hospitalizedCurrently value on the
--     single worst day nationally (the day with the highest total
--     hospitalizations across all states)?


-- 27. Find all states where the average positiveIncrease is above
--     the overall national average positiveIncrease.


-- 28. Return the top 3 days with the highest deathIncrease for each
--     state.


-- 29. Find states that never reported a day with zero positiveIncrease
--     (i.e. always had at least 1 new case every day).


-- 30. Using a subquery, find the date and state of the single record
--     with the maximum onVentilatorCurrently value.


-- =============================================================
-- CTEs (Common Table Expressions)
-- =============================================================

-- 31. Use a CTE to calculate cumulative deaths per state, then select
--     only states where cumulative deaths exceeded 20,000.


-- 32. Using a CTE, compute the 7-day rolling average of positiveIncrease
--     for each state-date pair, then find the date when this average
--     peaked for each state.


-- 33. Create a CTE that flags each record as 'surge'
--     (positiveIncrease > 5000) or 'normal'. Then count surge vs normal
--     days per state.


-- 34. Using CTEs, calculate the 3-day moving sum of deathIncrease
--     nationwide (aggregated across all states per day first).


-- 35. Write a CTE that finds the first date each state had a
--     hospitalizedCurrently value above 1000, then list them in
--     ascending order of that date.


-- =============================================================
-- SELF-JOINS
-- =============================================================

-- 36. Perform a self-join to compare each state's positiveIncrease on
--     a given date with the same state's value exactly 7 days prior.
--     Hint: use DATE_ADD or INTERVAL in MySQL.


-- 37. Use a self-join to find all cases where a state's positiveIncrease
--     on one day was at least double its value the day before.


-- =============================================================
-- CASE WHEN
-- =============================================================

-- 38. Using CASE WHEN, classify each record's hospitalizedCurrently into
--     'low' (< 500), 'medium' (500–2000), or 'high' (> 2000).
--     Count each category per state.


-- 39. Using CASE WHEN and LAG(), create a column that labels each day's
--     deathIncrease as 'increasing', 'decreasing', or 'no change'
--     compared to the previous day.


-- =============================================================
-- NULL HANDLING (COALESCE, NULLIF, IS NULL, COUNT vs COUNT(*))
-- =============================================================

-- 40. Return each state's total recovered using COALESCE(recovered, 0)
--     and compare it to their total deaths side by side.


-- 41. Find states where inIcuCurrently is NULL for more than 50% of
--     their records.


-- 42. Using NULLIF, calculate the positivity rate
--     (positive / totalTestResults * 100) per state per day,
--     avoiding division by zero.


-- =============================================================
-- RANKING (RANK, DENSE_RANK, PERCENT_RANK, NTILE)
-- =============================================================

-- 43. Using DENSE_RANK(), rank each state by their peak single-day
--     positiveIncrease. List the top 5 unique ranks.


-- 44. Find the state that recovered the fastest from its peak
--     hospitalizedCurrently value — measured as the fewest days from
--     peak to dropping to half that peak value.


-- 45. Using PERCENT_RANK(), find which percentile each day's
--     deathIncrease falls in per state, and return all days in the
--     top 5 percentile.


-- =============================================================
-- MIXED / ADVANCED
-- =============================================================

-- 46. Using GROUP BY WITH ROLLUP, produce a summary showing total
--     positiveIncrease by state and a grand total row.


-- 47. Find states where the ratio of deathConfirmed to death is below
--     70% (many probable deaths unconfirmed). Exclude states with
--     fewer than 100 non-null death records.


-- 48. Using a window function and CTE, compute the cumulative total
--     test results (totalTestResults) per state, and find the first
--     date each state surpassed 1 million total tests.


-- 49. Find the 3 consecutive dates with the highest combined
--     positiveIncrease nationwide, using a 3-day rolling window.


-- 50. Build a full summary report: for each state show total positive
--     cases, total deaths, case fatality rate (deaths / positive),
--     peak single-day cases, and whether their peak occurred before
--     or after 2021-01-01.




