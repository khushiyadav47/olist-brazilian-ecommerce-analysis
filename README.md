# Olist Brazilian E-Commerce Analysis

End-to-end analysis of Brazilian e-commerce (Olist) data using **Python** and **PostgreSQL**: delivery performance, customer repurchase behaviour and review scores.

---

## Business Questions

1. How many customers come back and buy again?
2. How often are orders delivered late, and which states are the worst?
3. How are customers rating their orders?
4. Does late delivery hurt review scores? *(see section 4)*

## Tools Used

| Purpose | Tool |
|---|---|
| Data cleaning and feature creation | Python (pandas), Google Colab |
| Analysis and querying | PostgreSQL, pgAdmin 4 |
| Dashboard | Power BI / Tableau *(in progress)* |

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle). Orders from Sep 2016 to Oct 2018.

Tables used till now: `olist_orders_dataset`, `olist_customers_dataset`, `olist_order_reviews_dataset`. 
The raw files are not uploaded here because of their size.

---

## Data Cleaning

**Orders and customers** (`python-notebooks/01_orders_customers_cleaning.ipynb`)
- Converted all date columns to datetime.
- Created a `delivery_status` column (early, on-time, slightly late, late) by comparing actual and estimated delivery dates.
- Found 6 canceled orders that still had a delivery date. Set their delivery date and status to null so they are not counted as delivered.
- Found 8 delivered orders with a missing delivery date. Kept them (not guessed), they are left out of delay analysis.
- Used `customer_unique_id` (not `customer_id`) to identify real customers, since `customer_id` changes with every order.

**Reviews** (`python-notebooks/02_reviews_cleaning.ipynb`)
- Converted timestamp columns to datetime.
- Found 551 duplicate reviews for the same order. Kept only the latest review per order (99,224 → 98,673 rows) so that joins do not double count orders.
- Dropped the free-text comment columns (mostly empty, not needed for score analysis).

The cleaned tables were loaded into PostgreSQL and all analysis was done in SQL.

---

## Key Findings

### 1. Repurchase is very low
- **2,801 of 93,358** customers with a delivered order bought more than once, a repurchase rate of **3.0%**.
- 97% of customers buy only once, so customer retention is weak.

### 2. Delivery performance
- Of 96,470 delivered orders with a delivery date, **4,664** were late.
- **SP** has a large number of late orders (1,128) but a low late rate of **2.79%**, because it has the most orders.
- Among states with 1,000+ orders, the highest late rates are:

| State | Orders | Late orders | Late % |
|---|---|---|---|
| CE | 1,279 | 146 | 11.42 |
| RJ | 12,350 | 1,198 | 9.70 |
| BA | 3,256 | 303 | 9.31 |
| ES | 1,995 | 158 | 7.92 |
| PE | 1,593 | 124 | 7.78 |

- Counting late orders alone is misleading. The late **percentage** shows the real picture.
- RJ has the biggest impact because it combines a high late rate with a high order volume.

### 3. Review scores
- Average review score is **4.09 / 5**.
- 57.8% of reviews are 5 star, and about **14.7%** are 1 or 2 star.
- Average review score by state (states with 1,000+ reviews) ranges only from **3.86 to 4.18**.

### 4. Late delivery vs review score
> TODO: add results of the delivery_status vs average review score query here.

---

## Recommendations

- Focus delivery improvement on **CE and RJ** first (high late rate, and RJ has high volume).
- Treat states with few orders, such as AL (17.38% late on about 400 orders), carefully, since small volumes make percentages unstable.
- Work on repeat purchase (offers, follow-ups after delivery), since only 3% of customers return.

---

## Repository Structure

```
olist-brazilian-ecommerce-analysis/
├── README.md
├── python-notebooks/
│   ├── 01_orders_customers_cleaning.ipynb
│   └── 02_reviews_cleaning.ipynb
├── sql-queries/
│   ├── 01_orders_customers_analysis.sql
│   └── 02_reviews_analysis.sql
├── images/
└── reports/
```

## About

**Khushi Yadavl** | [LinkedIn](www.linkedin.com/in/khushiyadav76) 
