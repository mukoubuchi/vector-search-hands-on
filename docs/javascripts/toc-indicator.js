/**
 * TOC reading-position indicator
 *
 * Highlights every section whose heading is currently on screen — at all
 * heading levels — with a link-colored segment on the table-of-contents
 * rail (see navigation.css). The segment spans the contiguous range of
 * visible headings and follows the page as it scrolls.
 */
(function() {
    function getNav() {
        return document.querySelector('.md-sidebar--secondary .md-nav--secondary');
    }

    function getList(nav) {
        return nav && nav.querySelector(':scope > .md-nav__list');
    }

    // Every TOC entry (any level) paired with its content heading element.
    function entries(nav) {
        var out = [];
        nav.querySelectorAll('.md-nav__link[href^="#"]').forEach(function(link) {
            var id = decodeURIComponent(link.hash.slice(1));
            var heading = id && document.getElementById(id);
            if (heading) {
                out.push({ link: link, heading: heading });
            }
        });
        return out;
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
        var all = entries(nav);
        if (!all.length) {
            bar.style.opacity = '0';
            return;
        }

        var vh = window.innerHeight || document.documentElement.clientHeight;
        var top = viewportTop();

        var visible = all.filter(function(e) {
            var r = e.heading.getBoundingClientRect();
            return r.top < vh && r.bottom > top;
        });

        if (!visible.length) {
            // In a long section with no heading on screen, mark the section
            // currently being read (the last heading above the fold).
            var current = null;
            all.forEach(function(e) {
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
            // The link row, not the item: a parent item's height would
            // include its whole subtree
            var t = offsetWithin(e.link, list);
            var b = t + e.link.offsetHeight;
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
