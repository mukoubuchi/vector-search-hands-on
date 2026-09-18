(function () {
  var MESSAGES = {
    ja: {
      header: 'Vector Search ハンズオン フィードバック',
      divider: '━━━━━━━━━━━━━━━━━━━━',
      noAnswer: '未回答',
      status: 'Slack に貼り付ける内容を作成しました。',
      copySuccess: 'コピーしました。Slack に貼り付けて送信してください。',
      copyFailure: 'コピーできませんでした。内容を選択して手動でコピーしてください。'
    },
    en: {
      header: 'Vector Search Hands-on Feedback',
      divider: '━━━━━━━━━━━━━━━━━━━━',
      noAnswer: 'No answer',
      status: 'Created the message to paste into Slack.',
      copySuccess: 'Copied. Paste it into Slack and send it.',
      copyFailure: 'Copy failed. Please select the content and copy it manually.'
    }
  };

  function collectFormData(form, messages) {
    var entries = [];
    var fields = form.querySelectorAll('select, textarea');

    fields.forEach(function (field) {
      if (field.hasAttribute('data-feedback-output')) {
        return;
      }

      var label = field.name || field.id;
      var value = (field.value || '').trim();
      entries.push('■ ' + label + '\n' + (value || messages.noAnswer));
    });

    return entries.join('\n\n');
  }

  function copyText(textarea, status, messages) {
    var text = textarea.value;

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(function () {
        if (status) {
          status.textContent = messages.copySuccess;
        }
      }).catch(function () {
        textarea.focus();
        textarea.select();

        if (status) {
          status.textContent = messages.copyFailure;
        }
      });
      return;
    }

    textarea.focus();
    textarea.select();

    try {
      document.execCommand('copy');
      if (status) {
        status.textContent = messages.copySuccess;
      }
    } catch (error) {
      if (status) {
        status.textContent = messages.copyFailure;
      }
    }
  }

  function handleFeedbackSubmit(event) {
    event.preventDefault();

    var form = event.currentTarget;
    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }

    var lang = form.getAttribute('data-feedback-lang');
    var messages = MESSAGES[lang] || MESSAGES.en;
    var body = messages.divider + '\n' + messages.header + '\n' + messages.divider + '\n\n' + collectFormData(form, messages);
    var status = form.querySelector('[data-feedback-status]');
    var panel = form.querySelector('[data-feedback-copy-panel]');
    var output = form.querySelector('[data-feedback-output]');

    if (status) {
      status.textContent = messages.status;
    }

    if (output) {
      output.value = body;
    }

    if (panel) {
      panel.hidden = false;
      panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  // A native <select> does not report its open state to CSS everywhere, so the
  // chevron follows a class as well. Browsers that support select:open turn it
  // from the stylesheet; this keeps the rest in step and always settles closed,
  // so a platform that opens a modal picker simply shows the closed chevron.
  function trackOpenState(form) {
    // Where CSS can read the open state, it is the only source of truth. Running
    // this alongside it would strand the chevron open: re-picking the option that
    // is already selected closes the list without firing change or blur, and the
    // press that closes it lands on the list, not on the select.
    if (CSS.supports('selector(select:open)')) {
      return;
    }

    form.querySelectorAll('.feedback-select > select').forEach(function (select) {
      var wrapper = select.parentElement;

      function close() {
        wrapper.classList.remove('feedback-select--open');
      }

      // The press that opens the native list is the same press that closes it.
      select.addEventListener('mousedown', function () {
        wrapper.classList.toggle('feedback-select--open');
      });

      select.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' || event.key === 'Tab' || event.key === 'Enter') {
          close();
        } else if (event.altKey && (event.key === 'ArrowDown' || event.key === 'ArrowUp')) {
          wrapper.classList.add('feedback-select--open');
        }
      });

      select.addEventListener('change', close);
      select.addEventListener('blur', close);
    });
  }

  document$.subscribe(function () {
    document.querySelectorAll('[data-feedback-form]').forEach(function (form) {
      form.addEventListener('submit', handleFeedbackSubmit);
      trackOpenState(form);

      var lang = form.getAttribute('data-feedback-lang');
      var messages = MESSAGES[lang] || MESSAGES.en;
      var copyButton = form.querySelector('[data-feedback-copy]');
      var output = form.querySelector('[data-feedback-output]');
      var copyStatus = form.querySelector('[data-feedback-copy-status]');

      if (copyButton && output) {
        copyButton.addEventListener('click', function () {
          copyText(output, copyStatus, messages);
        });
      }
    });
  });
}());
