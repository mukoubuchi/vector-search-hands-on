(function() {
    const siteConfig = window.VectorSearchHandsOn && window.VectorSearchHandsOn.site;
    const projectBase = siteConfig ? siteConfig.projectBase : '';

    function getProjectBase() {
        if (window.location.hostname.endsWith('.github.io')) {
            return projectBase;
        }

        return window.location.pathname.startsWith(projectBase + '/') ? projectBase : '';
    }

    // Point the language selector at the current page in each language. The alternate links
    // in the page head are relative in mkdocs.yml, so they need no fixing here.
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
    }

    document$.subscribe(fixLanguageSwitcherLinks);
})();
