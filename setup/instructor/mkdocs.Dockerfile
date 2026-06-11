# Documentation server image for participant sharing (port 8001).
# Plugin versions are pinned in sync with .github/workflows/ci.yml.
FROM squidfunk/mkdocs-material:9.7.6

RUN pip install --no-cache-dir "mkdocs-static-i18n==1.3.1"
