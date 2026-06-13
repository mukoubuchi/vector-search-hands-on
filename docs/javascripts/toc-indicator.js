/**
 * TOC reading-position indicator
 *
 * Marks the current section — the deepest heading on screen, tracked by
 * the theme's scroll-spy as .md-nav__link--active — with a link-colored
 * segment on the table-of-contents rail (see navigation.css). The theme's
 * toc.follow feature keeps that active entry scrolled into view.
 */
(function() {
    function getNav() {
        return document.querySelector('.md-sidebar--secondary .md-nav--secondary');
    }

    function getList(nav) {
        return nav && nav.querySelector(':scope > .md-nav__list');
    }

    // Vertical offset of an element within the (position: relative) list,
    // independent of how the sidebar is scrolled.
    function offsetWithin(el, ancestor) {
        var top = 0;
        while (el && el !== ancestor) {
            top += el.offsetTop;
            el = el.offsetParent;
        }
        return top;
    }

    function update(nav, list, bar) {
        var active = nav.querySelector('.md-nav__link--active');
        if (!active) {
            bar.style.opacity = '0';
            return;
        }
        bar.style.top = offsetWithin(active, list) + 'px';
        bar.style.height = active.offsetHeight + 'px';
        bar.style.opacity = '1';
    }

    function init() {
        var nav = getNav();
        if (!nav) {
            return;
        }
        var list = getList(nav);
        if (!list) {
            return;
        }

        var bar = list.querySelector(':scope > .md-toc-indicator');
        if (!bar) {
            bar = document.createElement('div');
            bar.className = 'md-toc-indicator';
            list.appendChild(bar);
        }

        function run() {
            update(nav, list, bar);
        }

        run();
        // The scroll-spy toggles .md-nav__link--active as the page scrolls
        new MutationObserver(run).observe(nav, {
            subtree: true,
            attributes: true,
            attributeFilter: ['class']
        });
        window.addEventListener('resize', run, { passive: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
