from src.extract import filename_to_table


def test_olist_file_strips_prefix_and_suffix():
    assert filename_to_table("olist_orders_dataset.csv") == "orders"


def test_olist_file_with_underscore_in_name():
    assert filename_to_table("olist_order_items_dataset.csv") == "order_items"


def test_simple_file_without_prefix():
    assert filename_to_table("marketing_spend.csv") == "marketing_spend"


def test_translation_file():
    assert filename_to_table("product_category_name_translation.csv") == "product_category_name_translation"