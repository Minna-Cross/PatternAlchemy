/*
    1. Recursive CTE for Time Intervals:
    - Generates 15-minute intervals for a 24-hour period

    2. Interval Formatting:
    - Formats each interval in both 24-hour and 12-hour formats

    3. Day Generation:
    - Generates days of the week (0-6) to apply day-type logic (Sunday to Saturday)

    4. Attributes for Analysis:
    - Adds attributes to each interval to aid in analysis:
        - hour: The hour of the day (00-23)
        - minute: The minute of the hour (00, 15, 30, 45)
        - am_pm: Whether the time is AM or PM
        - period_of_day: A general categorization of the time of day:
        
        | Period of Day    | Time Range    |
        |------------------|---------------|
        | Early Morning    | 00:00 - 05:59 |
        | Morning          | 06:00 - 11:59 |
        | Afternoon        | 12:00 - 17:59 |
        | Evening          | 18:00 - 23:59 |

    5. Shipping Window Calculations:
    - Determines the remaining time within specific shipping windows based on the current interval:
    
        | Shipping Window  | Time Range     | Description                                         |
        |------------------|----------------|-----------------------------------------------------|
        | 12-hour window   | 00:00 - 12:59  | Requests received during this time ship within 12 hours |
        | 18-hour window   | 13:00 - 23:59  | Requests received during this time ship within 18 hours |

        - ship_within_seconds_min: Minimum seconds remaining for the shipping window
        - ship_within_seconds_max: Maximum seconds remaining for the shipping window
        - ship_within_minutes_min: Minimum minutes remaining for the shipping window, rounded to two decimal places
        - ship_within_minutes_max: Maximum minutes remaining for the shipping window, rounded to two decimal places
        - ship_within_hours_min: Minimum hours remaining for the shipping window, rounded to two decimal places
        - ship_within_hours_max: Maximum hours remaining for the shipping window, rounded to two decimal places

    6. Day Type Considerations:
    - Includes intervals for each day of the week with different shipping logic:
        - If received outside of business days (weekends or holidays), processing starts at 12:00 am of the next business day
        - If holiday, consider Saturday or Sunday based on 1 day or 2 day requirements

    7. Business Hours Indicator:
    - Adds an attribute to indicate whether the time falls within standard business hours (09:00 - 17:00) on weekdays
*/
WITH RECURSIVE time_intervals AS (
    SELECT 
        0 AS minutes_since_midnight,
        LPAD(FLOOR(0 / 60), 2, '0') || ':' || LPAD(0 % 60, 2, '0') AS interval_start_24h,
        LPAD(FLOOR(15 / 60), 2, '0') || ':' || LPAD(15 % 60, 2, '0') AS interval_end_24h,
        LPAD(FLOOR(0 % 720 / 60), 2, '0') || ':' || LPAD(0 % 60, 2, '0') || CASE WHEN FLOOR(0 / 60) < 12 THEN ' AM' ELSE ' PM' END AS interval_start_12h,
        LPAD(FLOOR(15 % 720 / 60), 2, '0') || ':' || LPAD(15 % 60, 2, '0') || CASE WHEN FLOOR(15 / 60) < 12 THEN ' AM' ELSE ' PM' END AS interval_end_12h
    UNION ALL
    SELECT
        minutes_since_midnight + 15,
        LPAD(FLOOR((minutes_since_midnight + 15) / 60), 2, '0') || ':' || LPAD((minutes_since_midnight + 15) % 60, 2, '0'),
        LPAD(FLOOR((minutes_since_midnight + 30) / 60), 2, '0') || ':' || LPAD((minutes_since_midnight + 30) % 60, 2, '0'),
        LPAD(FLOOR(((minutes_since_midnight + 15) % 720) / 60), 2, '0') || ':' || LPAD((minutes_since_midnight + 15) % 60, 2, '0') || CASE WHEN FLOOR((minutes_since_midnight + 15) / 60) < 12 THEN ' AM' ELSE ' PM' END,
        LPAD(FLOOR(((minutes_since_midnight + 30) % 720) / 60), 2, '0') || ':' || LPAD((minutes_since_midnight + 30) % 60, 2, '0') || CASE WHEN FLOOR((minutes_since_midnight + 30) / 60) < 12 THEN ' AM' ELSE ' PM' END
    FROM time_intervals
    WHERE minutes_since_midnight + 15 < 24 * 60
),
days_of_week AS (
    SELECT 0 AS day_num UNION ALL
    SELECT 1 UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6
)
-- Generates intervals for each day of the week
SELECT 
    interval_start_24h,
    interval_end_24h,
    interval_start_12h,
    interval_end_12h,
    LPAD(FLOOR(ti.minutes_since_midnight / 60), 2, '0') AS hour,
    LPAD(ti.minutes_since_midnight % 60, 2, '0') AS minute,
    CASE 
        WHEN FLOOR(ti.minutes_since_midnight / 60) < 12 THEN 'AM'
        ELSE 'PM'
    END AS am_pm,
    CASE 
        WHEN ti.minutes_since_midnight < 360 THEN 'Early Morning'       -- 00:00 - 05:59
        WHEN ti.minutes_since_midnight < 720 THEN 'Morning'             -- 06:00 - 11:59
        WHEN ti.minutes_since_midnight < 1080 THEN 'Afternoon'          -- 12:00 - 17:59
        ELSE 'Evening'                                                  -- 18:00 - 23:59
    END AS period_of_day,
    CASE 
        WHEN d.day_num = 0 THEN 'Sunday'
        WHEN d.day_num = 1 THEN 'Monday'
        WHEN d.day_num = 2 THEN 'Tuesday'
        WHEN d.day_num = 3 THEN 'Wednesday'
        WHEN d.day_num = 4 THEN 'Thursday'
        WHEN d.day_num = 5 THEN 'Friday'
        WHEN d.day_num = 6 THEN 'Saturday'
    END AS day_name,
    CASE 
        WHEN d.day_num BETWEEN 1 AND 5 THEN 
            CASE 
                WHEN ti.minutes_since_midnight < 780 THEN (720 - ti.minutes_since_midnight) * 60    -- Time remaining during 12-hour shipping window period in seconds
                WHEN ti.minutes_since_midnight < 1440 THEN (1080 - ti.minutes_since_midnight) * 60  -- Time remaining during 18-hour shipping window period in seconds
                ELSE 0
            END
        ELSE 
            CASE 
                WHEN ti.minutes_since_midnight < 780 THEN (720 - ti.minutes_since_midnight + 1440) * 60     -- Adding 1440 minutes for next business day
                WHEN ti.minutes_since_midnight < 1440 THEN (1080 - ti.minutes_since_midnight + 1440) * 60   -- Adding 1440 minutes for next business day
                ELSE 0
            END
    END AS ship_within_seconds_min,
    ROUND(ship_within_seconds_min / 60.0, 2) AS ship_within_minutes_min,
    ROUND(ship_within_seconds_min / 3600.0, 2) AS ship_within_hours_min,
    CASE 
        WHEN d.day_num BETWEEN 1 AND 5 THEN 
            CASE 
                WHEN ti.minutes_since_midnight < 780 THEN 720 * 60      -- Maximum seconds remaining during 12-hour shipping window period
                ELSE 1080 * 60                                          -- Maximum seconds remaining during 18-hour shipping window period
            END
        ELSE 
            CASE 
                WHEN ti.minutes_since_midnight < 780 THEN (720 + 1440) * 60 -- Maximum seconds remaining during 12-hour shipping window period + next business day
                ELSE (1080 + 1440) * 60                                     -- Maximum seconds remaining during 18-hour shipping window period + next business day
            END
    END AS ship_within_seconds_max,
    ROUND(ship_within_seconds_max / 60.0, 2) AS ship_within_minutes_max,
    ROUND(ship_within_seconds_max / 3600.0, 2) AS ship_within_hours_max,
    CASE 
        WHEN ti.minutes_since_midnight BETWEEN 540 AND 1020 AND d.day_num BETWEEN 1 AND 5 THEN 'Yes' -- 09:00 - 17:00 on weekdays
        ELSE 'No'
    END AS business_hours,
    ti.minutes_since_midnight,
    d.day_num
FROM time_intervals ti
CROSS JOIN days_of_week d
ORDER BY d.day_num, ti.minutes_since_midnight;
