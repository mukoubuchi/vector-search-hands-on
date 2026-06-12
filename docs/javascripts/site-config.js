(function() {
    window.VectorSearchHandsOn = window.VectorSearchHandsOn || {};

    // Derive the GitHub Pages project base ("/<repository-name>") from this
    // script's own URL, so the site keeps working if the repository is
    // renamed or forked. Every page loads this script from
    // "<base>/javascripts/site-config.js".
    function detectProjectBase() {
        const script = document.currentScript;

        if (script && script.src) {
            const path = new URL(script.src, window.location.href).pathname;
            const suffix = '/javascripts/site-config.js';

            if (path.endsWith(suffix)) {
                return path.slice(0, -suffix.length);
            }
        }

        return '';
    }

    window.VectorSearchHandsOn.site = {
        projectBase: detectProjectBase(),
        navPaths: [
            '/',
            '/preparation/',
            '/part1/',
            '/part2/',
            '/part3/',
            '/summary/',
            '/feedback/'
        ],
        languages: ['en', 'ja']
    };
})();
