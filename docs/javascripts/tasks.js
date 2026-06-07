/**
 * Task list functionality
 * Saves and restores task list checkbox states using localStorage
 */

// Task list functionality - save state to localStorage
document.addEventListener('DOMContentLoaded', function() {
    function getTaskKey(item) {
        return 'task-' + window.location.pathname + '-' + item.textContent.trim();
    }

    // Wait for Material theme to initialize
    setTimeout(function() {
        // Get all task list items
        const taskListItems = document.querySelectorAll('.task-list-item');
        
        taskListItems.forEach(function(item) {
            const checkbox = item.querySelector('.task-list-control');
            
            if (checkbox) {
                const key = getTaskKey(item);

                // Save state to localStorage on change
                checkbox.addEventListener('change', function() {
                    localStorage.setItem(key, checkbox.checked);
                });
                
                // Restore state from localStorage
                const savedState = localStorage.getItem(key);
                
                if (savedState !== null) {
                    checkbox.checked = (savedState === 'true');
                }
            }
        });
    }, 500);
});
