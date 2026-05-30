(function() {
    function initLanguageSwitcher() {
        const header = document.querySelector('.md-header__inner');
        if (!header || document.querySelector('.custom-language-switcher')) {
            return;
        }

        const currentPath = window.location.pathname;
        const isJapanese = currentPath === '/ja/' || currentPath.startsWith('/ja/');
        const switcher = document.createElement('div');
        switcher.className = 'custom-language-switcher';

        switcher.innerHTML = `
            <button class="custom-language-switcher__toggle" type="button" aria-label="Switch language" aria-expanded="false" aria-controls="custom-language-switcher-menu">
                <i class="fa-solid fa-language" aria-hidden="true"></i>
            </button>
            <ul class="custom-language-switcher__menu" id="custom-language-switcher-menu" hidden>
                <li><a class="custom-language-switcher__link" href="/" ${isJapanese ? '' : 'aria-current="true"'}>English</a></li>
                <li><a class="custom-language-switcher__link" href="/ja/" ${isJapanese ? 'aria-current="true"' : ''}>日本語</a></li>
            </ul>
        `;

        header.prepend(switcher);

        const toggle = switcher.querySelector('.custom-language-switcher__toggle');
        const menu = switcher.querySelector('.custom-language-switcher__menu');

        const closeMenu = () => {
            menu.hidden = true;
            toggle.setAttribute('aria-expanded', 'false');
        };

        toggle.addEventListener('click', (event) => {
            event.stopPropagation();
            const isHidden = menu.hidden;
            menu.hidden = !isHidden;
            toggle.setAttribute('aria-expanded', String(isHidden));
        });

        document.addEventListener('click', (event) => {
            if (!switcher.contains(event.target)) {
                closeMenu();
            }
        });

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                closeMenu();
            }
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initLanguageSwitcher);
    } else {
        initLanguageSwitcher();
    }
})();

// Made with Bob
