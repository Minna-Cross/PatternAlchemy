/*
    1. Recursive CTE for Date Range:
    - Generates a date range from X days in the past to X days in the future from the current date

    2. Year Extraction:
    - Extracts years from the date range
    - Facilitates the creation of holiday dates

    3. Fixed-Date Holidays:
    - Identifies fixed-date holidays using `DATE_FROM_PARTS`:

    | Holiday          | Date         |
    |------------------|--------------|
    | New Year's Day   | January 1    |
    | Juneteenth       | June 19      |
    | Independence Day | July 4       |
    | Veterans Day     | November 11  |
    | Christmas Eve    | December 24  |
    | Christmas Day    | December 25  |
    | New Year's Eve   | December 31  |

    4. Variable-Date Holidays:
    - Identifies variable-date holidays with specific logic to ensure they fall on the correct weekdays
    - Validated holiday dates for accuracy from 2022 to 2026:

    | Holiday                   | Date                          |
    |---------------------------|-------------------------------|
    | MLK Day                   | Third Monday in January       |
    | Presidents' Day           | Third Monday in February      |
    | Memorial Day              | Last Monday in May            |
    | Labor Day                 | First Monday in September     |
    | Indigenous Peoples' Day   | Second Monday in October      |
    | Thanksgiving              | Fourth Thursday in November   |

    5. Output:
    - Includes comprehensive attributes for each date by row
*/

WITH RECURSIVE date_range AS (
	SELECT 
		DATEADD(day, -365, CURRENT_DATE()) AS date
	UNION ALL
	SELECT
		DATEADD(day, 1, date)
	FROM date_range
	WHERE date < DATEADD(day, 365, CURRENT_DATE())
),
years AS (
	SELECT DISTINCT 
		EXTRACT(year FROM date) AS year 
	FROM date_range
),
fixed_holidays AS (
	-- Logic for calculating fixed-date holidays
	-- Proprietary holiday logic obfuscated
	SELECT 
		DATE_FROM_PARTS(year, 1, 1) AS holiday_date, 'New Year''s Day' AS holiday_name
	FROM years
	UNION ALL
	-- Other fixed holidays (Juneteenth, Independence Day, etc.)
	SELECT 
		-- Placeholder: Logic for other fixed holidays here
		DATE_FROM_PARTS(year, 7, 4) AS holiday_date, 'Independence Day' AS holiday_name
	FROM years
	-- Additional fixed holidays redacted
),
variable_holidays AS (
	-- Logic for calculating variable-date holidays
	-- Proprietary logic obfuscated for holidays with specific weekday rules
	SELECT 
		-- Placeholder: Logic for calculating MLK Day (Third Monday in January)
		DATEADD(day, X, DATE_FROM_PARTS(year, 1, X)) AS holiday_date, 'MLK Day' AS holiday_name
	FROM years
	UNION ALL
	-- Placeholder: Logic for calculating Thanksgiving (Fourth Thursday in November)
	SELECT 
		DATEADD(day, Y, DATE_FROM_PARTS(year, 11, Y)) AS holiday_date, 'Thanksgiving' AS holiday_name
	FROM years
	-- Additional variable holidays redacted
),
all_holidays AS (
	-- Combine fixed and variable holidays
	SELECT * FROM fixed_holidays
	UNION ALL
	SELECT * FROM variable_holidays
)

SELECT
	date,
	TO_CHAR(date, 'YYYY-MM-DD') AS date_string,
	h.holiday_name,
	DAYNAME(date) AS day_name,
	EXTRACT(dayofweek FROM date) AS day_of_week,
	EXTRACT(year FROM date) AS year,
	EXTRACT(dayofyear FROM date) AS day_of_year,
	EXTRACT(week FROM date) AS week_of_year,
	EXTRACT(quarter FROM date) AS quarter,
	MONTHNAME(date) AS month_name,
	EXTRACT(month FROM date) AS month_num,
	EXTRACT(day FROM date) AS day_num,
	CASE 
		WHEN EXTRACT(dayofweek FROM date) IN (6, 7) THEN 'Yes' ELSE 'No'
	END AS is_weekend,
	CASE 
		WHEN EXTRACT(dayofweek FROM date) IN (1, 2, 3, 4, 5) THEN 'Yes' ELSE 'No'
	END AS is_weekday,
	EXTRACT(yearofweekiso FROM date) AS iso_year,
	EXTRACT(weekiso FROM date) AS iso_week,
	CASE 
		WHEN MOD(EXTRACT(year FROM date), 4) = 0 AND (MOD(EXTRACT(year FROM date), 100) != 0 OR MOD(EXTRACT(year FROM date), 400) = 0) THEN 'Yes' ELSE 'No'
	END AS is_leap_year,
	CASE 
		WHEN h.holiday_date IS NOT NULL THEN 'Yes' ELSE 'No'
	END AS is_holiday,
	CASE 
		WHEN EXTRACT(month FROM date) IN (12, 1, 2) THEN 'Winter'
		WHEN EXTRACT(month FROM date) IN (3, 4, 5) THEN 'Spring'
		WHEN EXTRACT(month FROM date) IN (6, 7, 8) THEN 'Summer'
		WHEN EXTRACT(month FROM date) IN (9, 10, 11) THEN 'Autumn'
	END AS season_us
FROM date_range d
LEFT JOIN all_holidays h ON d.date = h.holiday_date
ORDER BY
	date DESC;
