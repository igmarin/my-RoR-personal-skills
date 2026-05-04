# Live Team Activity Feed for a Project Dashboard

## Problem/Feature Description

A software consultancy uses a Rails project management application. Each project has a dashboard page where team members can see activity as it happens — tasks completed, comments added, files uploaded. Currently the activity feed only updates when the page is refreshed, which means team members miss real-time collaboration events. The product team wants the feed to update automatically whenever any team member records an activity, without requiring a page refresh.

The Activity model already exists with `id`, `project_id`, `user_id`, `description`, and `created_at` columns. The `Project` model exists with a `has_many :activities` association. Your job is to wire up real-time feed updates so that when a new Activity is created (via the existing `ActivitiesController#create` action), it appears at the top of every team member's open dashboard for that project without a page reload. The existing page load should still render all activities without WebSocket — the real-time layer is additive.

## Output Specification

Produce the following files:

- `app/models/activity.rb` — the Activity model with broadcast configuration
- `app/views/projects/show.html.erb` — the project dashboard view with the real-time subscription and activity list
- `app/views/activities/_activity.html.erb` — the activity item partial
- `app/controllers/activities_controller.rb` — the create action (existing actions can be stubbed)
- `REALTIME_NOTES.md` — a short document describing how to verify the ActionCable subscription is active and what to check if updates are not appearing

## Input Files

The following file represents the current state before your changes. Extract it before beginning.

=============== FILE: app/models/activity.rb ===============
class Activity < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :description, presence: true
end
