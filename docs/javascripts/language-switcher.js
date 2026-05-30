(function() {
    function createSwitcherHTML(englishUrl, japaneseUrl, isJapanese, menuId) {
        return `
            <button class="custom-language-switcher__toggle" type="button" aria-label="Switch language" aria-expanded="false" aria-controls="${menuId}">
                <i class="fa-solid fa-language" aria-hidden="true"></i>
            </button>
            <ul class="custom-language-switcher__menu" id="${menuId}" hidden>
                <li><a class="custom-language-switcher__link" href="${englishUrl}" data-md-component="skip" ${isJapanese ? '' : 'aria-current="true"'}>English</a></li>
                <li><a class="custom-language-switcher__link" href="${japaneseUrl}" data-md-component="skip" ${isJapanese ? 'aria-current="true"' : ''}>日本語</a></li>
            </ul>
        `;
    }

    function setupSwitcherEvents(switcher) {
        const toggle = switcher.querySelector('.custom-language-switcher__toggle');
        const menu = switcher.querySelector('.custom-language-switcher__menu');
        const links = switcher.querySelectorAll('.custom-language-switcher__link');

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

        // 言語リンクのクリックイベントをインターセプトして強制的にページ遷移
        links.forEach(link => {
            link.addEventListener('click', (event) => {
                event.preventDefault();
                event.stopPropagation();
                const targetUrl = link.getAttribute('href');
                // 完全なページリロードを強制
                window.location.assign(targetUrl);
            }, true); // キャプチャフェーズで実行
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

    function initLanguageSwitcher() {
        const header = document.querySelector('.md-header__inner');
        
        if (!header || document.querySelector('.custom-language-switcher')) {
            return;
        }

        const currentPath = window.location.pathname;
        const isJapanese = currentPath === '/ja/' || currentPath.startsWith('/ja/');
        
        // 現在のページに対応する英語版と日本語版のURLを生成
        let englishUrl, japaneseUrl;
        
        if (isJapanese) {
            // 日本語ページの場合、/ja/を削除して英語版URLを生成
            japaneseUrl = currentPath;
            englishUrl = currentPath.replace(/^\/ja\//, '/');
            // ルートの場合は/にする
            if (englishUrl === '/') {
                englishUrl = '/';
            }
        } else {
            // 英語ページの場合、/ja/を追加して日本語版URLを生成
            englishUrl = currentPath;
            if (currentPath === '/') {
                japaneseUrl = '/ja/';
            } else {
                japaneseUrl = '/ja' + currentPath;
            }
        }
        
        // 言語スイッチャーを作成
        const languageSwitcher = document.createElement('div');
        languageSwitcher.className = 'custom-language-switcher custom-language-switcher--header';
        languageSwitcher.innerHTML = createSwitcherHTML(englishUrl, japaneseUrl, isJapanese, 'custom-language-switcher-menu');
        
        // 既存の言語スイッチャー（.md-header__option）の後に配置
        const defaultLangSwitcher = header.querySelector('.md-header__option');
        if (defaultLangSwitcher && defaultLangSwitcher.nextElementSibling) {
            header.insertBefore(languageSwitcher, defaultLangSwitcher.nextElementSibling);
        } else {
            // フォールバック: 検索ボタンの前に配置
            const searchButton = header.querySelector('label.md-header__button[for="__search"]');
            if (searchButton) {
                header.insertBefore(languageSwitcher, searchButton);
            } else {
                header.appendChild(languageSwitcher);
            }
        }
        
        setupSwitcherEvents(languageSwitcher);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initLanguageSwitcher);
    } else {
        initLanguageSwitcher();
    }
})();

// Made with Bob
