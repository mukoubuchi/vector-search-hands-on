/**
 * Navigation functionality
 * Controls back-to-top button visibility based on scroll position
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
});

// Made with Bob
