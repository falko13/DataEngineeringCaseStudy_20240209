WITH time_windows AS (
SELECT
'2023-12-15' AS current_christmas_start,
'2024-01-08' AS current_christmas_end,
'2022-12-15' AS previous_christmas_start,
'2023-01-08' AS previous_christmas_end,
'2023-11-01' AS collection_start,
'2024-01-08' AS collection_end
),
active_products AS (
SELECT DISTINCT
product_id
FROM product_data
WHERE DeactivationDate IS NULL
),
active_stores_products AS (
SELECT DISTINCT
t.store_id,
ap.product_id
FROM transactions t
CROSS JOIN active_products ap
WHERE DATE(t.transaction_begin_date) BETWEEN (SELECT collection_start FROM time_windows) AND (SELECT collection_end FROM time_windows)
OR DATE(t.transaction_begin_date) BETWEEN (SELECT previous_christmas_start FROM time_windows) AND (SELECT previous_christmas_end FROM time_windows)
),
relevant_dates AS (
SELECT calendar_date
FROM calendar
WHERE calendar_date BETWEEN (SELECT current_christmas_start FROM time_windows) AND (SELECT current_christmas_end FROM time_windows)
),
comprehensive_combinations AS (
SELECT
rd.calendar_date,
asp.store_id,
asp.product_id
FROM relevant_dates rd
CROSS JOIN active_stores_products asp
),
current_year_transactions AS (
SELECT
store_id,
product_id,
SUM(COALESCE(sale_quantity, 0)) AS sale_quantity_sum,
DATE(transaction_begin_date) AS transaction_date
FROM transactions
WHERE DATE(transaction_begin_date) BETWEEN (SELECT current_christmas_start FROM time_windows) AND (SELECT current_christmas_end FROM time_windows)
AND Transaction_Status <> 'Voided'
GROUP BY store_id, product_id, DATE(transaction_begin_date)
),
previous_year_transactions AS (
SELECT
store_id,
product_id,
SUM(COALESCE(sale_quantity, 0)) AS sale_quantity_sum,
DATE(transaction_begin_date) AS transaction_date
FROM transactions
WHERE DATE(transaction_begin_date) BETWEEN (SELECT previous_christmas_start FROM time_windows) AND (SELECT previous_christmas_end FROM time_windows)
AND Transaction_Status <> 'Voided'
GROUP BY store_id, product_id, DATE(transaction_begin_date)
),
aggregated_transactions AS (
SELECT
cc.store_id,
cc.product_id,
cc.calendar_date,
pd.product_category,
pd.product_name,
pd.unit_of_measure,
pd.supplier,
cyt.transaction_date,
cyt.sale_quantity_sum AS sale_quantity_sum_current_year,
pyt.sale_quantity_sum AS sale_quantity_sum_previous_year,
SUM(cyt.sale_quantity_sum) OVER(PARTITION BY cc.store_id, cc.product_id ORDER BY cc.calendar_date) AS sales_cumulative_current_year,
SUM(pyt.sale_quantity_sum) OVER(PARTITION BY cc.store_id, cc.product_id ORDER BY cc.calendar_date) AS sales_cumulative_sum_previous_year
FROM comprehensive_combinations cc
LEFT JOIN current_year_transactions cyt ON cc.store_id = cyt.store_id AND cc.product_id = cyt.product_id AND cc.calendar_date = cyt.transaction_date
LEFT JOIN previous_year_transactions pyt ON cc.store_id = pyt.store_id AND cc.product_id = pyt.product_id AND cc.calendar_date = DATE_ADD(pyt.transaction_date, INTERVAL 1 YEAR)
LEFT JOIN product_data pd ON cc.product_id = pd.product_id
)
SELECT *
FROM aggregated_transactions
ORDER BY store_id, product_id, calendar_date;
