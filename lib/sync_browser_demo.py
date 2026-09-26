"""Copy the participant search screen and sample products into the browser demo.

The browser demo in docs/demo/ reuses the participant screen (app.js, style.css,
and the product images) unchanged, and reads the sample products as JSON. Run
this after changing those files; `--check` fails when the demo is out of date.

Usage: python lib/sync_browser_demo.py [--check]
"""
import ast
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PARTICIPANT = ROOT / "setup" / "participant"
DEMO = ROOT / "docs" / "demo"


def sample_products(language):
    """Read SAMPLE_PRODUCTS from sample_products_<language>.py without importing it."""
    source = (PARTICIPANT / f"sample_products_{language}.py").read_text(encoding="utf-8")
    for node in ast.parse(source).body:
        if isinstance(node, ast.Assign) and any(getattr(t, "id", None) == "SAMPLE_PRODUCTS" for t in node.targets):
            return ast.literal_eval(node.value)
    raise ValueError(f"SAMPLE_PRODUCTS not found for {language}")


def expected_files():
    files = {}
    for name in ("app.js", "style.css"):
        files[f"{name}"] = (PARTICIPANT / "static" / name).read_bytes()
    for image in sorted((PARTICIPANT / "static" / "images").glob("*.svg")):
        files[f"images/{image.name}"] = image.read_bytes()
    for language in ("en", "ja"):
        # The images follow the order of SAMPLE_PRODUCTS: product-01.svg is the first product
        products = [dict(product, image_url=f"images/product-{index:02d}.svg")
                    for index, product in enumerate(sample_products(language), start=1)]
        text = json.dumps(products, ensure_ascii=False, indent=2) + "\n"
        files[f"data/products-{language}.json"] = text.encode("utf-8")
    return files


def main():
    check = "--check" in sys.argv[1:]
    stale = []
    for relative, content in expected_files().items():
        target = DEMO / relative
        if target.exists() and target.read_bytes() == content:
            continue
        stale.append(relative)
        if not check:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
    if check and stale:
        print("docs/demo is out of date; run python lib/sync_browser_demo.py:", ", ".join(stale))
        return 1
    print("docs/demo is up to date" if check else f"updated {len(stale)} file(s) in docs/demo")
    return 0


if __name__ == "__main__":
    sys.exit(main())
