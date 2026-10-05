# Adventure Works Sales Analysis – Power BI, SQL and Excel

## Project Overview

This project is an end-to-end **Power BI, SQL, and Excel sales analytics solution** built using the **AdventureWorksDW2019** data warehouse. The goal is not simply to create charts, but to build a reliable analytical model that answers business questions at the correct level of detail and produces metrics that can be independently validated.

The solution combines **Power BI data modeling and DAX, SQL validation, Excel reconciliation, business analysis, troubleshooting, and report design** to analyze Internet (B2C) and Reseller (B2B) sales across products, customers, salespeople, profitability, and geographic territories.

A dashboard is only as useful as the data and logic behind it. Anybody can place fields on a chart, but a polished visualization built on an incorrect model or unvalidated metric can lead to incorrect business conclusions. For that reason, this project emphasizes three things throughout the development process:

- **Correct data modeling** so dimensions filter facts at the intended business grain.
- **Independent SQL validation** so Power BI KPIs and analytical results can be reconciled to source-level calculations.
- **Excel reconciliation and review** so SQL outputs can be organized, compared with Power BI results, and investigated at a detailed level.
- **Investigation and troubleshooting** when results do not make business or mathematical sense.

Understanding the business question comes before choosing the visual. Validation comes before trusting the metric.

---

## Business Objectives

The report was designed to answer questions such as:

- How are total sales performing compared with the prior year?
- How much revenue comes from Internet sales versus Reseller sales?
- Are sales, orders, units, customers, and average selling prices increasing or declining?
- Which products and product categories drive the most revenue?
- Which products are newly sold, consistently sold, or no longer sold compared with the prior year?
- How profitable are Internet and Reseller channels?
- Which customers generate the most Internet sales?
- How many customers are new, returning, retained, or lost?
- Which salespeople generate the most Reseller revenue?
- Which resellers and territories contribute most to salesperson performance?
- Which geographic territories have the strongest sales growth and profitability?
- Are high-sales territories necessarily high-margin territories?
- Where do negative margins or unusual YoY movements require further investigation?

---

## Technology Stack

- **Power BI Desktop**
- **DAX**
- **Power Query**
- **SQL / T-SQL**
- **AdventureWorksDW2019**
- **Relational / Star Schema Modeling**
- **Microsoft Excel** for reconciliation, detailed validation review, and side-by-side comparison of SQL and Power BI results

---

## Data Model

The semantic model uses dimension-to-fact relationships designed around the business grain of each fact table.

### Dimension Tables

- `DimDate`
- `DimCustomer`
- `DimProduct`
- `DimProductSubcategory`
- `DimProductCategory`
- `DimSalesTerritory`
- `DimEmployee`
- `DimReseller`

### Fact Tables

- `FactInternetSales` — B2C / individual customer transactions
- `FactResellerSales` — B2B / reseller transactions

### Core Relationships

- `DimDate[DateKey]` → `FactInternetSales[OrderDateKey]`
- `DimDate[DateKey]` → `FactResellerSales[OrderDateKey]`
- `DimProduct[ProductKey]` → both sales fact tables
- `DimCustomer[CustomerKey]` → `FactInternetSales[CustomerKey]`
- `DimEmployee[EmployeeKey]` → `FactResellerSales[EmployeeKey]`
- `DimReseller[ResellerKey]` → `FactResellerSales[ResellerKey]`
- `DimSalesTerritory[SalesTerritoryKey]` → both sales fact tables
- `DimProductCategory` → `DimProductSubcategory` → `DimProduct`

The model primarily uses **single-direction, one-to-many relationships** from dimensions to facts. Order Date is used as the primary active date relationship for time intelligence.

---

## Report Pages

### 01 – Executive Summary

Provides a high-level view of overall business performance across Internet and Reseller channels.

Key KPIs include:

- Total Sales
- Internet Sales
- Reseller Sales
- Gross Profit
- Profit Margin %
- Total Orders
- Units Sold
- Internet Customers
- Active Resellers
- Average Selling Price
- Internet Average Order Value
- Reseller Average Order Value
- Total Products Sold
- Prior-year values and YoY changes

The page also highlights monthly trends, category and subcategory performance, leading products, customers, and resellers.

### 02 – Profitability Analysis

Examines whether sales growth is translating into profitable growth.

Analysis includes:

- Combined Product Cost
- Combined Gross Profit
- Combined Profit Margin
- Internet Gross Profit and Margin
- Reseller Gross Profit and Margin
- Prior-year profitability
- YoY Gross Profit change
- Margin percentage-point change
- Gross Profit by month
- Gross Profit by category, subcategory, and product
- Product Sales vs Profit Margin analysis
- Bottom-margin products
- Channel profitability comparisons

This page demonstrates why revenue alone is insufficient. For example, a channel can grow sales while simultaneously experiencing margin deterioration or moving from profit to loss.

### 03 – Product & Sales

Analyzes product-level sales performance across both sales channels.

Key metrics include:

- Total Products Sold
- Internet Products Sold
- Reseller Products Sold
- Total Sales
- Units Sold
- Average Selling Price
- Products Newly Sold vs Prior Year
- Products Not Sold vs Prior Year

Visuals compare current-year and prior-year monthly sales, leading products, product categories, subcategories, Internet vs Reseller product sales, and product lifecycle activity.

Product lifecycle logic distinguishes products sold in both periods, newly sold products, and products sold in the prior year but not the current year.

### 04 – Customer Performance

Focuses specifically on **Internet / B2C customers**.

Key measures include:

- Internet Customers
- New Customers
- Returning Customers
- Lost Customers
- New Customer Rate
- Customer Retention Rate
- Customer Loss Rate
- Average Revenue per Customer
- Customer Sales and Order YoY metrics

The page includes monthly customer activity, Top 5 customers, geography, customer AOV, customer lifecycle, and customer-level detail.

Customer analysis is performed at the **CustomerKey grain**, not name alone. During validation, duplicate customer names were identified. A customer display value combining `CustomerKey` and customer name was therefore used so separate customers with identical names are not incorrectly aggregated into one visual category.

### 05 – Salesperson Performance

Analyzes B2B / Reseller sales by salesperson.

Key metrics include:

- Reseller Sales
- Reseller Sales YoY %
- Reseller Orders
- Reseller Orders YoY %
- Reseller Units Sold
- Active Resellers
- Active Resellers YoY %
- Sales per Salesperson
- Reseller Average Order Value
- Salesperson Sales Contribution %

Visuals include monthly Reseller sales, Top 5 salespeople, active resellers by salesperson, salesperson contribution, territory sales, and detailed CY/PY performance.

### 06 – Region & Territory

Analyzes geographic performance across Internet and Reseller channels.

Analysis includes:

- Combined Sales by Territory
- Prior-Year Sales
- Sales YoY %
- Internet vs Reseller Sales by Territory
- Sales by Territory Group
- Combined Gross Profit
- Profit Margin % by Territory
- Orders and Units by Territory
- Territory Sales Contribution %
- Country / Region mapping

Territory-level SQL validation was especially important because overall totals can reconcile while a visual still contains the wrong filter context. The final territory margin analysis reconciles sales and gross profit at each territory before calculating margin.

### 07 – Salesperson Drillthrough

Provides a focused detailed analysis for an individual salesperson selected from the Salesperson Performance page.

The drillthrough page includes:

- Reseller Sales
- Sales YoY %
- Reseller Orders
- Orders YoY %
- Units Sold
- Units YoY %
- Active Resellers
- Reseller AOV
- Monthly CY vs PY Reseller Sales
- Top Resellers
- Product Category performance
- Top Products
- Gross Profit by Product Category
- Salesperson detail matrix

This allows users to move from summary salesperson performance to a more detailed root-cause view without overcrowding the primary report page.

---

## DAX and Analytical Logic

Reusable DAX measures were developed rather than embedding business logic directly into individual visuals.

Examples include:

```DAX
Combined Sales =
[Internet Sales] + [Reseller Sales]
```

```DAX
Combined Sales YoY % =
DIVIDE(
    [Combined Sales] - [PY Combined Sales],
    [PY Combined Sales]
)
```

```DAX
Combined Gross Profit =
[Internet Gross Profit] + [Reseller Gross Profit]
```

```DAX
Combined Profit Margin % =
DIVIDE(
    [Combined Gross Profit],
    [Combined Sales]
)
```

```DAX
Combined Margin Change =
[Combined Profit Margin %] - [PY Combined Profit Margin %]
```

Margin changes are presented as **percentage-point changes** where appropriate rather than treating every percentage metric as ordinary YoY growth.

Time-intelligence measures use the marked `DimDate` table and `SAMEPERIODLASTYEAR()` to calculate prior-year results.

---

## SQL Validation and Reconciliation

SQL was used as an independent validation layer rather than assuming that a Power BI result was correct because the visual rendered successfully.

Validation covered:

- Total Sales
- Internet Sales
- Reseller Sales
- Orders
- Units Sold
- Gross Profit
- Product Cost
- Profit Margin
- Average Selling Price
- Average Order Value
- Internet Customers
- New / Returning / Lost Customers
- Customer retention and loss rates
- Active Resellers
- Product counts
- Product lifecycle metrics
- Top products
- Top customers
- Top salespeople
- Salesperson contribution
- Territory sales
- Territory gross profit
- Territory profit margin
- Current-year and prior-year comparisons

### Example 2013 KPI Reconciliation

| KPI | Validated Result |
|---|---:|
| Total Sales | $49.93M |
| Internet Sales | $16.35M |
| Reseller Sales | $33.57M |
| Gross Profit | $6.27M |
| Profit Margin | 12.57% |
| Total Orders | 22,997 |
| Units Sold | 156,459 |
| Internet Customers | 17,429 |
| Active Resellers | 489 |
| Average Selling Price | $319.10 |
| Internet AOV | $768.08 |
| Reseller AOV | $19.66K |
| Total Products Sold | 183 |

The Power BI results were reconciled against SQL before considering the pages complete.

---


## Excel Validation and Review

Excel was used as an important validation and investigation layer alongside SQL and Power BI. SQL independently calculated expected results from the underlying AdventureWorks data, while Excel provided a practical environment for organizing those query outputs and comparing them with Power BI KPIs, rankings, matrices, and detailed results.

Excel was particularly useful for:

- Reviewing SQL validation outputs in a familiar tabular format
- Comparing Power BI results with independently calculated SQL results
- Checking CY, PY, and YoY values side by side
- Reviewing customer, product, salesperson, and territory-level detail
- Identifying differences in totals, rankings, aggregation grain, and filter context
- Documenting validation results before considering a report page complete

This created a complementary analytical workflow: **SQL calculated and validated the expected results, Excel supported reconciliation and investigation, and Power BI delivered the semantic model, DAX calculations, interactive analysis, and final reporting experience.**

---

## Validation Findings and Troubleshooting

Validation was not treated as a final checkbox. It actively identified problems that could otherwise have produced misleading analysis.

### 1. Incorrect KPI Measures

Several KPI cards initially displayed the correct CY and PY values but referenced the wrong YoY measure. Independent calculations exposed the discrepancy. The cards were corrected so the displayed YoY values reconcile mathematically with the underlying CY and PY results.

### 2. Slicer / Visual Interactions

A customer visual initially included transactions outside the selected year even though the date relationship and Year slicer were correct. Investigation showed that the visual interaction was not applying the Year slicer as intended.

This demonstrated that a correct semantic model alone does not guarantee that every visual is operating under the expected filter context.

### 3. Duplicate Customer Names and Business Grain

Two different `CustomerKey` values were found for customers sharing the same name. A visual using customer name alone combined their sales and changed the Top Customer ranking.

The solution was to preserve the true customer grain by using a display field such as:

```text
CustomerKey - Customer Name
```

This aligned Power BI rankings with SQL grouped at the CustomerKey level.

### 4. Territory Profitability

An initial territory profitability visual produced margins that did not reconcile with SQL even though the overall report margin was correct. A diagnostic matrix was created containing territory sales, gross profit, and margin. Once the visual filter context was corrected, every territory reconciled to SQL, including negative-margin territories.

### 5. Non-Additive Distinct Counts

Metrics such as Active Resellers are distinct counts and should not automatically be summed across salesperson rows. Validation logic therefore distinguishes additive measures such as Sales and Units from non-additive measures such as distinct reseller counts.

---

## Why Validation Matters

Building a dashboard without correct modeling, investigation, and validation is not enough.

Modern BI tools make it relatively easy to create attractive charts. The harder and more valuable analytical work is determining whether those charts answer the correct business question and whether the numbers can be trusted.

A report can look polished and still be wrong because of:

- Incorrect relationships
- Wrong data grain
- Duplicate business entities
- Incorrect DAX measures
- Inappropriate denominators
- Disabled visual interactions
- Unexpected filter context
- Incorrect aggregation
- Distinct counts treated as additive metrics
- CY/PY measures evaluated under different contexts

For this project, unexpected results were investigated rather than accepted. SQL was used to independently reproduce key metrics, Excel was used to review and reconcile the validation outputs against Power BI, and discrepancies were traced back to their underlying causes.

**Anybody can build a chart. The analytical value comes from understanding the business question, building the correct data model, defining the metric correctly, investigating unexpected results, and proving that the final number is reliable.**

That validation and troubleshooting process is as important as the dashboard itself.

---

## Key Analytical Insights

The report supports findings such as:

- Total sales increased significantly year over year, but channel performance differed substantially.
- Internet Sales and Reseller Sales have very different growth and profitability profiles.
- Overall Gross Profit improved even while Reseller Gross Profit moved into negative territory in the selected period.
- Revenue growth does not automatically imply margin improvement.
- Product sales are concentrated among a relatively small number of leading products.
- Customer acquisition, retention, and loss provide different perspectives on customer performance and require different denominators.
- Salesperson performance varies materially across sales, orders, units, reseller coverage, and contribution.
- Territory sales ranking and territory profitability ranking are not the same.
- Some territories can generate substantial revenue while producing very low or negative gross margins.

These findings reinforce the importance of analyzing **drivers and profitability**, not simply reporting topline sales.

---

## Report Navigation and User Experience

The report uses consistent page navigation across the main analytical pages:

1. Executive Summary
2. Profitability Analysis
3. Product & Sales
4. Customer Performance
5. Salesperson Performance
6. Region & Territory

The Salesperson Drillthrough page is accessed contextually from salesperson analysis rather than being included as a primary navigation destination.

Common slicers include:

- Year
- Country
- Region
- Product Category
- Product Subcategory

The design intentionally balances executive-level summaries with the ability to investigate detailed drivers.

---

## Repository Structure

```text
AdventureWorks-Sales-Analysis/
│
├── README.md
│
├── PowerBI/
│   └── AdventureWorks_Sales_Analysis.pbix
│
├── SQL/
│   └── Validation_Queries.sql
│
├── Excel/
│   └── AdventureWorks_Data_Validation.xlsx
│
├── Screenshots/
│   ├── 01_Executive_Summary.png
│   ├── 02_Profitability_Analysis.png
│   ├── 03_Product_and_Sales.png
│   ├── 04_Customer_Performance.png
│   ├── 05_Salesperson_Performance.png
│   ├── 06_Region_and_Territory.png
│   └── 07_Salesperson_Drillthrough.png
```

---

## Future Enhancements

Potential future additions include:

- Expand the SQL validation library with page-level reconciliation queries.
- Add automated validation checks comparing expected and reported KPI results.
- Add additional profitability root-cause analysis.
- Add product and customer segmentation.
- Add dynamic metric selection using field parameters.
- Add report tooltips for deeper contextual analysis.
- Publish the report to Power BI Service where appropriate.

---

## Project Takeaway

This project demonstrates more than Power BI visualization skills. It shows how Power BI, SQL, and Excel can work together as complementary analytical tools. It represents an end-to-end analytical workflow:

**Business Question → Data Model → Metric Definition → DAX → Visualization → SQL Validation → Excel Reconciliation → Investigation → Troubleshooting → Business Insight**

The objective is not to produce the largest number of visuals. The objective is to produce a report where the metrics are understandable, explainable, reproducible, and trustworthy.

---

## Author

**Yikum Shiferaw**

Data Analytics | SQL | Power BI | DAX | Python | PySpark | Databricks
