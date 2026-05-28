/**
 * Syntax highlighting enhancements
 * Adds custom highlighting for bash commands and properties files
 */

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

// Highlight pure numeric values and inline comments in properties files
document.addEventListener('DOMContentLoaded', function() {
    setTimeout(function() {
        const propertiesBlocks = document.querySelectorAll('.language-properties.highlight code');
        
        propertiesBlocks.forEach(function(codeBlock) {
            // Get all string spans (.s class)
            const stringSpans = codeBlock.querySelectorAll('span.s');
            
            stringSpans.forEach(function(span) {
                const text = span.textContent.trim();
                
                // Check if the value contains a comment
                const commentMatch = text.match(/^(.+?)(\s+#.*)$/);
                
                if (commentMatch) {
                    const value = commentMatch[1].trim();
                    const comment = commentMatch[2];
                    
                    // Check if the value part is a pure number
                    if (/^[\d.]+$/.test(value)) {
                        // Numeric value with inline comment
                        span.innerHTML = '<span class="mi">' + value + '</span><span class="c1">' + comment + '</span>';
                    } else {
                        // Non-numeric value with inline comment
                        span.innerHTML = value + '<span class="c1">' + comment + '</span>';
                    }
                } else {
                    // No comment, check if it's a pure number
                    if (/^[\d.]+$/.test(text)) {
                        span.innerHTML = '<span class="mi">' + text + '</span>';
                    }
                }
            });
        });
    }, 500);
});

// Made with Bob
