/**
 * TOC reading-position indicator
 *
 * Highlights the sections whose headings are currently on screen with a
 * link-colored segment on the table-of-contents rail (see navigation.css),
 * at the finest (leaf) heading granularity. The segment spans the
 * contiguous range of visible sections and follows the page as it scrolls.
 */
(function() {
    function getNav() {
        return document.querySelector('.md-sidebar--secondary .md-nav--secondary');
    }

    function getList(nav) {
        return nav && nav.querySelector(':scope > .md-nav__list');
    }

    // Leaf TOC entries: items with no nested sub-navigation (the finest
    // granularity), paired with their content heading element.
    function leafEntries(nav) {
        var entries = [];
        nav.querySelectorAll('.md-nav__item').forEach(function(item) {
            if (item.querySelector(':scope > .md-nav')) {
                return;
            }
            var link = item.querySelector(':scope > .md-nav__link[href^="#"]');
            if (!link) {
                return;
            }
            var id = decodeURIComponent(link.hash.slice(1));
            var heading = id && document.getElementById(id);
            if (heading) {
                entries.push({ item: item, link: link, heading: heading });
            }
        });
        return entries;
    }

    // Top of the readable area, below the sticky header.
    function viewportTop() {
        var header = document.querySelector('.md-header');
        return header ? header.offsetHeight : 0;
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
        var entries = leafEntries(nav);
        if (!entries.length) {
            bar.style.opacity = '0';
            return;
        }

        var vh = window.innerHeight || document.documentElement.clientHeight;
        var top = viewportTop();

        var visible = entries.filter(function(e) {
            var r = e.heading.getBoundingClientRect();
            return r.top < vh && r.bottom > top;
        });

        if (!visible.length) {
            // In a long section with no heading on screen, mark the section
            // currently being read (the last heading above the fold).
            var current = null;
            entries.forEach(function(e) {
                if (e.heading.getBoundingClientRect().top <= top) {
                    current = e;
                }
            });
            if (current) {
                visible = [current];
            }
        }

        nav.querySelectorAll('.md-toc-current').forEach(function(link) {
            link.classList.remove('md-toc-current');
        });

        if (!visible.length) {
            bar.style.opacity = '0';
            return;
        }

        var minTop = Infinity;
        var maxBottom = -Infinity;
        visible.forEach(function(e) {
            e.link.classList.add('md-toc-current');
            var t = offsetWithin(e.item, list);
            var b = t + e.item.offsetHeight;
            if (t < minTop) {
                minTop = t;
            }
            if (b > maxBottom) {
                maxBottom = b;
            }
        });

        bar.style.top = minTop + 'px';
        bar.style.height = (maxBottom - minTop) + 'px';
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

        var ticking = false;
        function schedule() {
            if (ticking) {
                return;
            }
            ticking = true;
            requestAnimationFrame(function() {
                ticking = false;
                update(nav, list, bar);
            });
        }

        schedule();
        window.addEventListener('scroll', schedule, { passive: true });
        window.addEventListener('resize', schedule, { passive: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
