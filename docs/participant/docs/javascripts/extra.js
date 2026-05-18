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

// Made with Bob
