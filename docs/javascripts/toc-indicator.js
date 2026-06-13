/**
 * TOC reading-position indicator
 *
 * Highlights every section currently on screen — not just the single one
 * the theme's scroll-spy marks active — with a link-colored segment on the
 * table-of-contents rail (see navigation.css). A section counts as on
 * screen when its own content range (from its heading down to the next
 * heading, of any level) overlaps the viewport, so a parent heading drops
 * off once you scroll past its own text into a subsection. The segment
 * spans from the topmost to the bottommost visible section's TOC entry.
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

    function getHeadings() {
        return Array.prototype.slice.call(document.querySelectorAll(
            '.md-content h1[id], .md-content h2[id], .md-content h3[id], ' +
            '.md-content h4[id], .md-content h5[id], .md-content h6[id]'
        ));
    }

    // Headings whose own content overlaps the viewport. A heading owns the
    // range from itself to the very next heading (of any level), so a parent
    // stops counting once you scroll past its text into a subsection.
    function visibleHeadings(headings, viewTop, viewBottom) {
        var visible = [];
        for (var i = 0; i < headings.length; i++) {
            var top = headings[i].getBoundingClientRect().top;
            var end = (i + 1 < headings.length)
                ? headings[i + 1].getBoundingClientRect().top
                : Infinity;
            if (top < viewBottom && end > viewTop) {
                visible.push(headings[i]);
            }
        }
        return visible;
    }

    function update(nav, list, bar) {
        var header = document.querySelector('.md-header');
        var viewTop = header ? header.offsetHeight : 0;
        var viewBottom = window.innerHeight;

        var visible = visibleHeadings(getHeadings(), viewTop, viewBottom);
        var onScreen = {};
        for (var i = 0; i < visible.length; i++) {
            onScreen[visible[i].id] = true;
        }

        // Span the rail from the first to the last visible section's TOC entry
        var top = Infinity;
        var bottom = -Infinity;
        var links = nav.querySelectorAll('.md-nav__link[href^="#"]');
        for (var k = 0; k < links.length; k++) {
            var id;
            try {
                id = decodeURIComponent(links[k].hash.slice(1));
            } catch (e) {
                id = links[k].hash.slice(1);
            }
            if (!onScreen[id]) {
                continue;
            }
            var t = offsetWithin(links[k], list);
            var b = t + links[k].offsetHeight;
            if (t < top) {
                top = t;
            }
            if (b > bottom) {
                bottom = b;
            }
        }

        if (bottom <= top) {
            bar.style.opacity = '0';
            return;
        }
        bar.style.top = top + 'px';
        bar.style.height = (bottom - top) + 'px';
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

        var scheduled = false;
        function run() {
            if (scheduled) {
                return;
            }
            scheduled = true;
            window.requestAnimationFrame(function() {
                scheduled = false;
                update(nav, list, bar);
            });
        }

        run();
        window.addEventListener('scroll', run, { passive: true });
        window.addEventListener('resize', run, { passive: true });
        // Catch late layout shifts (fonts, images, expanding admonitions)
        new MutationObserver(run).observe(nav, {
            subtree: true,
            attributes: true,
            attributeFilter: ['class']
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
