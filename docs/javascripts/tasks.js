/**
 * Task list functionality
 * Saves and restores task list checkbox states using localStorage.
 *
 * Material replaces the page body on every instant navigation, so the
 * checkboxes are bound again for each page rather than once on first load.
 */
document$.subscribe(function() {
    document.querySelectorAll('.task-list-item').forEach(function(item) {
        // The checkbox input lives inside the .task-list-control label;
        // the label itself has no usable "checked" property
        const checkbox = item.querySelector('.task-list-control input[type="checkbox"]');

        if (!checkbox) {
            return;
        }

        const key = 'task-' + window.location.pathname + '-' + item.textContent.trim();

        // Save state to localStorage on change
        checkbox.addEventListener('change', function() {
            localStorage.setItem(key, checkbox.checked);
        });

        // Restore state from localStorage
        const savedState = localStorage.getItem(key);

        if (savedState !== null) {
            checkbox.checked = savedState === 'true';
        }
    });
});
