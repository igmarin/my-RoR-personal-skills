# Add a Hotwire Turbo Stream to Live-Update a Notification Badge

## Problem/Feature Description

The notifications feature at HubApp currently requires a full page reload to update the unread count badge in the top navigation bar. The product team wants this badge to update live whenever a new notification is created — no page reload required.

The backend already has a `Notification` model and a `NotificationsController`. Your job is to wire up **Turbo Streams** so that:

1. When a `Notification` is created, a Turbo Stream broadcast updates the badge in the header partial.
2. The `NotificationsController#index` responds with both HTML and Turbo Stream format.
3. The existing `app/views/layouts/application.html.erb` subscribes to the notifications stream using `turbo_stream_from`.

The following files are provided. Extract them before beginning.

=============== FILE: app/models/notification.rb ===============
# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  scope :unread, -> { where(read_at: nil) }

  after_create_commit :broadcast_badge_update

  private

  def broadcast_badge_update
    # TODO: implement broadcast
  end
end
=============== END FILE ===============

=============== FILE: app/controllers/notifications_controller.rb ===============
# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    @unread_count  = current_user.notifications.unread.count
  end
end
=============== END FILE ===============

=============== FILE: app/views/layouts/application.html.erb ===============
<!DOCTYPE html>
<html>
  <head>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application" %>
    <%= javascript_importmap_tags %>
  </head>
  <body>
    <%= render "shared/navbar" %>
    <%= yield %>
  </body>
</html>
=============== END FILE ===============

=============== FILE: app/views/shared/_navbar.html.erb ===============
<nav>
  <a href="/">Home</a>
  <!-- TODO: add notification badge here -->
</nav>
=============== END FILE ===============

## Output Specification

Produce the following files:

- `app/models/notification.rb` — with `broadcast_badge_update` implemented using `broadcast_replace_to`
- `app/views/shared/_notification_badge.html.erb` — the badge partial (shows unread count)
- `app/views/layouts/application.html.erb` — with `turbo_stream_from` subscription added
- `app/views/shared/_navbar.html.erb` — renders the notification badge partial
- `app/views/notifications/index.turbo_stream.erb` — (optional) marks notifications as viewed on open
- `app/controllers/notifications_controller.rb` — responds to both `:html` and `:turbo_stream` formats

Do not add Stimulus or JavaScript files. Use only Turbo Streams and server-side broadcasts.
