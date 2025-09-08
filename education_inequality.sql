-- EDA

SELECT *
FROM education_inequality_data;

-- Number of schools by state
SELECT state, COUNT(*) AS school_count
FROM education_inequality_data
GROUP BY state
ORDER BY school_count DESC;

-- Number of schools by type(public, private, charter)
SELECT school_type, COUNT(*) AS count
FROM education_inequality_data
GROUP BY school_type;

-- Number of schools by grade level (Elementary, Middle, High)
SELECT grade_level, COUNT(*) AS school_count
FROM education_inequality_data
GROUP BY grade_level
ORDER BY school_count DESC;

-- Min, mean, max of avg test scores
SELECT MIN(avg_test_score_percent) AS min_score, MAX(avg_test_score_percent) AS max_score,
	ROUND(AVG(avg_test_score_percent), 2) AS avg_score
FROM education_inequality_data;

-- top 10 highest scoring schools
WITH ranked_schools AS (
  SELECT school_name, state, avg_test_score_percent,
    RANK() OVER (ORDER BY avg_test_score_percent DESC) AS score_rank
  FROM education_inequality_data
)
SELECT *
FROM ranked_schools
WHERE score_rank <= 10;

-- bot 10 lowest scoring schools
WITH ranked_schools AS (
  SELECT school_name, state, avg_test_score_percent,
    RANK() OVER (ORDER BY avg_test_score_percent ASC) AS score_rank
  FROM education_inequality_data
)
SELECT *
FROM ranked_schools
WHERE score_rank <= 10;

-- schools with the lowest per-student funding
SELECT school_name, state, funding_per_student_usd
FROM education_inequality_data
WHERE funding_per_student_usd IS NOT NULL
ORDER BY funding_per_student_usd
LIMIT 10;

-- Average Test Score per school vs State Average
WITH state_avg_scores AS 
(
SELECT state, ROUND(AVG(avg_test_score_percent), 2) AS avg_state_score
FROM education_inequality_data
GROUP BY state
)
SELECT e.school_name, e.state, e.avg_test_score_percent, s.avg_state_score,
    ROUND(e.avg_test_score_percent - s.avg_state_score, 2) AS score_diff_from_state_avg
FROM education_inequality_data AS e
JOIN state_avg_scores AS s
    ON e.state = s.state
ORDER BY score_diff_from_state_avg DESC;

-- State rankings and performance summary
SELECT state,
    COUNT(*) AS school_count,
    ROUND(AVG(avg_test_score_percent), 2) AS avg_test_score,
    ROUND(AVG(funding_per_student_usd), 2) AS avg_funding,
    ROUND(AVG(student_teacher_ratio), 2) AS avg_class_size,
    ROUND(AVG(percent_low_income), 2) AS avg_poverty_rate,
    ROUND(AVG(dropout_rate_percent), 2) AS avg_dropout_rate,
    -- high performing schools = 80% or higher
    SUM(CASE WHEN avg_test_score_percent >= 80 THEN 1 ELSE 0 END) AS high_performing_schools,
    -- low performing schools = 60% or higher
    SUM(CASE WHEN avg_test_score_percent < 60 THEN 1 ELSE 0 END) AS low_performing_schools
FROM education_inequality_data
GROUP BY state
ORDER BY avg_test_score DESC;

-- Performance across public, private, charter schools
SELECT school_type, grade_level,
    COUNT(*) AS school_count,
    ROUND(AVG(avg_test_score_percent), 2) AS avg_score,
    ROUND(AVG(funding_per_student_usd), 2) AS avg_funding,
    ROUND(AVG(student_teacher_ratio), 2) AS avg_student_teacher_ratio,
    ROUND(AVG(percent_low_income), 2) AS avg_poverty_rate
FROM education_inequality_data
GROUP BY school_type, grade_level
ORDER BY school_type, grade_level;

-- Summary table to move to tableau

SELECT school_name, state, school_type, grade_level, avg_test_score_percent, funding_per_student_usd,
    student_teacher_ratio, percent_low_income, percent_minority, internet_access_percent, dropout_rate_percent,
    -- Performance
    CASE
        WHEN avg_test_score_percent >= 80 THEN 'High Performing'
        WHEN avg_test_score_percent >= 60 THEN 'Average Performing'
        ELSE 'Low Performing'
    END AS performance_category,
    -- Funding
    CASE
        WHEN funding_per_student_usd < 10000 THEN 'Low Funding (<$10K)'
        WHEN funding_per_student_usd < 20000 THEN 'Medium Funding ($10K-$20K)'
        ELSE 'High Funding (>$20K)'
    END AS funding_category,
    -- Poverty
    CASE
        WHEN percent_low_income < 25 THEN 'Low Poverty (<25%)'
        WHEN percent_low_income < 50 THEN 'Medium Poverty (25%-50%)'
        WHEN percent_low_income < 75 THEN 'High Poverty (50%-75%)'
        ELSE 'Very High Poverty (>75%)'
    END AS poverty_category,
    -- Class size
    CASE
        WHEN student_teacher_ratio < 15 THEN 'Small Classes (<15)'
        WHEN student_teacher_ratio < 20 THEN 'Medium Classes (15-20)'
        ELSE 'Large Classes (>20)'
    END AS class_size_category

FROM education_inequality_data;