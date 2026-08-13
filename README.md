# 💰 Finance Transactions Analytics Dashboard

An end-to-end data analytics project covering the full pipeline — from raw, messy data to a polished Power BI dashboard — using **Python, SQL, and Power BI**.

## 📌 Project Overview

This project analyzes 50,000+ bank transaction records and 5,000 customer profiles to uncover spending patterns, transaction status trends, fraud/risk indicators, and customer segment behavior. It simulates a real analyst workflow: clean the data, analyze it, then visualize it for business decision-making.

**Tools used:** Python (Pandas) → MySQL → Power BI

---

## 🧰 Tech Stack

| Phase | Tool | Purpose |
|---|---|---|
| Data Cleaning | Python (Pandas, Google Colab) | Clean and feature-engineer raw CSV data |
| Analysis | MySQL Workbench | Aggregations, window functions, CTEs |
| Visualization | Power BI Desktop | Interactive dashboard with drill-through |

---





## 🐍 Phase 1: Python Data Cleaning

Cleaned two raw datasets (`customers.csv`, `finance_transactions.csv`) using Pandas. Key issues identified and resolved:

- **24 missing `fee_amount` values** — analyzed the value distribution first (0 was already the most common fee) before filling missing entries with 0, rather than guessing or using the mean.
- **Category-splitting typo** — `"M@bile App"` and `"Mobile App"` were being treated as separate categories due to a single bad character; merged into one consistent value.
- **Duplicate transaction IDs with conflicting data** — found 69 duplicate `transaction_id`s, but one pair had different `fee_amount` values (0.00 vs 21.19). Traced the records to identify which one was the actual data-entry error before removing it, instead of dropping both or picking one at random.
- **8 negative transaction amounts** — investigated for a business logic pattern (found none across transaction types), confirmed as entry errors, and corrected to absolute values.
- **Referential integrity check** — verified every `customer_id` in the transactions table exists in the customers table (0 orphan records), so downstream joins and relationships stay clean.


---

## 🗄️ Phase 2: SQL Analysis

Loaded the cleaned data into MySQL and wrote queries across six sections:

1. **Basic Aggregation** — transaction totals, status breakdown, fraud summary
2. **Customer-Level Analysis** — top customers, segment-wise averages
3. **Time-Based Analysis** — month-wise trends, month-over-month comparison (`LAG()`)
4. **Window Functions** — `RANK()`, running totals (`SUM() OVER`)
5. **CTEs** — high-value customer identification
6. **Risk/Business Insights** — fraud percentage by merchant category, channel-wise fraud rate


---

## 📊 Phase 3: Power BI Dashboard

Built a two-page interactive dashboard on top of the cleaned data:

- **Data Modeling** — star schema with a dedicated Date table (via `CALENDAR()`), proper relationships between Customers (dimension) and Transactions (fact)
- **DAX Measures** — Total Amount, Total Fees, Total Tax, Avg Transaction Value, and a dynamic metric selector (switch between measures via a field parameter)
- **Overview Page** — KPI cards,transaction status donut, customer segment and state-wise breakdowns, gender split
- **Transactions Page** — detailed drill-through table, filtered automatically when drilling in from the Overview page (e.g. clicking a specific state)

### Dashboard Preview

**Overview Page**
<img width="826" height="425" alt="Screenshot 2026-08-13 132850" src="https://github.com/user-attachments/assets/e1584c17-0f11-4d7f-a16d-9f43aa3efed3" />

**Transactions Drill-Through Page**
<img width="700" height="436" alt="Screenshot 2026-08-13 133121" src="https://github.com/user-attachments/assets/4605e6d6-5a17-4a6d-b0ae-3ef7c3b84a8a" />


---

## 🔑 Key Takeaway

Data cleaning isn't just running `.dropna()` and `.drop_duplicates()` — it's about understanding *why* an issue exists before deciding *how* to fix it. Every cleaning decision in this project (fee imputation, duplicate resolution, negative value correction) was made after first investigating the pattern behind the issue, not applying a default fix blindly.

---

## 👤 Author

**Astha Nagpal**
Aspiring Data Analyst |
[LinkedIn](https://www.linkedin.com/in/asthanagpal/) · [GitHub](https://github.com/Aasthaanagpall)
