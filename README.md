# SQL Queries for Customer Insights

This document outlines a series of SQL queries designed to extract valuable insights from customer data, focusing on product ownership, transaction behavior, account activity, and customer lifetime value.

## Table of Contents

- [Q1. High-Value Customers with Multiple Products](#q1-high-value-customers-with-multiple-products)
- [Q2. Transaction Frequency Analysis](#q2-transaction-frequency-analysis)
- [Q3. Account Inactivity Alert](#q3-account-inactivity-alert)
- [Q4. Customer Lifetime Value (CLV) Estimation](#q4-customer-lifetime-value-clv-estimation)
- [Challenges & Solutions](#challenges--solutions)

## Q1. High-Value Customers with Multiple Products

**Business Goal:** Identify customers who own both a funded savings plan and a funded investment plan, ranked by total deposits.

**Approach:**

Created CTEs to:

-   Count savings plans per customer (`is_regular_savings = 1`).
-   Count investment plans per customer (`is_a_fund = 1`).
-   Aggregate total deposit values per customer from the `savings_savingsaccount` table.
-   Joined the CTEs on `owner_id`.
-   Filtered for customers with at least one of each product type.
-   Sorted by total deposit value in descending order.

**Key SQL Features:**

-   Common Table Expressions (CTEs)
-   Conditional aggregation using `CASE`
-   `GROUP BY`, `JOIN`, filtering (`WHERE`), and `ORDER BY` clauses

## Q2. Transaction Frequency Analysis

**Business Goal:** Categorize customers by transaction frequency for segmentation (e.g., high/medium/low frequency).

**Approach:**

-   Grouped savings transactions by customer and month.
-   Counted total monthly transactions per customer.
-   Calculated the average transactions per customer per month.
-   Used `CASE` statements to assign each customer to a frequency band:
    -   High (≥10/month)
    -   Medium (3–9/month)
    -   Low (≤2/month)
-   Aggregated to get the number of customers and average frequency per category.

**Key SQL Features:**

-   `DATE_TRUNC` (to group by month)
-   `COUNT`, `AVG`, `GROUP BY`
-   Conditional logic with `CASE`
-   Subqueries or CTEs for multi-level aggregation

## Q3. Account Inactivity Alert

**Business Goal:** Identify all active plans with no inflow transactions in the past 365 days, for operational alerting.

**Approach:**

-   Extracted the most recent transaction per savings and investment plan using `MAX(transaction_date)`.
-   Unified savings and investment records using `UNION ALL`.
-   Compared the most recent transaction date with `CURRENT_DATE - 365`.
-   Calculated `inactivity_days` using `DATEDIFF`.
-   Returned all plans that exceeded the inactivity threshold.

**Key SQL Features:**

-   CTEs for modular logic
-   `UNION ALL` to merge across plan types
-   `MAX()` aggregate function
-   `DATEDIFF` for date-based calculations

## Q4. Customer Lifetime Value (CLV) Estimation

**Business Goal:** Estimate Customer Lifetime Value using a simplified model based on tenure and average transaction profit.

**Approach:**

-   Calculated account tenure (in months) since sign-up using `DATEDIFF(MONTH, signup_date, CURRENT_DATE)`.
-   Counted total transactions and summed transaction values.
-   Computed average profit per transaction (0.1% of transaction value).
-   Applied the given formula:
    ```
    CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction
    ```
-   Ordered results by estimated\_clv descending.

**Key SQL Features:**

-   Date part extraction using `DATEDIFF`
-   Aggregate functions (`SUM`, `COUNT`)
-   Arithmetic operations in `SELECT`
-   Handling `NULL`/zero values with `NULLIF` to avoid division errors

## 🧠 Challenges & Solutions

1.  **Month-Boundary Grouping (Q2)**

      - Used `DATE_TRUNC('month', transaction_date)` to group transactions cleanly by calendar month and prevent partial overlaps.

2.  **Division by Zero Risk (Q4)**

      - Used `NULLIF()` to safeguard against zero-month tenure or zero transaction counts, avoiding runtime errors in CLV calculation.

3.  **Transaction Date Consistency (Q3)**

      - Validated behavior of date subtraction logic (`CURRENT_DATE - INTERVAL '365 days'` or `DATEDIFF`) to ensure accuracy in inactivity checks.

4.  **Data Normalization for Deposits**

      - Converted monetary values from kobo to naira (e.g., `confirmed_amount / 100`) where applicable to match expected output formats.

5.  **Balancing Performance and Readability**

      - Used CTEs to improve modularity and clarity while avoiding deeply nested subqueries.
