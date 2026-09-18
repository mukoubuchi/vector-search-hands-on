/**
 * Navigation functionality
 * Controls back-to-top button visibility and mobile navigation behavior.
 *
 * Material's instant navigation replaces the page container on every tab or
 * link activation, so anything inside it is re-read on each document$ emission.
 * The tab strip is served from overrides/partials/tabs.html without a
 * data-md-component attribute, so it stays mounted and is bound only once.
 */
(function() {
    const MOBILE_BREAKPOINT = 1220;
    const tabs = document.querySelector('.md-tabs');
    const tabsList = document.querySelector('.md-tabs__list');

    function isMobileWidth() {
        return window.innerWidth <= MOBILE_BREAKPOINT;
    }

    function centerActiveTab() {
        const activeTab = document.querySelector('.md-tabs__item--active');

        if (!activeTab || !tabs || !isMobileWidth()) {
            return;
        }

        const tabsRect = tabs.getBoundingClientRect();
        const activeRect = activeTab.getBoundingClientRect();
        const scrollLeft = activeRect.left - tabsRect.left - (tabsRect.width / 2) + (activeRect.width / 2);

        tabs.scrollTo({
            left: tabs.scrollLeft + scrollLeft,
            behavior: 'smooth'
        });
    }

    // Show the button when scrolled down more than 300px. The button sits in
    // the replaced container, so look it up on every call instead of caching it.
    function updateBackToTop() {
        const backToTopButton = document.querySelector('.md-top');

        if (!backToTopButton) {
            return;
        }

        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        if (scrollTop > 300) {
            backToTopButton.removeAttribute('hidden');
        } else {
            backToTopButton.setAttribute('hidden', '');
        }
    }

    // Improve code block scrolling on mobile
    function markScrollableCodeBlocks() {
        if (!isMobileWidth()) {
            return;
        }

        document.querySelectorAll('.md-typeset pre').forEach(function(block) {
            // Add scroll indicator for long code blocks
            const code = block.querySelector('code');

            if (!code || code.scrollWidth <= block.clientWidth) {
                return;
            }

            // Show scroll hint on first interaction
            let scrollHintShown = false;
            block.addEventListener('touchstart', function() {
                if (scrollHintShown) {
                    return;
                }
                scrollHintShown = true;
                this.style.boxShadow = 'inset -10px 0 10px -10px rgba(0,0,0,0.2)';
                setTimeout(function() {
                    block.style.boxShadow = '';
                }, 1000);
            }, { passive: true, once: true });
        });
    }

    window.addEventListener('scroll', updateBackToTop, { passive: true });

    // Handle window resize: re-center the active tab on orientation change
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(centerActiveTab, 250);
    });

    // Add touch feedback for tab links
    if (tabsList) {
        tabsList.querySelectorAll('.md-tabs__link').forEach(function(link) {
            link.addEventListener('touchstart', function() {
                this.style.opacity = '0.6';
            }, { passive: true });

            link.addEventListener('touchend', function() {
                this.style.opacity = '';
            }, { passive: true });

            link.addEventListener('touchcancel', function() {
                this.style.opacity = '';
            }, { passive: true });
        });
    }

    document$.subscribe(function() {
        updateBackToTop();
        markScrollableCodeBlocks();
        // selector-indicator.js marks the active item in this same emission,
        // and it is subscribed after this script, so read the result next frame.
        requestAnimationFrame(centerActiveTab);
    });
})();
