/**
 * Navigation functionality
 * Controls back-to-top button visibility and mobile navigation behavior
 */

// Control back-to-top button visibility
document.addEventListener('DOMContentLoaded', function() {
    let lastScrollTop = 0;
    const backToTopButton = document.querySelector('.md-top');
    
    if (backToTopButton) {
        window.addEventListener('scroll', function() {
            const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
            
            // Show button when scrolled down more than 300px
            if (scrollTop > 300) {
                backToTopButton.removeAttribute('hidden');
            } else {
                backToTopButton.setAttribute('hidden', '');
            }
            
            lastScrollTop = scrollTop;
        });
    }
    
    // Mobile navigation improvements
    const tabs = document.querySelector('.md-tabs');
    const tabsList = document.querySelector('.md-tabs__list');
    
    if (tabs && tabsList) {
        // Smooth scroll to active tab on mobile
        const activeTab = tabsList.querySelector('.md-tabs__item--active');
        if (activeTab && window.innerWidth <= 1220) {
            setTimeout(() => {
                const tabsRect = tabs.getBoundingClientRect();
                const activeRect = activeTab.getBoundingClientRect();
                const scrollLeft = activeRect.left - tabsRect.left - (tabsRect.width / 2) + (activeRect.width / 2);
                tabs.scrollTo({
                    left: tabs.scrollLeft + scrollLeft,
                    behavior: 'smooth'
                });
            }, 100);
        }
        
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
    if (window.innerWidth <= 1220) {
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
            const activeTab = document.querySelector('.md-tabs__item--active');
            if (activeTab && tabs && window.innerWidth <= 1220) {
                const tabsRect = tabs.getBoundingClientRect();
                const activeRect = activeTab.getBoundingClientRect();
                const scrollLeft = activeRect.left - tabsRect.left - (tabsRect.width / 2) + (activeRect.width / 2);
                tabs.scrollTo({
                    left: tabs.scrollLeft + scrollLeft,
                    behavior: 'smooth'
                });
            }
        }, 250);
    });
});

// Made with Bob
