/**
 * TOC reading-position indicator
 *
 * Highlights the section currently on screen with a link-colored segment
 * on the table-of-contents rail (see navigation.css). The segment spans
 * the section that holds the active heading, positioned from live
 * geometry so it lands on the rail at any nesting depth.
 */
(function() {
    function getNav() {
        return document.querySelector('.md-sidebar--secondary .md-nav--secondary');
    }

    function getList(nav) {
        return nav.querySelector(':scope > .md-nav__list');
    }

    // The section to highlight: the active heading's own item when it is a
    // section (has a nested sub-list), otherwise its parent section item.
    function sectionItemFor(activeLink) {
        var item = activeLink.closest('.md-nav__item');
        if (!item) {
            return null;
        }
        if (item.querySelector(':scope > .md-nav')) {
            return item;
        }
        var parentItem = item.parentElement.closest('.md-nav__item');
        return parentItem || item;
    }

    function ensureIndicator(list) {
        var bar = list.querySelector(':scope > .md-toc-indicator');
        if (!bar) {
            bar = document.createElement('div');
            bar.className = 'md-toc-indicator';
            list.appendChild(bar);
        }
        return bar;
    }

    function update() {
        var nav = getNav();
        if (!nav) {
            return;
        }
        var list = getList(nav);
        if (!list) {
            return;
        }

        var bar = ensureIndicator(list);
        var active = nav.querySelector('.md-nav__link--active');
        var section = active ? sectionItemFor(active) : null;

        if (!section) {
            bar.style.opacity = '0';
            return;
        }

        // section.offsetParent is the position: relative list, so offsetTop
        // is measured from the rail's coordinate space regardless of depth
        bar.style.top = section.offsetTop + 'px';
        bar.style.height = section.offsetHeight + 'px';
        bar.style.opacity = '1';
    }

    function init() {
        var nav = getNav();
        if (!nav) {
            return;
        }

        update();

        // Material toggles .md-nav__link--active as the page scrolls
        new MutationObserver(update).observe(nav, {
            subtree: true,
            attributes: true,
            attributeFilter: ['class']
        });
        window.addEventListener('resize', update, { passive: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
