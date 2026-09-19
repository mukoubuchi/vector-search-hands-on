/**
 * Search functionality
 * Handles search box interactions, closing behavior, and language filtering
 */

document.addEventListener('DOMContentLoaded', function() {
    const siteConfig = window.VectorSearchHandsOn && window.VectorSearchHandsOn.site;
    const navPaths = siteConfig ? siteConfig.navPaths : ['/', '/preparation/', '/part1/', '/part2/', '/summary/'];
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

    function filterByLanguage() {
        document.querySelectorAll('.md-search-result__item').forEach(function(item) {
            const link = item.querySelector('a.md-search-result__link');
            if (!link) return;

            const href = link.getAttribute('href');
            if (!href) return;

            const absolutePath = new URL(href, window.location.href).pathname;
            const sitePath = normalizeSitePath(absolutePath);
            const itemIsJa = /\/ja(\/|$)/.test(sitePath);
            const itemIsAllowed = isAllowedPath(sitePath);

            item.style.display = (isJaLocale === itemIsJa && itemIsAllowed) ? '' : 'none';
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
