-- Assessment_Q2.sql
-- Categorize customers by their average monthly transaction count.

WITH txns AS (
    SELECT
        owner_id,
        DATE_TRUNC('month', transaction_date) AS month_start,
        COUNT(*) AS txn_count
    FROM savings_savingsaccount
    GROUP BY owner_id, DATE_TRUNC('month', transaction_date)
),
avg_monthly AS (
    SELECT
        owner_id,
        AVG(txn_count) AS avg_txn_per_month
    FROM txns
    GROUP BY owner_id
)
SELECT
    CASE
        WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
        WHEN avg_txn_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month
FROM avg_monthly
GROUP BY 1
ORDER BY
    CASE
        WHEN frequency_category = 'High Frequency'   THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
