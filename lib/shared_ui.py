#!/usr/bin/env python3
"""Check that this site's copies of the shared UI files match the reference.

The hands-on sites building-blocks-explorer-hands-on, text2sql-hands-on,
vault-secret-migrator-hands-on, and vector-search-hands-on share the files in SHARED;
the reference copies live in building-blocks-explorer-hands-on. lib/shared-ui.sha256
lists each shared file with its SHA-256, and CI runs this script, which fails when a
copy differs. Settings that differ between the sites stay in
docs/javascripts/site-config.js, and styles that only one site uses stay in a file of
their own that its mkdocs.yml lists after extra.css.

To change a shared file, edit it in building-blocks-explorer-hands-on, run
`python lib/shared_ui.py --update` there, and copy the files and the manifest to the
other sites with `python lib/shared_ui.py --copy-to ../text2sql-hands-on ...`.
"""

import argparse
import hashlib
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = "lib/shared-ui.sha256"
SHARED = [
    "docs/javascripts/language-switcher.js",
    "docs/javascripts/navigation.js",
    "docs/javascripts/search.js",
    "docs/javascripts/selector-indicator.js",
    "docs/javascripts/steps.js",
    "docs/javascripts/syntax-highlight.js",
    "docs/javascripts/tasks.js",
    "docs/javascripts/toc-indicator.js",
    "docs/stylesheets/code.css",
    "docs/stylesheets/components.css",
    "docs/stylesheets/extra.css",
    "docs/stylesheets/fonts.css",
    "docs/stylesheets/language-switcher.css",
    "docs/stylesheets/navigation.css",
    "docs/stylesheets/palette.css",
    "docs/stylesheets/typography.css",
    "overrides/partials/tabs.html",
    "lib/shared_ui.py",
]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_manifest(root: Path) -> dict[str, str]:
    entries = {}
    for line in (root / MANIFEST).read_text(encoding="utf-8").splitlines():
        if line.strip():
            value, name = line.split(None, 1)
            entries[name.strip()] = value
    return entries


def check() -> int:
    manifest = read_manifest(ROOT)
    problems = []
    if sorted(manifest) != sorted(SHARED):
        problems.append(f"{MANIFEST} does not list exactly the shared files of {Path(__file__).name}")
    for name in SHARED:
        path = ROOT / name
        if not path.is_file():
            problems.append(f"missing: {name}")
        elif digest(path) != manifest.get(name):
            problems.append(f"differs from the reference: {name}")
    for problem in problems:
        print(problem)
    if problems:
        print("Change shared files in building-blocks-explorer-hands-on and copy them here "
              "(see the docstring of lib/shared_ui.py).")
        return 1
    print(f"{len(SHARED)} shared UI files match the reference.")
    return 0


def update() -> int:
    lines = [f"{digest(ROOT / name)}  {name}" for name in SHARED]
    (ROOT / MANIFEST).write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {MANIFEST} for {len(SHARED)} files")
    return 0


def copy_to(targets: list[str]) -> int:
    for target in targets:
        dest = Path(target).resolve()
        for name in SHARED + [MANIFEST]:
            (dest / name).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, dest / name)
        print(f"copied {len(SHARED) + 1} files to {dest}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--update", action="store_true", help="rewrite the manifest from this repository's files")
    group.add_argument("--copy-to", nargs="+", metavar="REPO", help="copy the shared files and the manifest to other sites")
    args = parser.parse_args()
    if args.update:
        return update()
    if args.copy_to:
        return copy_to(args.copy_to)
    return check()


if __name__ == "__main__":
    sys.exit(main())
