# Feedback

Thank you for joining the Vector Search hands-on. Please share what worked well and what should be improved for future sessions.

!!! info "How to submit"
    When you click the button, it creates a message you can paste into Slack. Copy it, paste it into the designated Slack channel or DM, and send it there.

<form class="feedback-form" data-feedback-form data-feedback-lang="en" markdown="1">
  <section class="feedback-section" markdown="1">

## Overall Experience { #feedback-overall }

<label for="overall">Overall satisfaction <span class="feedback-required">Required</span></label>
<select id="overall" name="Overall satisfaction" required>
      <option value="">Select one</option>
      <option value="5 - Very satisfied">5 - Very satisfied</option>
      <option value="4 - Satisfied">4 - Satisfied</option>
      <option value="3 - Neutral">3 - Neutral</option>
      <option value="2 - Somewhat dissatisfied">2 - Somewhat dissatisfied</option>
      <option value="1 - Dissatisfied">1 - Dissatisfied</option>
</select>

<label for="pace">Workshop pace <span class="feedback-required">Required</span></label>
<select id="pace" name="Workshop pace" required>
      <option value="">Select one</option>
      <option value="Just right">Just right</option>
      <option value="A little fast">A little fast</option>
      <option value="Too fast">Too fast</option>
      <option value="A little slow">A little slow</option>
      <option value="Too slow">Too slow</option>
</select>
  </section>

  <section class="feedback-section" markdown="1">

## Hands-on Content { #feedback-content }

<label for="preparation">Was the preparation guide clear enough to set up IBM Bob, Milvus, the embedding model, and Python? <span class="feedback-required">Required</span></label>
<select id="preparation" name="Preparation clarity" required>
      <option value="">Select one</option>
      <option value="5 - Very clear">5 - Very clear</option>
      <option value="4 - Clear">4 - Clear</option>
      <option value="3 - Mostly clear">3 - Mostly clear</option>
      <option value="2 - Somewhat unclear">2 - Somewhat unclear</option>
      <option value="1 - Unclear">1 - Unclear</option>
</select>

<label for="vector-search">Did Part 1 help you understand semantic vector search compared with traditional keyword search? <span class="feedback-required">Required</span></label>
<select id="vector-search" name="Vector Search understanding" required>
      <option value="">Select one</option>
      <option value="5 - Strongly agree">5 - Strongly agree</option>
      <option value="4 - Agree">4 - Agree</option>
      <option value="3 - Neutral">3 - Neutral</option>
      <option value="2 - Disagree">2 - Disagree</option>
      <option value="1 - Strongly disagree">1 - Strongly disagree</option>
</select>

<label for="bob">Did Part 2 make the value of IBM Bob and Building Blocks easy to experience? <span class="feedback-required">Required</span></label>
<select id="bob" name="IBM Bob and Building Blocks value" required>
      <option value="">Select one</option>
      <option value="5 - Strongly agree">5 - Strongly agree</option>
      <option value="4 - Agree">4 - Agree</option>
      <option value="3 - Neutral">3 - Neutral</option>
      <option value="2 - Disagree">2 - Disagree</option>
      <option value="1 - Strongly disagree">1 - Strongly disagree</option>
</select>

<label for="features">Which added feature was most useful for learning? <span class="feedback-required">Required</span></label>
<select id="features" name="Most useful added feature" required>
      <option value="">Select one</option>
      <option value="Product image display">Product image display</option>
      <option value="Price filter">Price filter</option>
      <option value="Recommendation reason display">Recommendation reason display</option>
      <option value="All were useful">All were useful</option>
</select>

<label for="review">Were the verification, code review, and cleanup steps in Part 3 useful? <span class="feedback-required">Required</span></label>
<select id="review" name="Verification review cleanup usefulness" required>
      <option value="">Select one</option>
      <option value="5 - Very useful">5 - Very useful</option>
      <option value="4 - Useful">4 - Useful</option>
      <option value="3 - Neutral">3 - Neutral</option>
      <option value="2 - Not very useful">2 - Not very useful</option>
      <option value="1 - Not useful">1 - Not useful</option>
</select>
  </section>

  <section class="feedback-section" markdown="1">

## Comments { #feedback-comments }

<label for="confusing">Which part was confusing or hard to follow? <span class="feedback-required">Required</span></label>
<textarea id="confusing" name="Confusing or hard part" rows="4" placeholder="Example: Milvus connection setup, search API execution, IBM Bob code review..." required></textarea>

<label for="improvement">What should be improved for the next session? <span class="feedback-required">Required</span></label>
<textarea id="improvement" name="Improvement ideas" rows="4" required></textarea>

<label for="request">Please share any other comments or requests. <span class="feedback-optional">Optional</span></label>
<textarea id="request" name="Other comments or requests" rows="4"></textarea>
  </section>

  <div class="feedback-actions">
<button type="submit">Create Slack message</button>
<p data-feedback-status aria-live="polite"></p>
  </div>

  <section class="feedback-section feedback-copy-panel" data-feedback-copy-panel hidden>
<p class="feedback-copy-title">Message to paste into Slack</p>
<p class="feedback-copy-help">Copy the content below, paste it into the designated Slack channel or DM, and send it there.</p>
<textarea data-feedback-output rows="18" readonly aria-label="Feedback message to paste into Slack"></textarea>
<div class="feedback-actions">
      <button type="button" data-feedback-copy>Copy</button>
      <p data-feedback-copy-status aria-live="polite"></p>
</div>
  </section>
</form>
