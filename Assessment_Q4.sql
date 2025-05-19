-- Assessment_Q4.sql
-- Calculate tenure, total txns, and estimated CLV per customer.

WITH signup AS (
    SELECT
        id AS owner_id,
        signup_date
    FROM users_customuser
),
txns AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        SUM(confirmed_amount) / 100.0 AS total_value
    FROM savings_savingsaccount
    GROUP BY owner_id
)
SELECT
    u.owner_id   AS customer_id,
    u.name,
    DATE_PART('month', AGE(CURRENT_DATE, s.signup_date)) AS tenure_months,
    t.total_transactions,
    -- profit per txn = 0.001 * avg txn value; avg txn value = total_value/total_txns
    ROUND(
      (t.total_transactions::decimal / NULLIF(DATE_PART('month', AGE(CURRENT_DATE, s.signup_date)),0))
      * 12
      * (0.001 * (t.total_value / t.total_transactions)),
    2) AS estimated_clv
FROM users_customuser u
JOIN signup s    ON u.id = s.owner_id
LEFT JOIN txns   t ON u.id = t.owner_id
WHERE DATE_PART('month', AGE(CURRENT_DATE, s.signup_date)) > 0
ORDER BY estimated_clv DESC;
