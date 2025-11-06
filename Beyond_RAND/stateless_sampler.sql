-- PARAMETERS (suggest putting in a config table or dbt vars)
:p_nps = 0.50, :p_csat = 0.50, :cooldown_weeks = 4, :week_start = 'MONDAY'

WITH POPULATION_PRESAMPLE AS (
	SELECT
		DATE_TRUNC('DAY', survey_completed_utc) AS survey_date,
		CASE 
			WHEN UPPER(survey_status)= 'REJECTED' THEN 'CSAT' ELSE 'NPS' 
		END AS survey_type,
		LOWER(user_email) AS email,
		-- stable 0–1 random per record id
		TO_DECIMAL(ABS(HASH(survey_id)) % 10000000000000000) / 1e16 AS rand_val,
		*
	FROM your_source_table
	WHERE UPPER(survey_status) IN ('REJECTED', 'COMPLETED')
		AND is_eligible = TRUE
		AND UPPER(user_optout_email) = FALSE
		AND user_email IS NOT NULL
	),
CANDIDATES AS (
	SELECT
		*,
		DATE_TRUNC('WEEK', survey_date) AS week_start,
		CASE
			WHEN survey_type='NPS' AND rand_val < :p_nps THEN 1
			WHEN survey_type='CSAT' AND rand_val < :p_csat THEN 1
			ELSE 0
		END AS is_candidate
	FROM POPULATION_PRESAMPLE
		QUALIFY ROW_NUMBER() 
		OVER (
		PARTITION BY email, DATE_TRUNC('WEEK', survey_date)
		ORDER BY survey_date DESC
		) = 1
	),
SELECT_FINAL AS (
	SELECT
	*,
	LAG(week_start) OVER (PARTITION BY email ORDER BY week_start) AS prev_week,
	DATEDIFF('week', prev_week, week_start) AS diff_weeks
	FROM CANDIDATES
	WHERE is_candidate = 1
	)
SELECT
	week_start, 
	survey_date, 
	survey_type, 
	email, 
	rand_val
	-- add any fields needed for delivery
FROM SELECT_FINAL
	WHERE prev_week IS NULL OR diff_weeks >= :cooldown_weeks;
