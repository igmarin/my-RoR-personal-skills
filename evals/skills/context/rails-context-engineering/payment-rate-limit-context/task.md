# Load Context Before Modifying an Existing Rails App

## Problem/Feature Description

You've been asked to add a **rate-limiting feature** to a payments API. Before writing any code or spec, you must load the project's context following the `rails-context-engineering` skill: read the schema, inspect the routes, find the nearest patterns, and surface any ambiguities to the human.

The project files are provided below. Extract them before beginning.

=============== FILE: db/schema.rb (excerpt) ===============
ActiveRecord::Schema[7.1].define(version: 2024_03_01_000001) do
  create_table :payments, force: :cascade do |t|
    t.integer  :user_id, null: false
    t.string   :status, default: "pending"
    t.integer  :amount_cents, null: false
    t.string   :currency, default: "USD"
    t.string   :provider_reference
    t.jsonb    :metadata, default: {}
    t.timestamps
  end

  create_table :users, force: :cascade do |t|
    t.string :email, null: false
    t.string :role, default: "standard"
    t.boolean :rate_limit_exempt, default: false
    t.timestamps
  end

  create_table :rate_limit_rules, force: :cascade do |t|
    t.string  :scope, null: false  # e.g. "payments:create"
    t.integer :max_requests, null: false
    t.integer :window_seconds, null: false
    t.timestamps
  end
end
=============== END FILE ===============

=============== FILE: config/routes.rb ===============
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :payments, only: [:index, :create, :show]
      resources :users,    only: [:show, :update]
    end
  end
end
=============== END FILE ===============

=============== FILE: app/services/payments/create_payment_service.rb (excerpt) ===============
# frozen_string_literal: true

module Payments
  class CreatePaymentService
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @user   = params.fetch(:user)
      @amount = params.fetch(:amount_cents)
    end

    def call
      validate!
      payment = Payment.create!(user: @user, amount_cents: @amount, currency: 'USD')
      { success: true, response: { payment: payment } }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, response: { error: { message: e.message } } }
    end

    private

    def validate!
      raise ArgumentError, "amount must be positive" unless @amount.positive?
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `docs/context_analysis.md` — A structured context analysis containing:
  1. **Schema summary** — key models, their relevant fields, and relationships inferred from the schema
  2. **Route map** — the available API endpoints with HTTP verb and path
  3. **Nearest pattern** — how the existing `CreatePaymentService` informs the pattern for the new rate-limiting feature
  4. **Ambiguities** — at least 3 questions you would ask the human before writing code (e.g. Redis vs DB-backed rate limiting, response code on limit exceeded, exempt logic)
  5. **Proposed integration point** — where rate limiting would hook in (controller concern? middleware? service?)
