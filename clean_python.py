"""
clean_python.py
Cleans the "python" source (orders.csv, orders_items.csv) with pandas and
writes the result into ../cleaned/. Run from this folder with:

    python clean_python.py
"""
import pandas as pd

RAW_DIR = r"..\..\Dataset\python"
OUT_DIR = r"..\cleaned"

DATE_COLUMNS = ["OrderDate", "ShippingDate", "ExpectedDeliveryDate", "ActualDeliveryDate"]


def clean_orders():
    df = pd.read_csv(f"{RAW_DIR}\\orders.csv")
    for col in DATE_COLUMNS:
        df[col] = pd.to_datetime(df[col], utc=True)
    assert df["OrderID"].is_unique, "Found duplicate OrderID values"
    df.to_csv(f"{OUT_DIR}\\orders.csv", index=False)
    print(f"orders.csv: {len(df)} rows")


def clean_order_items():
    df = pd.read_csv(f"{RAW_DIR}\\orders_items.csv")
    df["Quantity"] = df["Quantity"].astype(int)
    assert df["OrderItemID"].is_unique, "Found duplicate OrderItemID values"
    assert (df["Quantity"] > 0).all(), "Found non-positive Quantity"
    df.to_csv(f"{OUT_DIR}\\orders_items.csv", index=False)
    print(f"orders_items.csv: {len(df)} rows")


if __name__ == "__main__":
    clean_orders()
    clean_order_items()
    print("Done.")
