"""MkDocs hook: copy the site's sitemap into the Japanese root.

Material fetches sitemap.xml under each language link in the page head
(extra.alternate in mkdocs.yml) whenever a page is shown, including after
instant navigation. mkdocs-static-i18n writes a single sitemap, covering both
languages, at the site root, so without a copy the request for ja/sitemap.xml
fails with 404 on every page view.
"""

import shutil
from pathlib import Path

from mkdocs.plugins import event_priority


# mkdocs-static-i18n builds the other languages in its own on_post_build
# (priority -100), so run after it, once the sitemap and ja/ are final.
@event_priority(-200)
def on_post_build(config, **kwargs):
    site_dir = Path(config["site_dir"])
    ja_dir = site_dir / "ja"
    if not ja_dir.is_dir():
        return
    for name in ("sitemap.xml", "sitemap.xml.gz"):
        source = site_dir / name
        if source.is_file():
            shutil.copyfile(source, ja_dir / name)
