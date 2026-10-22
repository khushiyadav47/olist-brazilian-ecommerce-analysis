# Olist Brazilian E-Commerce Analysis

End-to-end analysis of Brazilian e-commerce (Olist) data using **Python** and **PostgreSQL**. The project covers delivery performance and review scores, and then digs into the main business problem: **why do about 97% of customers never buy again?**

---

## Business Questions

**Part 1: Delivery and reviews**
1. How often are orders delivered late, and which states are the worst?
2. How do customers rate their orders?
3. Does late delivery hurt review scores?

**Part 2: Why customers do not return**
4. How many customers buy again, and how much revenue depends on one-time buyers?
5. Does the first-order experience (delivery time, review score, category) differ between repeat and one-time customers?
6. How soon do repeat customers come back?
7. Does a bad first experience reduce repeat purchases?

## Tools Used

| Purpose | Tool |
|---|---|
| Data cleaning and feature creation | Python (pandas), Google Colab |
| Analysis and querying | PostgreSQL (CTEs, window functions, joins, aggregations), pgAdmin 4 |
| Dashboard | Power BI / Tableau *(in progress)* |

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle). Orders from Sep 2016 to Oct 2018.

Tables used: orders, customers, order items, payments, reviews, products and sellers. The raw files are not uploaded here because of their size.

---

## Data Cleaning

All seven tables were cleaned in Python before loading into PostgreSQL (see `python-notebooks/`). Key decisions:

- Converted all date columns to datetime.
- Created a `delivery_status` column (early, on-time, slightly late, late) by comparing actual and estimated delivery dates.
- Found 6 canceled orders that still had a delivery date. Set their delivery date and status to null so they are not counted as delivered.
- Found 8 delivered orders with a missing delivery date. Kept them (not guessed) and left them out of delay analysis.
- Found 551 duplicate reviews for the same order. Kept only the latest review per order (99,224 to 98,673 rows) so joins do not double count orders.
- Dropped the free-text review comments (mostly empty, not needed for score analysis).
- Used `customer_unique_id` (not `customer_id`) to identify real customers, since `customer_id` changes with every order.

---

## Part 1: Delivery and Reviews

### Delivery performance
- **4,664** of 96,470 delivered orders arrived late.
- Late counts alone are misleading. **SP** has 1,128 late orders, but its late rate is just **2.79%** because it handles the most orders.
- Among states with 1,000+ orders, the highest late rates are:

| State | Orders | Late orders | Late % |
|---|---|---|---|
| CE | 1,279 | 146 | 11.42 |
| RJ | 12,350 | 1,198 | 9.70 |
| BA | 3,256 | 303 | 9.31 |
| ES | 1,995 | 158 | 7.92 |
| PE | 1,593 | 124 | 7.78 |

- **RJ** has the biggest impact, combining a high late rate with high order volume. Late deliveries are concentrated in the **north-east** states.

### Review scores
- Average review score is **4.09 / 5**. 57.8% of reviews are 5-star and about **14.7%** are 1 or 2 star.
- State-wise averages (states with 1,000+ reviews) stay within **3.86 to 4.18**.

### Late delivery vs review score

| Delivery status | Avg review score |
|---|---|
| Early | 4.29 |
| On-time | 4.03 |
| Slightly late | 3.29 |
| Late | 1.85 |

Late delivery is the biggest driver of bad reviews: late orders score less than half of early ones.

---

## Part 2: Why Don't Customers Come Back?

Customers are identified by `customer_unique_id`. "First order" means a customer's earliest order by purchase timestamp. Full queries are in `sql-queries/06_overall_analysis.sql`.

### 4. Repeat purchase is very low
Only **2,997 of 96,096** customers (**3.12%**) ever place a second order. About 97% buy once and never return.

**Revenue impact:**

| Customer type | Customers | Revenue (R$) | Revenue per customer (R$) |
|---|---|---|---|
| One-time | 92,431 | 12.81M | 138.62 |
| Repeat | 2,989 | 0.78M | 260.56 |

One-time customers bring about 94% of revenue, but a repeat customer spends about **1.9x** more. If the repeat rate rose from about 3% to 5%, the platform could earn roughly **R$217K** extra (about +1.6%). This is an estimate that assumes new repeat customers would spend like existing ones.

### 5. Does the first-order experience differ between the two groups?

| Metric (first order) | One-time | Repeat |
|---|---|---|
| Avg. delivery time (days) | 12.51 | 12.33 |
| Avg. review score | 4.08 | 4.10 |

The two groups had nearly identical delivery times and ratings. **Delivery time and review score of the first order do not explain low repurchase.**

**By first-order category** (overall repeat rate is about 3.1%):

| Lower retention | Customers | Repeat rate | Higher retention | Customers | Repeat rate |
|---|---|---|---|---|---|
| consoles_games | 995 | 1.81% | furniture_decor | 5,914 | 4.79% |
| electronics | 2,457 | 1.83% | bed_bath_table | 8,735 | 4.66% |
| cool_stuff | 3,465 | 1.96% | sports_leisure | 7,197 | 4.07% |

Retention varies from about 1.8% to 4.8%. Home-related categories bring customers back more often than electronics and gaming. Categories with fewer than about 300 customers were treated cautiously because a few customers can swing the percentage. Each order's category was taken from its first item.

### 6. How soon do repeat customers return?

| Days between 1st and 2nd order | Share of repeat customers |
|---|---|
| 0-30 | 51.2% |
| 31-60 | 10.8% |
| 61-90 | 6.8% |
| 90+ | 31.3% |

About half of repeat customers return within 30 days, then the rate drops sharply. The first month after a purchase is the key window for re-engagement. The 0-30 bucket includes same-day second orders, which may be split purchases.

### 7. Does a bad first experience reduce repeat purchases?

Bad = late or slightly late delivery with a 1-2 star review. Good = on-time or early delivery with a 4-5 star review. Moderate = everything else.

| First-order experience | Customers | Repeat rate |
|---|---|---|
| Bad | 3,885 | 2.55% |
| Good | 71,508 | 3.18% |
| Moderate | 17,362 | 3.42% |

A bad first experience is associated with a lower repeat rate, but the gap is only about 0.6 percentage points, and even satisfied customers rarely return.

---

## Conclusion

Late delivery clearly hurts reviews (Part 1), but it explains only a small part of why customers do not return (Part 2). Delivery time, review score and a bad first experience each differ only slightly between repeat and one-time customers, and satisfied customers still return at about 3%. The low repurchase rate looks **broad-based and structural** rather than caused by one fixable problem.

## Recommendations

- **Re-engage within 30 days** of the first order (follow-up offers, reminders), since most returns happen in that window.
- **Focus retention efforts on high-volume, low-retention categories** such as electronics and cool_stuff, and learn from home categories that retain well.
- **Fix late deliveries where they hurt most:** RJ (most late orders) and CE (highest late rate among high-volume states). Improve logistics partners and routes in the north-east states. Use SP, MG and PR (late rate under 3%) as a model.
- Treat low-volume states like AL (17.38% late on about 400 orders) with care, since small volumes make percentages unstable.

## Limitations

- Findings show associations, not proven causes.
- Customer counts differ slightly between analyses because each needs different tables (for example orders with reviews or items), so some customers drop out of the joins.
- Customers whose first order was near the end of the dataset had less time to return, which may understate the true repeat rate.

---

## Repository Structure

```
olist-brazilian-ecommerce-analysis/
├── README.md
├── Reports/                      # Written reports with questions, SQL queries, outputs and charts
├── python-notebooks/
│   ├── 01_orders_customers_cleaning.ipynb
│   ├── 02_reviews_cleaning.ipynb
│   ├── 03_olist_order_items_cleaning.ipynb
│   ├── 04_olist_payments_cleaning.ipynb
│   ├── 05_olist_sellers_cleaning.ipynb
│   ├── 06_olist_reviews_cleaning.ipynb
│   └── 07_olist_products_cleaning.ipynb
└── sql-queries/
    ├── 01_orders_customers_analysis.sql
    ├── 02_reviews_analysis.sql
    ├── 03_products_analysis.sql
    ├── 04_olist_payments.sql
    ├── 05_olist_sellers_analysis.sql
    └── 06_overall_analysis.sql   # Part 2: repeat purchase analysis
```

## Author

**Khushi Yadav** | [LinkedIn](https://linkedin.com/in/khushiyadav76) | [GitHub](https://github.com/khushiyadav47)
