-- Assessment_Q3.sql
-- Flag plans with no inflow in the last 365 days.

WITH last_savings_txn AS (
    SELECT
        owner_id,
        MAX(transaction_date) AS last_date
    FROM savings_savingsaccount
    GROUP BY owner_id
),
last_investment_txn AS (
    SELECT
        plan.owner_id,
        MAX(w.withdrawal_date) AS last_date
    FROM withdrawals_withdrawal w
    JOIN plans_plan plan
      ON w.plan_id = plan.id
    WHERE plan.is_a_fund = 1
    GROUP BY plan.owner_id
),
all_plans AS (
    SELECT
        p.id        AS plan_id,
        p.owner_id,
        CASE
          WHEN p.is_regular_savings = 1 THEN 'Savings'
          WHEN p.is_a_fund         = 1 THEN 'Investment'
        END AS type,
        COALESCE(s.last_date, i.last_date) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN last_savings_txn    s ON p.owner_id = s.owner_id
    LEFT JOIN last_investment_txn i ON p.owner_id = i.owner_id
    WHERE p.status = 'Active'
)
SELECT
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATE_PART('day', CURRENT_DATE - last_transaction_date) AS inactivity_days
FROM all_plans
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '365 days'
ORDER BY inactivity_days DESC;
