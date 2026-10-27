/**
 * Keep page controls working after Material's instant navigation updates.
 *
 * Instant navigation replaces the page container on every tab or link activation, so
 * anything inside it is looked up again on each document$ emission. The tab strip comes
 * from overrides/partials/tabs.html without a data-md-component attribute, so it stays
 * mounted and is bound only once.
 */
(function() {
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const tabs = document.querySelector('.md-tabs');
    const tabsList = document.querySelector('.md-tabs__list');

    function updateBackToTop() {
        const button = document.querySelector('.md-top');
        if (button) button.hidden = window.scrollY <= 300;
    }

    function centerActiveTab() {
        const active = document.querySelector('.md-tabs__item--active');
        if (!active || !tabs || window.innerWidth > 1220) return;
        const box = tabs.getBoundingClientRect();
        const item = active.getBoundingClientRect();
        tabs.scrollTo({
            left: tabs.scrollLeft + item.left - box.left - (box.width - item.width) / 2,
            behavior: reducedMotion.matches ? 'instant' : 'smooth'
        });
    }

    // A tap has no hover state, so dim the tab while a finger is on it.
    if (tabsList) {
        tabsList.querySelectorAll('.md-tabs__link').forEach(link => {
            link.addEventListener('touchstart', () => { link.style.opacity = '0.6'; },
                { passive: true });
            link.addEventListener('touchend', () => { link.style.opacity = ''; },
                { passive: true });
            link.addEventListener('touchcancel', () => { link.style.opacity = ''; },
                { passive: true });
        });
    }

    // Hint once, on first touch, that a wide code block scrolls sideways.
    function hintScrollableCodeBlocks() {
        if (window.innerWidth > 1220) return;
        document.querySelectorAll('.md-typeset pre').forEach(block => {
            const code = block.querySelector('code');
            if (!code || code.scrollWidth <= block.clientWidth) return;
            block.addEventListener('touchstart', () => {
                block.style.boxShadow = 'inset -10px 0 10px -10px rgba(0,0,0,0.2)';
                setTimeout(() => { block.style.boxShadow = ''; }, 1000);
            }, { passive: true, once: true });
        });
    }

    window.addEventListener('scroll', updateBackToTop, { passive: true });
    window.addEventListener('resize', centerActiveTab, { passive: true });
    document$.subscribe(() => {
        updateBackToTop();
        hintScrollableCodeBlocks();
        // selector-indicator.js marks the active item in this same emission, and it is
        // subscribed after this script, so read the result in the next frame.
        requestAnimationFrame(centerActiveTab);
    });
})();
