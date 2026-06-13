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
 *
 * Headings nested inside an admonition (??? / !!!) are collapsible aside
 * content, not page structure, so their TOC entries are pruned and they
 * are excluded from the on-screen calculation — the enclosing real section
 * stays highlighted while you read through the admonition.
 */
(function() {
    function getNav() {
        return document.querySelector('.md-sidebar--secondary .md-nav--secondary');
    }

    function getList(nav) {
        return nav && nav.querySelector(':scope > .md-nav__list');
    }

    function inAdmonition(el) {
        // Block admonitions (!!!) render as .admonition; collapsible ones
        // (??? / ???+) render as a <details> carrying only a type class
        // (e.g. "info"), with no .admonition. This site uses <details>
        // solely for admonitions, so either ancestor counts.
        return !!el.closest('.admonition, details');
    }

    // Drop TOC entries for headings that live inside an admonition.
    function pruneAdmonitionEntries(nav) {
        var links = nav.querySelectorAll('.md-nav__link[href^="#"]');
        for (var i = 0; i < links.length; i++) {
            var id;
            try {
                id = decodeURIComponent(links[i].hash.slice(1));
            } catch (e) {
                id = links[i].hash.slice(1);
            }
            var heading = id && document.getElementById(id);
            if (heading && inAdmonition(heading)) {
                var item = links[i].closest('.md-nav__item');
                if (item) {
                    item.remove();
                }
            }
        }
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
        var all = document.querySelectorAll(
            '.md-content h1[id], .md-content h2[id], .md-content h3[id], ' +
            '.md-content h4[id], .md-content h5[id], .md-content h6[id]'
        );
        var headings = [];
        for (var i = 0; i < all.length; i++) {
            if (!inAdmonition(all[i])) {
                headings.push(all[i]);
            }
        }
        return headings;
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
            var on = !!onScreen[id];
            // Tint every link the rail covers, so text and bar stay in sync
            links[k].classList.toggle('md-toc-onscreen', on);
            if (!on) {
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

        pruneAdmonitionEntries(nav);

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
