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
            if (searchToggle.checked) return;
            clearSearch();
            // Material opens the search only when the search field's focus changes to true;
            // typing into the field does not open it. Material blurs the field on Escape and
            // Tab, but not when Enter follows a result: after an instant navigation to a page
            // without a fragment, the field keeps the focus, and neither clicking it nor typing
            // in it opens the search again. Blur it whenever the search closes, as Material
            // does on Escape and Tab.
            if (searchInput && document.activeElement === searchInput) searchInput.blur();
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

        // Load a result on the current page as a full page. Material's instant navigation
        // replaces the page content only when the path changes, and its search highlighting
        // adds <mark> elements without removing the ones from an earlier search, so following
        // a result on the same page stacked the new highlights on the old ones; Material's
        // history handling also put the earlier query back in the address bar. Results on
        // other pages keep instant navigation. The clicks that Material's instant navigation
        // leaves to the browser (a button other than the left one, Cmd or Ctrl, a link with a
        // target) are left alone here too; Shift and Alt clicks, which Material takes over in
        // the current tab, load the page as well. Material's Enter clicks the best result, so
        // it comes through here too.
        searchContainer.addEventListener('click', function(event) {
            if (event.defaultPrevented || event.button !== 0) return;
            if (event.ctrlKey || event.metaKey) return;
            const link = event.target instanceof Element
                ? event.target.closest('a.md-search-result__link')
                : null;
            if (!link || link.target) return;
            const url = new URL(link.href, window.location.href);
            if (url.pathname !== window.location.pathname) return;
            // Keep the click from Material's instant navigation, which listens on the body.
            event.preventDefault();
            event.stopPropagation();
            // A URL that differs only in its fragment scrolls within the page without loading
            // it, so reload it after the move.
            const fragmentOnly = url.search === window.location.search && url.hash !== '';
            window.location.href = url.href;
            if (fragmentOnly) window.location.reload();
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
    // when Material is upgraded (pinned to 9.7.7 in .github/workflows/ci.yml,
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

    // Search highlighting marks the words of the h parameter in the page URL each time the
    // location changes, and never removes the marks already there. Within a page, instant
    // navigation keeps the content, so a table-of-contents entry or the tab of the current page
    // marked the same words again on top of the old marks. Once Material has taken the query for
    // a page, drop h from the address bar (the path and the fragment stay) and from the links to
    // this page, so later moves within the page carry no query and the words are marked once.
    // A reload or a copied URL then shows no highlights.
    // This relies on Material internals (9.7.7): the highlighting reads the page URL when it is
    // set up for a page, which Material does before this document$ subscriber runs, and instant
    // navigation resolves the links of a page against the URL the page was loaded with, so a
    // fragment-only link such as a table-of-contents entry carries h.
    function withoutHighlightQuery(href) {
        const url = new URL(href, window.location.href);
        if (!url.searchParams.has('h')) return null;
        url.searchParams.delete('h');
        return url;
    }

    function dropHighlightQuery() {
        const current = withoutHighlightQuery(window.location.href);
        if (current) history.replaceState(history.state, '', current.href);
        document.querySelectorAll('a[href]').forEach(function(link) {
            // Search results carry the query on purpose
            if (searchContainer && searchContainer.contains(link)) return;
            const url = withoutHighlightQuery(link.href);
            if (url && url.pathname === window.location.pathname) link.href = url.href;
        });
    }

    if (window.document$) window.document$.subscribe(dropHighlightQuery);

    // Escape takes the search highlights off the page when the search is closed and no input
    // has the focus. keyboard$ is Material's documented hook for custom keys (Setting up
    // navigation > Keyboard shortcuts); in its global mode Material leaves Escape unused and
    // skips keys typed into inputs, and Escape in the open search still closes it. The
    // highlights are Material's <mark data-md-highlight> elements (an internal detail of
    // 9.7.7; marks written in Markdown have no such attribute): put their text back in place
    // and join the split text again. Escape is claimed only when there was something to remove.
    if (window.keyboard$) {
        window.keyboard$.subscribe(function(key) {
            if (key.mode !== 'global' || key.type !== 'Escape') return;
            const marks = document.querySelectorAll(
                '[data-md-component="content"] mark[data-md-highlight]'
            );
            if (!marks.length) return;
            const parents = new Set();
            // Document order: an outer mark is unwrapped before the marks nested in it
            marks.forEach(function(mark) {
                const parent = mark.parentNode;
                if (!parent) return;
                while (mark.firstChild) parent.insertBefore(mark.firstChild, mark);
                parent.removeChild(mark);
                parents.add(parent);
            });
            parents.forEach(function(parent) {
                if (parent.isConnected) parent.normalize();
            });
            key.claim();
        });
    }
});
