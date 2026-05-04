# Configurable Auto-Save Status Widget

## Problem/Feature Description

A project management SaaS built on Rails wants to add an auto-save status widget to its document editor. When a user types in the editor, the widget should show a "Saving…" indicator after a configurable delay, then switch to "Saved" once the server confirms. The delay between keystrokes and the save attempt should be configurable per-page (different document types have different auto-save preferences). The CSS classes used to style the saving/saved/error states should not be hardcoded in JavaScript — instead, they should be injectable from the HTML so that different themes can change them without touching JavaScript.

The application already uses Rails with Hotwire set up. The server-side save endpoint exists at `PATCH /documents/:id` and returns a JSON response. Your task is to build the client-side widget that drives the status indicator.

This behavior is inherently client-side (debounce timing, immediate visual feedback before the server responds) and cannot be handled by Turbo alone, making a JavaScript controller appropriate here.

## Output Specification

Produce the following files:

- `app/javascript/controllers/auto_save_controller.js` — the Stimulus controller implementing the auto-save status widget
- `app/javascript/controllers/index.js` — the updated index file that registers the new controller (include at least this controller's registration, other controllers can be omitted)
- `app/views/documents/edit.html.erb` — an ERB snippet showing how the controller is wired into the document editor form, with the delay and CSS classes configured from HTML

Include a brief `CONTROLLER_NOTES.md` explaining how to verify the controller is connected at runtime.
