/**
 * Search functionality
 * Handles search box interactions, closing behavior, language filtering, and the result count
 */

document.addEventListener('DOMContentLoaded', function() {
    const siteConfig = window.VectorSearchHandsOn && window.VectorSearchHandsOn.site;
    const navPaths = siteConfig ? siteConfig.navPaths : ['/', '/preparation/', '/part1/', '/part2/', '/part3/', '/summary/', '/feedback/'];
    const languages = siteConfig ? siteConfig.languages : ['en', 'ja'];

    const searchToggle = document.querySelector('[data-md-toggle="search"]');
    const searchContainer = document.querySelector('.md-search');
    const searchInput = document.querySelector('[data-md-component="search-query"]');

    function clearSearch() {
        if (!searchInput || !searchInput.value) return;
        searchInput.value = '';
        // Notify the theme so suggestions and results also reset.
        searchInput.dispatchEvent(new Event('input', { bubbles: true }));
    }

    function closeSearch() {
        if (searchToggle && searchToggle.checked) {
            searchToggle.checked = false;
            searchToggle.dispatchEvent(new Event('change', { bubbles: true }));
        }
        clearSearch();
    }

    if (searchToggle && searchContainer) {
        searchToggle.addEventListener('change', function() {
            if (!searchToggle.checked) clearSearch();
        });

        document.addEventListener('pointerdown', function(event) {
            if (!searchContainer.contains(event.target)) closeSearch();
        });

        searchContainer.addEventListener('focusout', function(event) {
            // Keep the query while moving to a result or a search control.
            if (event.relatedTarget && !searchContainer.contains(event.relatedTarget)) {
                closeSearch();
            }
        });
    }

    // Filter search results to the current language only and to top-tab pages only
    const isJaLocale = /\/ja(\/|$)/.test(window.location.pathname);
    const allowedPaths = languages.flatMap(function(language) {
        if (language === 'en') return navPaths;
        return navPaths.map(function(path) {
            return path === '/' ? '/' + language + '/' : '/' + language + path;
        });
    });

    function getSiteBasePath() {
        const currentPath = window.location.pathname;
        const allowedSuffix = allowedPaths
            .filter(function(allowed) {
                return allowed !== '/';
            })
            .sort(function(a, b) {
                return b.length - a.length;
            })
            .find(function(allowed) {
                return currentPath.endsWith(allowed);
            });

        if (allowedSuffix) {
            return currentPath.slice(0, -allowedSuffix.length);
        }

        return currentPath === '/' ? '' : currentPath.replace(/\/$/, '');
    }

    function normalizeSitePath(path) {
        const siteBasePath = getSiteBasePath();
        if (!siteBasePath || !path.startsWith(siteBasePath + '/')) return path;

        return path.slice(siteBasePath.length) || '/';
    }

    function isAllowedPath(path) {
        return allowedPaths.some(function(allowed) {
            return path === allowed;
        });
    }

    // A result is shown when its page is in this page's language and is a top-tab page
    function isShownResult(absolutePath) {
        const sitePath = normalizeSitePath(absolutePath);
        const itemIsJa = /\/ja(\/|$)/.test(sitePath);
        return isJaLocale === itemIsJa && isAllowedPath(sitePath);
    }

    // Take the results that are not shown out of the list rather than hiding them: Material's
    // Enter opens the best-scored link in the list and its arrow keys step through every link,
    // hidden or not, so a hidden result could be opened in the other language (Enter) or stop
    // the arrow keys (a hidden link cannot take focus).
    function filterByLanguage() {
        document.querySelectorAll('.md-search-result__item').forEach(function(item) {
            const link = item.querySelector('a.md-search-result__link');
            if (!link) return;

            const href = link.getAttribute('href');
            if (!href) return;

            if (!isShownResult(new URL(href, window.location.href).pathname)) item.remove();
        });
    }

    // The search index holds both languages, and filterByLanguage takes the other results out
    // of the list, so Material's "N matching documents" line also counts them. Rewrite it with
    // the number of results the filter keeps. Count from the full result list rather than the page:
    // Material renders the first ten results and adds the rest as the list scrolls.
    // window.component$ is Material's undocumented component stream, on which the search result
    // component emits { ref, items } right after it writes its own count line. Recheck this
    // when Material is upgraded (pinned to 9.7.6 in .github/workflows/ci.yml,
    // .github/workflows/deploy-docs.yml, and setup/instructor/mkdocs.Dockerfile).
    const configElement = document.getElementById('__config');
    const materialConfig = configElement ? JSON.parse(configElement.textContent) : null;
    // Result locations are relative to the site root. config.base is relative to the page the
    // site was loaded on, so resolve it now; instant navigation keeps the language, and a
    // language change reloads the page (see language-switcher.js).
    const siteRoot = materialConfig ? new URL(materialConfig.base, window.location.href) : null;

    function updateResultCount(result) {
        const meta = result.ref.querySelector('.md-search-result__meta');
        // An empty query keeps Material's own prompt
        if (!meta || !searchInput || !searchInput.value) return;

        const translations = materialConfig.translations;
        const count = result.items.filter(function(item) {
            return isShownResult(new URL(item[0].location, siteRoot).pathname);
        }).length;

        if (count === 0) {
            meta.textContent = translations['search.result.none'];
        } else if (count === 1) {
            meta.textContent = translations['search.result.one'];
        } else {
            meta.textContent = translations['search.result.other'].replace('#', String(count));
        }
    }

    if (materialConfig && window.component$) {
        window.component$.subscribe(function(component) {
            if (component && Array.isArray(component.items) && component.ref instanceof Element &&
                component.ref.matches('[data-md-component="search-result"]')) {
                updateResultCount(component);
            }
        });
    }

    function attachSearchObserver() {
        const searchResult = document.querySelector('.md-search-result');
        if (!searchResult) return false;

        new MutationObserver(filterByLanguage)
            .observe(searchResult, { childList: true, subtree: true });
        return true;
    }

    if (!attachSearchObserver()) {
        const bodyObserver = new MutationObserver(function() {
            if (attachSearchObserver()) {
                bodyObserver.disconnect();
            }
        });
        bodyObserver.observe(document.body, { childList: true, subtree: true });
    }
});
