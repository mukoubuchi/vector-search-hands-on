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

// Highlight first word (command) in bash code blocks
document.addEventListener('DOMContentLoaded', function() {
    // Wait for content to be fully loaded
    setTimeout(function() {
        const bashBlocks = document.querySelectorAll('.language-bash.highlight code, .language-sh.highlight code, .language-shell.highlight code');
        
        bashBlocks.forEach(function(codeBlock) {
            // Get all line spans
            const lineSpans = codeBlock.querySelectorAll('span[id^="__span-"]');
            
            lineSpans.forEach(function(lineSpan) {
                // Skip if line already has a highlighted command (has .nb, .n, or .nn span as first element after anchor)
                let firstElement = lineSpan.firstChild;
                
                // Skip anchor tag if present
                if (firstElement && firstElement.tagName === 'A') {
                    firstElement = firstElement.nextSibling;
                }
                
                // If first element is already a span with a class, skip this line
                if (firstElement && firstElement.nodeType === Node.ELEMENT_NODE &&
                    firstElement.tagName === 'SPAN' && firstElement.className) {
                    return;
                }
                
                // Get the first text node
                let firstTextNode = null;
                for (let node of lineSpan.childNodes) {
                    if (node.nodeType === Node.TEXT_NODE && node.textContent.trim()) {
                        firstTextNode = node;
                        break;
                    }
                    if (node.tagName === 'A') continue; // Skip anchor tags
                    if (node.nodeType === Node.ELEMENT_NODE) break; // Stop at first element
                }
                
                if (!firstTextNode) return;
                
                const text = firstTextNode.textContent;
                const trimmedText = text.trimStart();
                const leadingSpaces = text.length - trimmedText.length;
                
                // Extract the first word (command)
                const match = trimmedText.match(/^(\S+)/);
                if (!match) return;
                
                const firstWord = match[1];
                const remainingText = trimmedText.substring(firstWord.length);
                
                // Create a new span for the command
                const commandSpan = document.createElement('span');
                commandSpan.className = 'nb'; // Use the same class as built-in commands
                commandSpan.textContent = firstWord;
                
                // Create text nodes for spaces and remaining text
                const leadingSpaceNode = document.createTextNode(text.substring(0, leadingSpaces));
                const remainingTextNode = document.createTextNode(remainingText);
                
                // Replace the text node
                const parent = firstTextNode.parentNode;
                parent.insertBefore(leadingSpaceNode, firstTextNode);
                parent.insertBefore(commandSpan, firstTextNode);
                parent.insertBefore(remainingTextNode, firstTextNode);
                parent.removeChild(firstTextNode);
            });
        });
    }, 500);
});

// Made with Bob
