-- Purpose: Exploratory & Advanced Analysis for Power BI Dashboard
CREATE DATABASE bank_analysis_project;
USE bank_analysis_project;

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    second_name VARCHAR(50),
    gender VARCHAR(10),
    date_of_birth VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50),
    occupation VARCHAR(50),
    customer_segment VARCHAR(20),
    annual_income DECIMAL(12,2),
    join_date VARCHAR(20),
    age INT,
    tenure_years INT
);

CREATE TABLE transactions (
    transaction_id VARCHAR(15) PRIMARY KEY,
    transaction_date VARCHAR(20),
    account_id VARCHAR(10),
    customer_id VARCHAR(10),
    transaction_type VARCHAR(30),
    channel VARCHAR(30),
    merchant_category VARCHAR(30),
    amount DECIMAL(12,2),
    fee_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    currency VARCHAR(5),
    transaction_status VARCHAR(20),
    is_fraud VARCHAR(5),
    risk_score INT,
    reference_no VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

select * from customers limit 5;
select * from transactions limit 5;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM transactions;

SET SQL_SAFE_UPDATES = 0;

UPDATE customers
SET date_of_birth = STR_TO_DATE(date_of_birth, '%d-%m-%Y'),
    join_date = STR_TO_DATE(join_date, '%d-%m-%Y');

ALTER TABLE customers 
MODIFY date_of_birth DATE,
MODIFY join_date DATE;

SELECT date_of_birth, join_date FROM customers LIMIT 5;
SELECT transaction_date FROM transactions LIMIT 5;

select * from transactions limit 5;

-- Basic Aggregation Queries
-- 1 - Total transactions count, total amount, avg amount
Select 'Total_transactions' as 'MeasureName' , count(transaction_id) as 'MeasureValues' from transactions
Union all
Select 'Sum of Transactions' as 'MeasureName', round(sum(amount),2) as 'MeasureValues' from transactions
Union all
Select 'Avg Transactions Amount' as 'MeasureName' , round(avg(amount),2) as 'MeasureValues' from transactions;

-- 2 - Count and total amount grouped by transaction statua
Select transaction_status , count(transaction_id) , sum(amount) from transactions group by transaction_status;

-- 3 - Identifies which transaction types (Deposit, Loan EMI, Transfer etc.) drive the most volume
Select transaction_type, sum(amount) from transactions group by transaction_type order by sum(amount) desc;

-- 4 - count and total amount flagged as fraud
select count(transaction_id)  , sum(amount) from transactions where is_fraud = 'Yes';

-- Customer Level Analysis
-- 5 -  customer-level spend analysis
Select t.customer_id , count(t.transaction_id), sum(t.amount)
from transactions as t
left join customers as c
on t.customer_id  = c.customer_id
group by t.customer_id;

-- 6 - highest-value customers 
Select concat(first_name , ' ' ,second_name) as name , sum(t.amount) as total
from transactions as t
left join customers as c
on t.customer_id  = c.customer_id
group by t.customer_id 
order by sum(amount) desc
limit 10;

-- 7 -  Compares spending behavior across segments (Retail, Premium, SME, Corporate, Wealth)
Select c.customer_segment, avg(t.amount) as average_per_segment
from customers as c
left join transactions as t
on c.customer_id = t.customer_id 
group by customer_segment;

-- Time based analysis 
-- 8 - Transaction volume across each Year-Month
SELECT YEAR(transaction_date) AS yr, MONTH(transaction_date) AS mn, SUM(amount) AS total_amount
FROM transactions
GROUP BY YEAR(transaction_date), MONTH(transaction_date)
ORDER BY yr, mn;

-- 9 - Month-over-Month Comparison (Current vs Previous Month Amount)
WITH monthly_totals AS (
    SELECT YEAR(transaction_date) AS yr, 
           MONTH(transaction_date) AS mn, 
           SUM(amount) AS total_amount
    FROM transactions
    GROUP BY YEAR(transaction_date), MONTH(transaction_date)
)
SELECT 
    yr, 
    mn, 
    total_amount,
    LAG(total_amount) OVER (ORDER BY yr, mn) AS previous_month_amount
FROM monthly_totals
ORDER BY yr, mn;


-- Window functions
-- 10 - customer ranking based on total transaction amount
Select concat(first_name , ' ' ,second_name) as name , sum(t.amount)  as total , rank() over(order by sum(t.amount) desc) as rnk
from transactions as t
left join customers as c
on t.customer_id  = c.customer_id
group by t.customer_id 
order by sum(amount) desc;

-- 11 - Running Total of Amount per Customer
SELECT customer_id, transaction_date, amount,
       SUM(amount) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS running_total
FROM transactions
ORDER BY customer_id, transaction_date;

-- CTE-Based
-- 12 - High Value Customers
WITH customer_spend AS (
    SELECT customer_id, SUM(amount) AS total_spend
    FROM transactions
    GROUP BY customer_id
)
SELECT customer_id, total_spend
FROM customer_spend
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_spend)
ORDER BY total_spend DESC;

-- 13 - Fraud Percentage by Merchant Category 
WITH fraud_stats AS (
    SELECT merchant_category,
           COUNT(*) AS total_txns,
           SUM(CASE WHEN is_fraud = 'Yes' THEN 1 ELSE 0 END) AS fraud_txns
    FROM transactions
    GROUP BY merchant_category
)
SELECT merchant_category, total_txns, fraud_txns,
       ROUND(fraud_txns * 100.0 / total_txns, 2) AS fraud_percent
FROM fraud_stats
ORDER BY fraud_percent DESC;

-- 14 - Risk Score Categorization 
SELECT 
    CASE 
        WHEN risk_score < 30 THEN 'Low'
        WHEN risk_score BETWEEN 30 AND 70 THEN 'Medium'
        ELSE 'High'
    END AS risk_category,
    COUNT(*) AS txn_count
FROM transactions
GROUP BY risk_category;


