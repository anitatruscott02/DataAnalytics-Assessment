-- Assessment_Q1.sql
-- Find customers who have at least one savings and one investment plan,
-- along with counts and total deposits, sorted by total deposits descending.

WITH savings_plans AS (
    SELECT
        p.owner_id,
        COUNT(*) AS savings_count
    FROM plans_plan p
    WHERE p.is_regular_savings = 1
      AND p.status = 'Funded'
    GROUP BY p.owner_id
),
investment_plans AS (
    SELECT
        p.owner_id,
        COUNT(*) AS investment_count
    FROM plans_plan p
    WHERE p.is_a_fund = 1
      AND p.status = 'Funded'
    GROUP BY p.owner_id
),
deposits AS (
    SELECT
        s.owner_id,
        SUM(s.confirmed_amount) / 100.0 AS total_deposits  -- convert kobo to naira
    FROM savings_savingsaccount s
    GROUP BY s.owner_id
)
SELECT
    u.id       AS owner_id,
    u.name,
    sp.savings_count,
    ip.investment_count,
    d.total_deposits
FROM users_customuser u
JOIN savings_plans    sp ON u.id = sp.owner_id
JOIN investment_plans ip ON u.id = ip.owner_id
LEFT JOIN deposits    d  ON u.id = d.owner_id
ORDER BY d.total_deposits DESC;
