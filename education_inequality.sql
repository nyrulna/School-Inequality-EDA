-- EDA
SELECT *
FROM education_inequality_data;

SELECT state, COUNT(*) as school_count
FROM education_inequality_data
GROUP BY state
ORDER BY school_count DESC;

SELECT school_type, COUNT(*) as count
FROM education_inequality_data
GROUP BY school_type;

SELECT grade_level, COUNT(*) as school_count
FROM education_inequality_data
GROUP BY grade_level
ORDER BY school_count DESC;

SELECT MIN(avg_test_score_percent) as min_score, MAX(avg_test_score_percent) as max_score,
	ROUND(AVG(avg_test_score_percent), 2) as avg_score
FROM education_inequality_data;

-- top 10 schools
WITH ranked_schools AS (
  SELECT school_name, state, avg_test_score_percent,
    RANK() OVER (ORDER BY avg_test_score_percent DESC) AS score_rank
  FROM education_inequality_data
)
SELECT *
FROM ranked_schools
WHERE score_rank <= 10;

-- bot 10 schools
WITH ranked_schools AS (
  SELECT school_name, state, avg_test_score_percent,
    RANK() OVER (ORDER BY avg_test_score_percent ASC) AS score_rank
  FROM education_inequality_data
)
SELECT *
FROM ranked_schools
WHERE score_rank <= 10;

SELECT school_name, state, funding_per_student_usd
FROM education_inequality_data
WHERE funding_per_student_usd IS NOT NULL
ORDER BY funding_per_student_usd
LIMIT 10;

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

-- State rankings 
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
    COUNT(*) as school_count,
    ROUND(AVG(avg_test_score_percent), 2) as avg_score,
    ROUND(AVG(funding_per_student_usd), 2) as avg_funding,
    ROUND(AVG(student_teacher_ratio), 2) as avg_student_teacher_ratio,
    ROUND(AVG(percent_low_income), 2) as avg_poverty_rate
FROM education_inequality_data
GROUP BY school_type, grade_level
ORDER BY school_type, grade_level;
