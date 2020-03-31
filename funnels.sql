-- Inspect survey table
SELECT * FROM survey
LIMIT 10;

-- survey funnel
SELECT question,
  COUNT(DISTINCT user_id) 
FROM survey
GROUP BY question;
-- conversion rate calculated in Excel

-- Inspect multiple tables for funnels
SELECT * FROM quiz
LIMIT 5;

SELECT * FROM home_try_on
LIMIT 5;

SELECT * FROM purchase
LIMIT 5;

-- funnel for overall conversion
WITH q AS(
	SELECT '1-quiz' AS stage, COUNT(DISTINCT user_id)
	FROM quiz),
h AS(
	SELECT '2-home-try-on' AS stage, COUNT(DISTINCT user_id)
	FROM home_try_on),
p AS(
	SELECT '3-purchase' AS stage, COUNT(DISTINCT user_id)
	FROM purchase)

SELECT * FROM q
UNION ALL
SELECT * FROM h
UNION ALL
SELECT * FROM p;
-- conversion rate calculated in Excel

-- funnel for home_try_on to purchase conversion: 3 pairs vs 5 pairs
WITH funnel AS(
  SELECT DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS 'q'
  LEFT JOIN home_try_on AS 'h'
  ON q.user_id = h.user_id
  LEFT JOIN purchase AS 'p'
  ON q.user_id = p.user_id)

SELECT number_of_pairs,
	SUM(is_home_try_on) AS 'num_home_try_on',
	SUM(is_purchase) AS 'num_purchase',
	1.0 * SUM(is_purchase)/ COUNT(number_of_pairs) AS 'purchase_rate'
FROM funnel
GROUP BY 1
HAVING num_home_try_on > 1;