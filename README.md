# Indian E-Commerce Sales & Profitability Analysis

End-to-end data analytics project turning raw Indian e-commerce order data into an interactive Power BI dashboard and a set of business insights on revenue, profitability, customers, geography, products, and target achievement.

**Tech stack:** Python (Pandas) • MySQL • SQL (Views & Stored Procedures) • Power BI • DAX

---

## Project Snapshot

| Metric | Value |
|---|---|
| Revenue analyzed | ₹431,502 |
| Profit analyzed | ₹23,955 |
| Overall profit margin | 5.55% |
| Units sold | 5,615 |
| Unique customers | 332 |
| Analysis period | April 2018 – March 2019 |

**Executive takeaway:** Electronics is strongest for revenue and target achievement; Clothing is strongest for total profit and margin; Furniture needs profitability attention; Tables are a major loss area; and repeat customers show substantially higher value per customer than one-time customers.

---

## Table of Contents

1. [Business Problem & Objectives](#business-problem--objectives)
2. [Dataset & Data Structure](#dataset--data-structure)
3. [Workflow](#workflow)
4. [Python Data Cleaning](#python-data-cleaning)
5. [SQL Database & Analysis](#sql-database--analysis)
6. [SQL Views & Stored Procedures](#sql-views--stored-procedures)
7. [Power BI Data Model](#power-bi-data-model)
8. [DAX Measures](#dax-measures)
9. [Dashboard Design & Visuals](#dashboard-design--visuals)
10. [Key Business Findings](#key-business-findings)
11. [Recommendations](#recommendations)
12. [Lessons Learned](#lessons-learned)
13. [Repository Structure](#repository-structure)

---

## Business Problem & Objectives

The business needs a clear view of where sales are coming from, where profit is being generated or lost, which customers are valuable, how performance changes over time, and whether actual sales are meeting planned targets.

**Objectives:**
- Clean and validate the raw datasets before analysis
- Calculate revenue, profit, profit margin, units sold and customer counts
- Compare performance across categories and sub-categories
- Identify loss-making products and transactions
- Analyze state-level revenue, profit and profit margin
- Study monthly revenue and profit trends
- Compare repeat and one-time customers
- Compare actual sales against category and monthly targets
- Build reusable SQL views and selected parameterized procedures
- Build an interactive Power BI dashboard with DAX measures

**Analytical approach:** Raw Data → Cleaning → Validation → EDA → MySQL → SQL Analysis → Views/Procedures → Data Model → DAX → Power BI Dashboard → Business Insights

---

## Dataset & Data Structure

**List of Orders** — `Order ID`, `Order Date`, `CustomerName`, `State`, `City`

**Order Details** — `Order ID` (join key), `Amount`, `Profit`, `Quantity`, `Category`, `Sub-Category`

**Sales Target** — `Month of Order Date`, `Category`, `Target`

> ⚠️ **Grain note:** Order Details is at line-item level, while Sales Target is at month + category level. Directly joining target rows to every transaction detail duplicates targets. This project aggregates actual sales to month + category **before** comparing to target.

---

## Workflow

```
Raw CSVs → Python cleaning/validation → MySQL load → SQL analysis
   → Views & stored procedures → Power BI data model → DAX measures
   → Interactive dashboard → Business insights
```

---

## Python Data Cleaning

- Removed fully blank rows from List of Orders (560 → 500 valid rows) using `dropna(how='all')`
- Validated no missing values or exact duplicate rows in Order Details (1,500 rows) and Sales Target (36 records)
- Retained repeated Order IDs in Order Details (multiple line items per order are expected)
- Converted date fields to proper datetime types:
  - `Order Date`: `DD-MM-YYYY`
  - `Month of Order Date`: `MMM-YY` (e.g. `Apr-18`)

---

## SQL Database & Analysis

Cleaned DataFrames were loaded into a MySQL database (`E_Commerce`) via SQLAlchemy into `list_order`, `orders`, and `sales_target` tables.

**Core SQL techniques used:** `SELECT`/`WHERE` filtering, `GROUP BY` + aggregates, `HAVING`, `JOIN`, `COUNT(DISTINCT)`, `CASE`, `ROUND`/`DATE_FORMAT`, and CTEs for grain-aware target analysis.

```sql
SELECT
    Category,
    SUM(Amount) AS total_revenue,
    SUM(Profit) AS total_profit,
    SUM(Quantity) AS total_quantity
FROM orders
GROUP BY Category
ORDER BY total_revenue DESC;
```

---

## SQL Views & Stored Procedures

**Views** (reusable business logic for recurring analysis):
- `category_performance`
- `state_performance`
- `monthly_performance`
- `customer_performance`
- `target_vs_actual`

**Stored procedures** (used selectively, where parameters add value):
```sql
CALL GetSalesByState('Maharashtra');
CALL GetSalesByDate('2018-04-01', '2018-06-30');
```

**Design rule:** use a *view* for a reusable result set, and a *stored procedure* when the logic benefits from parameters or procedural steps.

---

## Power BI Data Model

**Tables:** `e_commerce list_order`, `e_commerce orders`, `e_commerce target`, `MonthTable`, `CategoryTable`, `_measures` (independent measures table)

**Relationships:**
```
e_commerce list_order (1) → (*) e_commerce orders   [Order ID]
MonthTable → e_commerce list_order
MonthTable → e_commerce target
CategoryTable → e_commerce orders
CategoryTable → e_commerce target
```

`MonthTable` and `CategoryTable` act as bridge dimensions so target values (stored at month + category grain) don't get duplicated when joined to transaction-level data.

---

## DAX Measures

```dax
Total Revenue = SUM('e_commerce orders'[Amount])
Total Profit = SUM('e_commerce orders'[Profit])
Total Units Sold = SUM('e_commerce orders'[Quantity])
Total Customers = DISTINCTCOUNT('e_commerce list_order'[CustomerName])

Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0)

Actual Revenue = SUM('e_commerce orders'[Amount])
Sales Target = SUM('e_commerce target'[Target])
Target Achievement % = DIVIDE([Actual Revenue], [Sales Target], 0)
Target Variance = [Actual Revenue] - [Sales Target]
```

> Format `Profit Margin %` and `Target Achievement %` as **Percentage** in Power BI rather than multiplying by 100 in the DAX expression. `DIVIDE()` is used throughout for safe handling of zero/invalid denominators.

**Customer Type** (calculated column, needed for legend/slicer use):
```dax
Customer Type =
VAR OrderCount =
    CALCULATE(
        DISTINCTCOUNT('e_commerce list_order'[Order ID]),
        ALLEXCEPT('e_commerce list_order', 'e_commerce list_order'[CustomerName])
    )
RETURN IF(OrderCount > 1, "Repeat", "One-time")
```

---

## Dashboard Design & Visuals

| Page | Purpose | Main Visuals |
|---|---|---|
| Executive Sales Overview | Overall business performance | KPI cards, revenue by category, monthly revenue/profit, top states |
| Profitability & Customer Analysis | Profit and customer behavior | Sub-category profit, margins, customers, repeat vs one-time |
| Target & Performance | Plan vs actual performance | Actual vs target, achievement %, variance, monthly/category analysis |

**Recommended slicers:** Date (Order Date), State, Category, Sub-Category, Customer Type — kept intentionally minimal; Customer Name is excluded from the main dashboard.

**Visual story:** overall financial performance → category performance → monthly trend → geography → sub-category profitability → customer behavior → target achievement → key insights.

**Visible components:** Revenue / Profit / Quantity / Profit Margin / Total Customer KPI cards, Revenue by Category donut, Revenue & Profit by Month trend, Top Products/Sub-Categories chart, Actual vs Target Revenue, Top 5 States by Profit map, Repeat vs One-Time Customer Revenue & Profit, Top 10 Customers by Revenue, and Category/State filter controls.

---

## Key Business Findings

| Area | Finding |
|---|---|
| Revenue vs Profit | Electronics leads revenue, but Clothing leads total profit and margin |
| Furniture | ₹127.18K revenue but only ₹2.30K profit (1.81% margin) |
| Tables | Largest negative sub-category at -₹4.01K profit |
| Electronic Games | Also negative overall profit at -₹1.24K, with 40 loss-making orders |
| Geography | Madhya Pradesh leads revenue; Maharashtra leads absolute profit; West Bengal has the highest state margin (17.75%) |
| Monthly | June 2018 is the worst profit month at -₹4,970 |
| Targets | Electronics exceeds target at 128.11% (best monthly: Dec at 206.22%); Clothing is lowest at 79.92% (weakest monthly: Jul at 21.29%) |
| Customers | Repeat customers generate ~2.78× more revenue and ~5.79× more profit per customer than one-time customers |
| Volume vs Profit | Saree sold 782 units for only ₹352 profit; Printers sold 291 units for ₹5,964 profit |

---

## Recommendations

- Review Furniture profitability — a ₹127.18K revenue category producing only ₹2.30K profit
- Investigate Tables at the transaction level — the largest negative overall profit sub-category
- Review Electronic Games — 40 loss-making orders and negative overall profit
- Strengthen repeat-customer retention given their substantially higher value
- Improve Clothing target achievement, especially the July shortfall
- Investigate June 2018 by drilling from month → category → sub-category before making pricing/product decisions
- Always monitor profitability alongside sales, not sales alone
- Keep target analysis at the correct grain (month + category) to avoid duplicated target values

> These recommendations are based on observed patterns in the dataset. Specific causes (discounts, supplier costs, pricing strategy) are not confirmed by the data and should be investigated separately.

---

## Lessons Learned

- **Blank rows:** List of Orders contained 60 fully blank rows, corrected to 500 valid rows
- **Duplicate Order IDs:** Expected — multiple line items per order, not data quality issues
- **Target duplication:** First target calculation over-counted because targets were joined at transaction grain; fixed by aggregating actuals to month + category first
- **Power BI relationships:** Bridge dimensions for Month and Category were required to prevent target duplication
- **Customer Type:** Implemented as a calculated column (not a measure) since it's needed as a categorical value for legends/slicers
- **Core takeaway — grain awareness:** before joining two tables, understand what one row represents in each table; most SQL/Power BI errors trace back to mixing levels of detail

---

## Repository Structure

```
├── data/
│   ├── List_of_Orders.csv
│   ├── Order_Details.csv
│   └── Sales_target.csv
├── sql/
│   └── E_Commerce.sql          # schema, queries, views, stored procedures
├── python/
│   └── data_cleaning.ipynb     # Pandas cleaning & EDA
├── powerbi/
│   └── E_Commerce_Dashboard.pbix
├── assets/
│   └── dashboard_screenshot.png
└── README.md
```

---

## Skills Demonstrated

Python/Pandas data cleaning • Exploratory data analysis • MySQL database handling • SQL joins & aggregations • CTEs and grain-aware analysis • SQL views & stored procedures • Power BI data modeling • DAX measures • Business KPI design • Dashboard storytelling • Root-cause drill-down analysis

---

## Conclusion

This project demonstrates a complete analytics workflow from raw data to business decision support — not stopping at total sales, but investigating where revenue came from, where profit was generated, where losses occurred, which customers were valuable, how states and months performed, and whether sales targets were achieved.

**Final takeaway:** A good business dashboard should not simply show what happened — it should help explain where performance is strong, where it's weak, why further investigation is needed, and what the business should monitor next.
