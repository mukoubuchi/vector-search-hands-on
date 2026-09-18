(function() {
    const siteConfig = window.VectorSearchHandsOn && window.VectorSearchHandsOn.site;
    const projectBase = siteConfig ? siteConfig.projectBase : '';

    function getProjectBase() {
        if (window.location.hostname.endsWith('.github.io')) {
            return projectBase;
        }

        return window.location.pathname.startsWith(projectBase + '/') ? projectBase : '';
    }

    function prefixProjectBase(path) {
        const base = getProjectBase();

        if (!base || !path.startsWith('/') || path.startsWith(base + '/') || path === base + '/') {
            return path;
        }

        return base + path;
    }

    function fixLinkElement(link) {
        const rawHref = link.getAttribute('href');

        if (!rawHref || rawHref.startsWith('http') || rawHref.startsWith('#')) {
            return;
        }

        if (rawHref.startsWith('/')) {
            link.setAttribute('href', prefixProjectBase(rawHref));
        }
    }

    function fixLanguageSwitcherLinks() {
        const base = getProjectBase();
        const pagePath = window.location.pathname.slice(base.length).replace(/^\/ja(?=\/|$)/, '') || '/';
        document.querySelectorAll('.md-select__link[hreflang]').forEach(function(link) {
            const locale = link.getAttribute('hreflang');
            link.setAttribute('href', base + (locale === 'ja' ? '/ja' : '') + pagePath);
            // A language change reloads the localized theme and search index.
            // Ordinary page navigation stays within the mounted document.
            link.setAttribute('target', '_self');
        });
        document.querySelectorAll('link[rel="alternate"][hreflang]').forEach(fixLinkElement);
    }

    document$.subscribe(fixLanguageSwitcherLinks);
})();
