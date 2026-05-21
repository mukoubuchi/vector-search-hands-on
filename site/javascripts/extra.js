// Close search when clicking outside search area
document.addEventListener('DOMContentLoaded', function() {
    // Wait for search to be initialized and for search results to be available
    setTimeout(function() {
        // Use mousedown instead of click to avoid interfering with search functionality
        document.addEventListener('mousedown', function(e) {
            const searchToggle = document.querySelector('[data-md-toggle="search"]');
            
            // Only proceed if search is open
            if (!searchToggle || !searchToggle.checked) return;
            
            const searchContainer = document.querySelector('.md-search');
            const searchOutput = document.querySelector('.md-search__output');
            
            // Don't close if clicking within the search container or output
            if (searchContainer && searchContainer.contains(e.target)) return;
            if (searchOutput && searchOutput.contains(e.target)) return;
            
            // Close search
            searchToggle.checked = false;
        });
    }, 1000); // Increase timeout to ensure search is fully initialized
});

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

// Task list functionality - save state to localStorage
document.addEventListener('DOMContentLoaded', function() {
    // Wait for Material theme to initialize
    setTimeout(function() {
        // Get all task list items
        const taskListItems = document.querySelectorAll('.task-list-item');
        
        taskListItems.forEach(function(item) {
            const checkbox = item.querySelector('.task-list-control');
            
            if (checkbox) {
                // Save state to localStorage on change
                checkbox.addEventListener('change', function() {
                    const itemText = item.textContent.trim();
                    const key = 'task-' + window.location.pathname + '-' + itemText;
                    localStorage.setItem(key, checkbox.checked);
                });
                
                // Restore state from localStorage
                const itemText = item.textContent.trim();
                const key = 'task-' + window.location.pathname + '-' + itemText;
                const savedState = localStorage.getItem(key);
                
                if (savedState !== null) {
                    checkbox.checked = (savedState === 'true');
                }
            }
        });
    }, 500);
});

// Made with Bob
