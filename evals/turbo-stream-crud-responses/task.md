# Inline Comment Management for a Blog Platform

## Problem/Feature Description

A content team maintains a Rails blog application where each post can receive reader comments. Currently, the comment workflow is entirely server-side: submitting a new comment triggers a full page reload that scrolls the user back to the top of the page, editing a comment navigates away to a separate edit form, and deleting a comment reloads the entire article. Readers are dropping off during comment interactions because they lose their reading position.

The engineering lead wants to modernise the comment section so that creating, updating, and deleting comments happen inline — the list updates without a full page reload, the form resets after submission, and deleted comments disappear without losing scroll position. The feature must remain accessible to users on slow or unreliable connections, so it must continue to work even when JavaScript is unavailable.

## Output Specification

Produce the implementation files for the comment feature upgrade. The output should include:

- `app/controllers/comments_controller.rb` — the updated controller with relevant actions
- `app/views/comments/` — all required view templates, including any needed for partial-update responses
- `app/views/posts/show.html.erb` — the post show view embedding the comment list and form (may be partial)
- `README_comments.md` — a short document (plain markdown) describing how the feature degrades when JavaScript is disabled

You may also include any ERB partials (`_comment.html.erb`, `_form.html.erb`, etc.) needed to make the templates work. The output does not need to be a runnable Rails app — focus on the template and controller code that implements the feature.
