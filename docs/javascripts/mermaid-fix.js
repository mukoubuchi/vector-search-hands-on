// Mermaid diagram size fix
document.addEventListener('DOMContentLoaded', function() {
    // Wait for Mermaid to render
    setTimeout(function() {
        const mermaidDiagrams = document.querySelectorAll('.mermaid');
        
        mermaidDiagrams.forEach(function(diagram) {
            // Find all rect elements in nodes
            const rects = diagram.querySelectorAll('g.node rect, g[class*="node"] rect');
            rects.forEach(function(rect) {
                rect.setAttribute('width', '160');
                rect.setAttribute('height', '60');
                rect.style.width = '160px';
                rect.style.height = '60px';
            });
            
            // Find all foreignObject elements
            const foreignObjects = diagram.querySelectorAll('foreignObject');
            foreignObjects.forEach(function(fo) {
                fo.setAttribute('width', '160');
                fo.setAttribute('height', '60');
                fo.style.width = '160px';
                fo.style.height = '60px';
                
                // Fix the div inside foreignObject
                const div = fo.querySelector('div');
                if (div) {
                    div.style.width = '160px';
                    div.style.height = '60px';
                    div.style.display = 'flex';
                    div.style.alignItems = 'center';
                    div.style.justifyContent = 'center';
                }
            });
            
            // Fix all text elements
            const texts = diagram.querySelectorAll('text, .nodeLabel');
            texts.forEach(function(text) {
                text.style.fontSize = '14px';
                text.style.lineHeight = '1.2';
            });
        });
    }, 500);
});

// Made with Bob
