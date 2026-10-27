/**
 * Persist completion checkboxes for each page across instant navigation.
 *
 * Material replaces the page body on every instant navigation, so the checkboxes are
 * bound again for each page rather than once on first load.
 */
document$.subscribe(function() {
    document.querySelectorAll('.task-list-item').forEach(function(item) {
        // The input lives inside the .task-list-control label, which has no checked state.
        const checkbox = item.querySelector('.task-list-control input[type="checkbox"]');
        if (!checkbox) return;
        const key = 'task-' + window.location.pathname + '-' + item.textContent.trim();
        checkbox.addEventListener('change', function() {
            localStorage.setItem(key, checkbox.checked);
        });
        const savedState = localStorage.getItem(key);
        if (savedState !== null) checkbox.checked = savedState === 'true';
    });
});
