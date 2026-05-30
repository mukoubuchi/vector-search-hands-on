/**
 * Language Switcher with Auto-detection
 * 
 * Features:
 * - Auto-detects user's region and redirects to appropriate language
 * - Provides manual language switcher in navigation
 * - Stores user's language preference in localStorage
 */

(function() {
    'use strict';

    // Configuration
    const STORAGE_KEY = 'preferred-language';
    const DEFAULT_LANG = 'en';
    const SUPPORTED_LANGS = ['en', 'ja'];
    
    // Language detection based on browser settings and region
    function detectUserLanguage() {
        // Check if user has a stored preference
        const storedLang = localStorage.getItem(STORAGE_KEY);
        if (storedLang && SUPPORTED_LANGS.includes(storedLang)) {
            return storedLang;
        }

        // Check browser language settings
        const browserLang = navigator.language || navigator.userLanguage;
        
        // Japanese detection
        if (browserLang.startsWith('ja')) {
            return 'ja';
        }

        // Default to English
        return DEFAULT_LANG;
    }

    // Get current language from URL
    function getCurrentLanguage() {
        const path = window.location.pathname;
        
        // Check if we're in a language-specific path
        if (path.includes('/ja/')) {
            return 'ja';
        }
        
        return 'en';
    }

    // Get the base path without language prefix
    function getBasePath() {
        const path = window.location.pathname;
        
        // Remove language prefix if present
        if (path.includes('/ja/')) {
            return path.replace('/ja/', '/');
        }
        
        return path;
    }

    // Redirect to appropriate language version
    function redirectToLanguage(targetLang) {
        const currentLang = getCurrentLanguage();
        
        if (currentLang === targetLang) {
            return; // Already on correct language
        }

        const basePath = getBasePath();
        let newPath;

        if (targetLang === 'ja') {
            // Redirect to Japanese version
            newPath = basePath.replace(/^\//, '/ja/');
        } else {
            // Redirect to English version (default)
            newPath = basePath;
        }

        // Store preference
        localStorage.setItem(STORAGE_KEY, targetLang);

        // Redirect
        window.location.href = newPath;
    }

    // Create language switcher UI
    function createLanguageSwitcher() {
        const currentLang = getCurrentLanguage();
        
        // Create switcher container
        const switcher = document.createElement('div');
        switcher.className = 'language-switcher';
        switcher.setAttribute('role', 'navigation');
        switcher.setAttribute('aria-label', 'Language switcher');

        // Create language buttons
        const languages = [
            { code: 'en', label: 'En', flag: '🇺🇸' },
            { code: 'ja', label: 'Ja', flag: '🇯🇵' }
        ];

        languages.forEach(lang => {
            const button = document.createElement('button');
            button.className = 'language-button';
            button.setAttribute('data-lang', lang.code);
            button.setAttribute('aria-label', `Switch to ${lang.label}`);
            
            if (lang.code === currentLang) {
                button.classList.add('active');
                button.setAttribute('aria-current', 'true');
            }

            button.innerHTML = `
                <span class="flag">${lang.flag}</span>
                <span class="label">${lang.label}</span>
            `;

            button.addEventListener('click', () => {
                redirectToLanguage(lang.code);
            });

            switcher.appendChild(button);
        });

        return switcher;
    }

    // Insert language switcher inside navigation tabs (right end)
    function insertLanguageSwitcher() {
        // Wait for Material theme to load
        const checkInterval = setInterval(() => {
            const tabs = document.querySelector('.md-tabs');
            
            if (tabs) {
                clearInterval(checkInterval);
                
                // Check if switcher already exists
                if (document.querySelector('.language-switcher')) {
                    return;
                }

                const switcher = createLanguageSwitcher();
                
                // Make tabs container relative for absolute positioning
                tabs.style.position = 'relative';
                
                // Insert switcher inside tabs container
                tabs.appendChild(switcher);
            }
        }, 100);

        // Stop checking after 5 seconds
        setTimeout(() => clearInterval(checkInterval), 5000);
    }

    // Auto-redirect on first visit
    function autoRedirect() {
        // Check if this is a direct visit (not from internal navigation)
        const isDirectVisit = !document.referrer || 
                             !document.referrer.includes(window.location.hostname);

        if (!isDirectVisit) {
            return; // Don't auto-redirect on internal navigation
        }

        // Check if user has already been redirected in this session
        const hasRedirected = sessionStorage.getItem('language-redirected');
        if (hasRedirected) {
            return;
        }

        const detectedLang = detectUserLanguage();
        const currentLang = getCurrentLanguage();

        if (detectedLang !== currentLang) {
            // Mark as redirected for this session
            sessionStorage.setItem('language-redirected', 'true');
            
            // Redirect to detected language
            redirectToLanguage(detectedLang);
        }
    }

    // Initialize
    function init() {
        // Auto-redirect on first visit
        autoRedirect();

        // Insert language switcher
        insertLanguageSwitcher();

        // Re-insert on page navigation (for SPA-like behavior)
        document.addEventListener('DOMContentLoaded', insertLanguageSwitcher);
        
        // Handle instant loading (Material theme feature)
        if (typeof app !== 'undefined' && app.document$) {
            app.document$.subscribe(insertLanguageSwitcher);
        }
    }

    // Run initialization
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();

// Made with Bob
