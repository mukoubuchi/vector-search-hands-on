(function() {
    const siteConfig = window.VectorSearchHandsOn && window.VectorSearchHandsOn.site;
    const projectBase = siteConfig ? siteConfig.projectBase : '/vector-search-hands-on';

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
        document
            .querySelectorAll('.md-select__link[hreflang], link[rel="alternate"][hreflang]')
            .forEach(fixLinkElement);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', fixLanguageSwitcherLinks);
    } else {
        fixLanguageSwitcherLinks();
    }
})();
