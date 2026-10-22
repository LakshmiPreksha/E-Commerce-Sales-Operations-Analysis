# Power BI Guide

Power BI Desktop can't be built from a script, so this is the one part of
the project you build by hand. Everything below is exact, so you're
following steps, not guessing.

## 1. Load the data

`Home > Get Data > Folder` → point at the `cleaned/` folder from this
project → **Combine & Transform** isn't needed here (each file is already
a separate clean table) → load all 8 files individually instead:
`Get Data > Text/CSV`, once for each of:

```
customers.csv   addresses.csv   payment_methods.csv
payments.csv    returns.csv     products.csv
orders.csv      orders_items.csv
```

## 2. Build the relationships

Open **Model view** and create these relationships (drag `CustomerID` on
`customers` onto `CustomerID` on `orders`, etc. — Power BI will offer to
create the relationship for you):

| From | To | Cardinality |
|---|---|---|
| `customers[CustomerID]` | `orders[CustomerID]` | 1 → many |
| `customers[CustomerID]` | `addresses[CustomerID]` | 1 → many |
| `orders[OrderID]` | `orders_items[OrderID]` | 1 → many |
| `orders[OrderID]` | `payments[OrderID]` | 1 → many |
| `orders[OrderID]` | `returns[OrderId]` | 1 → many |
| `products[product_id]` | `orders_items[ProductID]` | 1 → many |
| `products[product_id]` | `returns[ProductID]` | 1 → many |
| `payment_methods[PaymentMethodID]` | `payments[PaymentMethodID]` | 1 → many |

**Don't** add a relationship from `payment_methods` to
`customers[PreferredPaymentMethodID]` as well — Power BI only allows one
*active* relationship between any two tables, and you don't need a second
one for this report. Skip it.

## 3. Add a Date table

`Home > New Table`, paste:

```
Dates = CALENDAR(DATE(2010,1,1), DATE(2026,12,31))
```

Then in Model view, relate `Dates[Date]` to `orders[OrderDate]`
(1 → many). In the Dates table's column tools, mark it as a **Date Table**.
This is what powers month/quarter slicers and trend lines.

## 4. DAX measures (create these 5 — keep it to just these for now)

Revenue is defined as what the order line items say the products sold for
(`orders_items[Quantity]` × the product's discounted price) — simplest
definition that avoids having to reconcile multiple payment/discount
fields:

```DAX
Total Revenue =
    SUMX(
        orders_items,
        orders_items[Quantity] * RELATED(products[discounted_price_inr])
    )

Total Orders = DISTINCTCOUNT(orders[OrderID])

Average Order Value = DIVIDE([Total Revenue], [Total Orders])

Return Rate % = DIVIDE(DISTINCTCOUNT(returns[OrderId]), [Total Orders])

On-Time Delivery % =
    DIVIDE(
        CALCULATE(COUNTROWS(orders), orders[ActualDeliveryDate] <= orders[ExpectedDeliveryDate]),
        COUNTROWS(orders)
    )
```

## 5. Build 3 report pages

- **Sales Overview** — KPI cards for Total Revenue / Total Orders / Average
  Order Value, a line chart of Total Revenue by month (using the Dates
  table), a bar chart of top 10 products by revenue, a pie/donut of orders
  by `OrderChannel`.
- **Customers** — a bar chart of customers by `State` (from `addresses`), a
  donut of payments by `payment_methods[MethodName]`.
- **Returns & Delivery** — cards for Return Rate % and On-Time Delivery %, a
  bar chart of `Return_reason` counts, a bar chart of returns by
  `products[category]`.
- Add a date-range slicer (bound to `Dates[Date]`) and a `State` slicer,
  both set to apply across all 3 pages (`Format > Edit interactions`, or
  just leave default sync behavior if the fields exist on every page).

## 6. Save

Save as `EcommerceAnalystProject.pbix`. Publishing to the Power BI Service
is optional and not required to finish this project.
