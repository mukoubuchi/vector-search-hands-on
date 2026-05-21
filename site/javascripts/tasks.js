/**
 * Task list functionality
 * Saves and restores task list checkbox states using localStorage
 */

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
