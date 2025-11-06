# Stateless Random Sampling: Taming Survey Chaos with Deterministic SQL #

**Keywords:** Reproducible Sampling, Participant Selection, Survey Design, Hash-Stable Randomness, Reproducibility, Bernoulli Trials, Sampling Methodology

### TL;DR

Survey pipelines often store “who we invited last time” to tame randomness. This design utilizes hash-stable randomness to achieve reproducible, auditable selections with predictable volumes and cooldowns — entirely in SQL, without requiring state tables or storing a random seed.

### Abstract

In survey design, randomness plays a crucial role in selecting participants, yet traditional methods often lead to inconsistencies and challenges in reproducibility. This paper proposes a novel approach utilizing hash-stable randomness in survey pipelines, addressing the need for reliable and auditable participant selection. By storing information on previously invited participants, we can effectively manage and mitigate the unpredictability associated with random sampling. The implementation is executed entirely in SQL, eliminating the need for complex state tables and minimizing the risk of unexpected errors or heisenbugs. This approach not only enhances the reproducibility of selections but also ensures predictable participant volumes and cooldowns, ultimately promoting greater integrity and reliability in survey research methodologies.

### 1. Introduction

Survey programs often face two *opposing* pressures:

- **Statistical fairness** — each eligible user should have an equal chance of selection.
- **Operational control** — consistent volumes and must avoid spam or fatigue.

Traditional ETL-based sampling solves neither cleanly. Random functions, such as `RAND()` or `RANDOM()`, vary between runs, forcing teams to persist “selected” lists that must be versioned, reloaded, and reconciled. Over time, these lists desynchronize from the source of truth. Given the same data, the invitations are chosen based on specific logic.

**Question:**

Can we derive sampling deterministically from the data itself, so that no state needs to be stored?

**Answer:** 

Yes — by turning randomness into a pure function of record attributes.

### 2. “SAFRF” Design Principles

1. **Statelessness:** The sampling process derives all necessary information (including prior invitations) from a snapshot of the source data.
2. **Auditability:** The selection logic is readable, inspectable, and reconstructable.
3. **Fairness:** Each eligible record has a fixed, known inclusion probability.
4. **Reproducibility:** When provided with the same data, the generated invitations will align with the established logic.
5. **Fatigue-Aware:** Simple rules enforce one invite per week and a long-term cooldown.

**Acronym:** SAFRF “safe-ref”, which reads as “safe reference”.

*“safe reference” → stateless, auditable, fair, reproducible, fatigue-aware.*

### 3. Methodology

### 3.1 Eligibility Filtering

Only include contacts who:

- Consented to communication,
- Have a valid email,
- Contact successfully reached,
- Have an outcome: *Completed* or *Rejected* (e.g., mapped to NPS/CSAT).

If the filter is biased (e.g., only includes users with certain characteristics), the output will be biased. This is a precondition.

***Tip:** Keep this filter as a single CTE so that policy changes are diffable and auditable.*

### 3.2 Deterministic Randomness

Each contact record receives a fixed, random-like value:

```sql
-- Hash-stable uniform in [0,1). Prefer a 64-bit hash when possible.
-- Example (portable-ish): normalize a hash to double

TO_DECIMAL(ABS(HASH(distinct_id)) % 10000000000000000) / 1e16 AS rand_val
```

Set inclusion probabilities by survey type (example):

- **NPS**: include if u < 0.50
- **CSAT**: include if u < 0.50

We have now created a **Bernoulli trial**; ****in probability, these are random experiments with exactly two outcomes.

***Production note:** if the warehouse exposes a 64-bit hash, normalize that directly (e.g., `HASH64 / 18446744073709551616.0`) to avoid modulo edge distortion.*

### 3.3 Weekly Deduplication

Retain only the most recent interaction for each person every week:

```sql
QUALIFY ROW_NUMBER() OVER (
PARTITION BY email, DATE_TRUNC('week', date_field)
ORDER BY date_field DESC
) = 1
```

No dog-piling the same person due to multiple interactions in the same week.

### 3.4 Cooldown Exclusion

Enforce a long-form cooldown after any invite — no state table needed. Compare the current **week_start** to the **previous selected** week per person and drop those that fall within the cooldown window.

```sql
LAG(week_start) OVER (PARTITION BY email ORDER BY week_start) AS prev_week,
DATEDIFF('week', prev_week, week_start) AS diff_weeks

-- Keep only if prev_week is null or diff_weeks >= :cooldown_weeks
```

Set cooldown_weeks to the policy (e.g., 4). If supported, parameterize it for easier manipulation and auditing.

### 4. Implementation

The full system runs as a composable SQL view. No intermediate storage, no manual exclusions. CTEs encapsulate each logical phase:

1. POPULATION_PRESAMPLE — eligibility filtering + random value generation
2. CANDIDATES — inclusion probability check + deduplication
3. SELECT_FINAL — cooldown enforcement

Because every decision depends only on deterministic functions, any analyst can rerun the script for any date range and reproduce the same invite population.

### 4.1 Reference Implementation (Composable CTEs)

The code runs as a single view or model, with no intermediate storage and no manual exclusions.

```sql
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
```

***Dialect note:** if the engine lacks `QUALIFY`, wrap that windowed `ROW_NUMBER()` in a subquery and filter `where rn = 1`.*

### 5. Results (What to Expect / How to Show It)

In operational use, one should observe:

- **Invite volumes** track expected values within normal binomial bounds (e.g., ±1–2% of target over weekly runs).
- **Zero duplicates** inside the cooldown window.
- **Deterministic reruns** for the same date window and snapshot — byte-for-byte identical outputs.

### 6. Discussion

This approach reframes randomness as a *functional constant* rather than a stateful process.

The benefits extend beyond surveys:

- **A/B testing frameworks** (fixed randomization by user ID)
- **Controlled load balancing** (stable random partitioning)
- **Privacy-preserving analytics** (no stored selection logs)

**Limitations:**

- Bias can occur if `HASH()` has implementation changes between engines.
- Modulo arithmetic introduces minor boundary distortion (use HASH64 / 2⁶³ for production, if available).
- Requires consistent ID inputs — downstream deduping must ensure stable keys.

### 7. Ethics & Fairness

Survey fatigue is not only an operational issue but an ethical one. Stateless sampling prevents oversampling of vulnerable groups and guarantees equal probability across demographic strata *without* manual tuning.

Algorithmic fairness ensures each eligible record has the same inclusion probability, while procedural fairness ensures the process is transparent, explainable, and auditable. Because the logic is reproducible, compliance teams can verify fairness mathematically, making the “why this person?” question answerable.

### 8. Conclusion

A deterministic, hash-based sampler replaces persistence with math. The system achieves predictable invite volumes, zero duplicates, and transparent governance in ***under 55 lines of SQL**.*

This **probabilistic control without a state** is a reusable pattern for analytics engineering.
