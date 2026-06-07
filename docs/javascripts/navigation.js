/**
 * Navigation functionality
 * Controls back-to-top button visibility and mobile navigation behavior
 */

// Control back-to-top button visibility
document.addEventListener('DOMContentLoaded', function() {
    const MOBILE_BREAKPOINT = 1220;
    const backToTopButton = document.querySelector('.md-top');
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
    
    if (backToTopButton) {
        window.addEventListener('scroll', function() {
            const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            
            // Show button when scrolled down more than 300px
            if (scrollTop > 300) {
                backToTopButton.removeAttribute('hidden');
            } else {
                backToTopButton.setAttribute('hidden', '');
            }
        });
    }
    
    // Mobile navigation improvements
    if (tabs && tabsList) {
        // Smooth scroll to active tab on mobile
        setTimeout(centerActiveTab, 100);
        
        // Add touch feedback for tab links
        const tabLinks = tabsList.querySelectorAll('.md-tabs__link');
        tabLinks.forEach(link => {
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
    
    // Improve code block scrolling on mobile
    if (isMobileWidth()) {
        const codeBlocks = document.querySelectorAll('.md-typeset pre');
        codeBlocks.forEach(block => {
            // Add scroll indicator for long code blocks
            const code = block.querySelector('code');
            if (code && code.scrollWidth > block.clientWidth) {
                block.classList.add('has-horizontal-scroll');
                
                // Show scroll hint on first interaction
                let scrollHintShown = false;
                block.addEventListener('touchstart', function() {
                    if (!scrollHintShown) {
                        scrollHintShown = true;
                        this.style.boxShadow = 'inset -10px 0 10px -10px rgba(0,0,0,0.2)';
                        setTimeout(() => {
                            this.style.boxShadow = '';
                        }, 1000);
                    }
                }, { passive: true, once: true });
            }
        });
    }
    
    // Handle window resize
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            // Re-center active tab on orientation change
            centerActiveTab();
        }, 250);
    });
});
