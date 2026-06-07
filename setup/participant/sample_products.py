"""Select sample product data by participant language."""


def get_sample_products(language: str):
    """Return sample products for the requested participant language."""
    normalized_language = language.strip().lower()
    if normalized_language == "ja":
        from sample_products_ja import SAMPLE_PRODUCTS
    else:
        from sample_products_en import SAMPLE_PRODUCTS

    return SAMPLE_PRODUCTS
