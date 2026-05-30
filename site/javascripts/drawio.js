/**
 * Draw.io Integration for MkDocs
 * 
 * このスクリプトは、MkDocsドキュメント内でDraw.ioダイアグラムを表示するための統合機能を提供します。
 * .drawioファイルをSVGに変換して表示します。
 */

(function() {
    'use strict';

    /**
     * Draw.ioダイアグラムを初期化
     */
    function initDrawio() {
        // data-drawio属性を持つすべての要素を取得
        const drawioElements = document.querySelectorAll('[data-drawio]');
        
        if (drawioElements.length === 0) {
            return;
        }

        drawioElements.forEach(element => {
            const drawioPath = element.getAttribute('data-drawio');
            
            if (!drawioPath) {
                console.warn('Draw.io: data-drawio属性が空です', element);
                return;
            }

            // .drawioファイルを.svgに変換
            const svgPath = drawioPath.replace(/\.drawio$/, '.svg');
            
            // SVG画像を作成
            const img = document.createElement('img');
            img.src = svgPath;
            img.alt = element.getAttribute('data-alt') || 'Draw.io diagram';
            img.className = 'drawio-diagram';
            
            // スタイルを適用
            img.style.maxWidth = '100%';
            img.style.height = 'auto';
            img.style.display = 'block';
            img.style.margin = '1em auto';
            
            // エラーハンドリング
            img.onerror = function() {
                console.error('Draw.io: SVGファイルの読み込みに失敗しました:', svgPath);
                const errorMsg = document.createElement('div');
                errorMsg.className = 'admonition warning';
                errorMsg.innerHTML = `
                    <p class="admonition-title">Draw.io図の読み込みエラー</p>
                    <p>SVGファイルが見つかりません: <code>${svgPath}</code></p>
                    <p>Draw.ioファイルをSVGにエクスポートしてください。</p>
                `;
                element.appendChild(errorMsg);
            };
            
            // 読み込み成功時
            img.onload = function() {
                console.log('Draw.io: SVGファイルを読み込みました:', svgPath);
            };
            
            // 要素に追加
            element.appendChild(img);
        });
    }

    /**
     * ページ読み込み時に初期化
     */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDrawio);
    } else {
        initDrawio();
    }

    /**
     * MkDocsのページ遷移時にも初期化（SPAモード対応）
     */
    if (typeof document$ !== 'undefined') {
        document$.subscribe(initDrawio);
    }
})();

// Made with Bob
