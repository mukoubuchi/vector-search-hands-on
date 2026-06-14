/**
 * Numbered step rail
 *
 * Turns runs of "Step N: …" / "ステップ N: …" headings into a vertical
 * numbered timeline: a continuous line down the left margin with a numbered
 * circle at each step (styled in components.css). A run is a sequence of step
 * headings at the same heading level with only sub-content between them; a
 * non-step heading at that level (or higher) ends the run, so each Part 2
 * Feature gets its own rail and Part 3's Step 3 — separated from Steps 1–2 by
 * the Completion Check and FAQ sections — starts a fresh one.
 *
 * Only the step's own heading is marked (.step__title) and gets a circle;
 * non-step sub-headings inside a step keep their normal styling. Steps are
 * meant to be the smallest unit, so nesting is not expected — but if a deeper
 * step run appears inside a step it nests properly (smaller circles per depth,
 * see components.css) and is still numbered from its own heading.
 *
 * The "Step N:" prefix is stripped from the visible heading because the number
 * now lives in the circle. The circle shows the number parsed from the source
 * heading (not a CSS counter), so it stays correct even when a run is broken
 * up (Part 3) or restarts per group (Part 2).
 */
(function () {
    var STEP_RE = /^\s*(?:Step|ステップ)\s+(\d+)\s*[:：]\s*/;

    function headingLevel(el) {
        var m = /^H([1-6])$/.exec(el.tagName);
        return m ? parseInt(m[1], 10) : 0;
    }

    function stepNumber(el) {
        if (!headingLevel(el)) return null;
        var m = STEP_RE.exec(el.textContent);
        return m ? m[1] : null;
    }

    // Drop the "Step N:" prefix from the heading's leading text node, leaving
    // inline markup (code, strong, the headerlink anchor) untouched.
    function stripPrefix(heading) {
        for (var i = 0; i < heading.childNodes.length; i++) {
            var node = heading.childNodes[i];
            if (node.nodeType !== Node.TEXT_NODE) continue;
            if (STEP_RE.test(node.nodeValue)) {
                node.nodeValue = node.nodeValue.replace(STEP_RE, '');
            }
            return;
        }
    }

    function build(container) {
        var children = Array.prototype.slice.call(container.children);
        // Stack of open runs, outermost first: { group, level, step }.
        var stack = [];

        function top() {
            return stack.length ? stack[stack.length - 1] : null;
        }

        children.forEach(function (el) {
            var lvl = headingLevel(el);
            var num = lvl ? stepNumber(el) : null;

            if (num !== null) {
                // Close any runs deeper than this step's level.
                while (stack.length && top().level > lvl) stack.pop();

                var run = top();
                if (!run || run.level < lvl) {
                    // Start a new run: nested inside the enclosing step when one
                    // is open, otherwise inline in the page where the heading is.
                    var groupEl = document.createElement('div');
                    groupEl.className = 'steps';
                    if (run && run.step) {
                        run.step.appendChild(groupEl);
                    } else {
                        container.insertBefore(groupEl, el);
                    }
                    run = { group: groupEl, level: lvl, step: null };
                    stack.push(run);
                }

                var step = document.createElement('div');
                step.className = 'step';
                run.group.appendChild(step);
                stripPrefix(el);
                el.classList.add('step__title');
                el.setAttribute('data-step', num); // circle reads this in CSS
                step.appendChild(el);
                run.step = step;
                return;
            }

            // A non-step heading at a run's level (or higher) ends that run.
            if (lvl) {
                while (stack.length && top().level >= lvl) stack.pop();
            }

            var cur = top();
            if (cur && cur.step) cur.step.appendChild(el);
        });
    }

    function init() {
        var container = document.querySelector('.md-content__inner.md-typeset');
        if (container) build(container);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
