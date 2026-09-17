/** Keep one selection underline for the header and linked content tabs. */
(function() {
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const header = document.querySelector('.md-tabs__list');
    let contentControllers = [];

    function createIndicator(strip, getSelected) {
        const indicator = document.createElement(strip === header ? 'li' : 'span');
        indicator.className = 'selector-indicator';
        indicator.setAttribute('aria-hidden', 'true');
        strip.append(indicator);
        strip.classList.add('has-selector-indicator');
        let destination;
        let animation;

        function position(target = getSelected(), animate = true) {
            if (!target || !strip.isConnected) return;
            const parent = strip.getBoundingClientRect();
            const rect = target.getBoundingClientRect();
            if (!rect.width) return;
            const next = { x: rect.left - parent.left + strip.scrollLeft, width: rect.width };
            // Linked tabs and page updates can report the same selection twice.
            // Do not cancel or restart an animation already heading there.
            if (destination && Math.abs(next.x - destination.x) < 0.1 &&
                Math.abs(next.width - destination.width) < 0.1) return;
            const from = getComputedStyle(indicator).transform;
            const initialized = Boolean(destination);
            destination = next;
            if (animation) animation.cancel();
            const to = `translateX(${next.x}px) scaleX(${next.width})`;
            indicator.style.transform = to;
            if (animate && initialized && !reducedMotion.matches) {
                // Animate only the transform so layout work cannot interrupt it.
                animation = indicator.animate([{ transform: from }, { transform: to }], {
                    duration: 300,
                    easing: 'cubic-bezier(0.4, 0, 0.2, 1)'
                });
            }
        }

        const resize = new ResizeObserver(() => position(getSelected(), false));
        resize.observe(strip);
        [...strip.children].filter(child => child !== indicator).forEach(child => resize.observe(child));
        const onChange = () => position();
        strip.parentElement.addEventListener('change', onChange);
        position(getSelected(), false);
        document.fonts.ready.then(() => position(getSelected(), false));
        return {
            position,
            dispose() {
                resize.disconnect();
                strip.parentElement.removeEventListener('change', onChange);
                if (animation) animation.cancel();
            }
        };
    }

    function selectedHeader() {
        return header && [...header.querySelectorAll('a')].find(link =>
            new URL(link.href).pathname === location.pathname);
    }
    const headerController = header && createIndicator(header, selectedHeader);
    if (header) {
        header.addEventListener('click', event => {
            const link = event.target.closest('a');
            if (!link || event.button !== 0 || event.metaKey || event.ctrlKey ||
                event.shiftKey || event.altKey || link.target) return;
            headerController.position(link);
        });
    }

    function init() {
        if (headerController) {
            const selected = selectedHeader();
            header.querySelectorAll('a').forEach(link => {
                const active = link === selected;
                link.closest('.md-tabs__item').classList.toggle('md-tabs__item--active', active);
                if (active) link.setAttribute('aria-current', 'page');
                else link.removeAttribute('aria-current');
            });
            headerController.position(selected);
        }
        contentControllers.forEach(controller => controller.dispose());
        contentControllers = [...document.querySelectorAll('.tabbed-labels')].map(strip =>
            createIndicator(strip, () => {
                const input = strip.parentElement.querySelector(':scope > input:checked');
                return input && [...strip.querySelectorAll('label')].find(label => label.htmlFor === input.id);
            })
        );
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
