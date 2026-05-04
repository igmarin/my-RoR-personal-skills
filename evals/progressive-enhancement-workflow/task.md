# Dynamic Search Results for a Job Board

## Problem/Feature Description

A job board startup has a Rails application where candidates search for open positions. The current search form does a full page reload on every submission, which feels sluggish. The CTO wants the search results to update dynamically as the user refines filters (job type, location, salary range) — but the feature must work for candidates on low-bandwidth connections or accessibility tools that disable JavaScript, so it cannot depend on JavaScript to function at all.

The search form currently lives in `app/views/jobs/index.html.erb` and posts to `JobsController#index`. The controller already handles filtering via query parameters. Your task is to enhance this feature progressively: start from the working HTML baseline, then layer in modern frontend enhancements in the appropriate order, adding a JavaScript interaction layer only if it provides value beyond what the server-side stack can offer.

Produce an implementation that clearly documents the enhancement layers added and, for each layer, how the behaviour was verified before moving to the next.

## Output Specification

Produce the following files:

- `app/controllers/jobs_controller.rb` — updated index (and any other needed) actions
- `app/views/jobs/index.html.erb` — the search form and results page
- `app/views/jobs/_job.html.erb` — job listing partial
- Any additional view templates required by your implementation
- `ENHANCEMENT_NOTES.md` — a walkthrough document describing each enhancement step applied, what was validated at each step, and how the feature behaves with JavaScript disabled

## Input Files

The following file represents the current baseline. Extract it before beginning.

=============== FILE: app/views/jobs/index.html.erb ===============
<h1>Find a Job</h1>

<%= form_with url: jobs_path, method: :get do |f| %>
  <%= f.select :job_type, ["Full-time", "Part-time", "Contract"], include_blank: "Any type" %>
  <%= f.text_field :location, placeholder: "City or remote" %>
  <%= f.submit "Search" %>
<% end %>

<div id="job_results">
  <% @jobs.each do |job| %>
    <div class="job-listing">
      <h2><%= job.title %></h2>
      <p><%= job.company %> · <%= job.location %></p>
    </div>
  <% end %>
</div>
