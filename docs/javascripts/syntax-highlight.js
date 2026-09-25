/**
 * Syntax highlighting enhancements
 * Adds custom highlighting for bash commands and properties files
 */

(function() {
    'use strict';

    function runAfterThemeInit(callback) {
        // Material emits document$ once the page body is in place, both on the
        // first load and after every instant navigation.
        document$.subscribe(callback);
    }

    function createHighlightedSpan(className, text) {
        const span = document.createElement('span');
        span.className = className;
        span.textContent = text;
        return span;
    }

    function getFirstPlainTextNode(lineSpan) {
        for (const node of lineSpan.childNodes) {
            if (node.nodeType === Node.TEXT_NODE && node.textContent.trim()) {
                return node;
            }
            if (node.tagName === 'A') {
                continue;
            }
            if (node.nodeType === Node.ELEMENT_NODE) {
                return null;
            }
        }

        return null;
    }

    function hasExistingHighlight(lineSpan) {
        let firstElement = lineSpan.firstChild;

        if (firstElement && firstElement.tagName === 'A') {
            firstElement = firstElement.nextSibling;
        }

        return firstElement
            && firstElement.nodeType === Node.ELEMENT_NODE
            && firstElement.tagName === 'SPAN'
            && firstElement.className;
    }

    function isShellEscape(node) {
        return node.nodeType === Node.ELEMENT_NODE
            && node.tagName === 'SPAN'
            && node.classList.contains('se');
    }

    // Pygments splits a Windows path such as venv\Scripts\activate into text
    // and escape tokens (.se for \S and \a). When the first word runs straight
    // into an escape, keep reading up to the next whitespace so that the whole
    // path becomes one command name. Returns the text taken from the siblings.
    function takeEscapedTail(firstTextNode) {
        const parent = firstTextNode.parentNode;
        const consumed = [];
        let tail = '';
        let node = firstTextNode.nextSibling;

        while (node && isShellEscape(node)) {
            tail += node.textContent;
            consumed.push(node);
            node = node.nextSibling;

            if (node && node.nodeType === Node.TEXT_NODE) {
                const head = node.textContent.match(/^\S*/)[0];
                tail += head;
                if (head.length < node.textContent.length) {
                    // Whitespace ends the word; leave the rest of this node in place.
                    node.textContent = node.textContent.substring(head.length);
                    break;
                }
                consumed.push(node);
                node = node.nextSibling;
            }
        }

        consumed.forEach(function(consumedNode) {
            parent.removeChild(consumedNode);
        });
        return tail;
    }

    function highlightShellCommand(lineSpan) {
        if (hasExistingHighlight(lineSpan)) {
            return;
        }

        const firstTextNode = getFirstPlainTextNode(lineSpan);
        if (!firstTextNode) {
            return;
        }

        const text = firstTextNode.textContent;
        const trimmedText = text.trimStart();
        const leadingSpaces = text.length - trimmedText.length;
        const match = trimmedText.match(/^(\S+)/);

        if (!match) {
            return;
        }

        let firstWord = match[1];
        const parent = firstTextNode.parentNode;
        const rest = trimmedText.substring(firstWord.length);

        if (rest === '') {
            firstWord += takeEscapedTail(firstTextNode);
        }

        parent.insertBefore(document.createTextNode(text.substring(0, leadingSpaces)), firstTextNode);
        parent.insertBefore(createHighlightedSpan('nb', firstWord), firstTextNode);
        parent.insertBefore(document.createTextNode(rest), firstTextNode);
        parent.removeChild(firstTextNode);
    }

    function highlightShellBlocks() {
        const bashBlocks = document.querySelectorAll('.language-bash.highlight code, .language-sh.highlight code, .language-shell.highlight code');

        bashBlocks.forEach(function(codeBlock) {
            codeBlock.querySelectorAll('span[id^="__span-"]').forEach(highlightShellCommand);
        });
    }

    function appendPropertiesValue(parent, value) {
        if (/^[\d.]+$/.test(value)) {
            parent.appendChild(createHighlightedSpan('mi', value));
        } else {
            parent.appendChild(document.createTextNode(value));
        }
    }

    function highlightPropertiesSpan(span) {
        const text = span.textContent.trim();
        const commentMatch = text.match(/^(.+?)(\s+#.*)$/);

        if (commentMatch) {
            span.textContent = '';
            appendPropertiesValue(span, commentMatch[1].trim());
            span.appendChild(createHighlightedSpan('c1', commentMatch[2]));
            return;
        }

        if (/^[\d.]+$/.test(text)) {
            span.textContent = '';
            appendPropertiesValue(span, text);
        }
    }

    function highlightPropertiesBlocks() {
        const propertiesBlocks = document.querySelectorAll('.language-properties.highlight code');

        propertiesBlocks.forEach(function(codeBlock) {
            codeBlock.querySelectorAll('span.s').forEach(highlightPropertiesSpan);
        });
    }

    runAfterThemeInit(function() {
        highlightShellBlocks();
        highlightPropertiesBlocks();
    });
})();
