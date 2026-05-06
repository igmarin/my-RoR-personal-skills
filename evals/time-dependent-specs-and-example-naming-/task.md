# Trial Subscription Spec Coverage

## Problem/Feature Description

A B2B SaaS product has a `Subscription` model that tracks trial periods, expiration, and billing cycle boundaries. The model was written by a contractor and has minimal test coverage. The product team needs confidence that the temporal logic is well-tested before the billing migration goes out next sprint.

Your task is to write a thorough RSpec spec file for the `Subscription` model, covering all of its public predicate methods. Each method involves time comparisons, so the tests need to work reliably regardless of when they are run.

## Output Specification

Produce the following file:
- `spec/models/subscription_spec.rb` — complete RSpec spec covering all public predicate methods on the model

Do not modify or add any other files.

## Input Files

The following files are provided as input. Extract them before beginning.

=============== FILE: app/models/subscription.rb ===============
# frozen_string_literal: true

class Subscription < ApplicationRecord
  TRIAL_DAYS = 14

  belongs_to :user

  # Returns true if the subscription is still within the trial period
  def trial?
    created_at > TRIAL_DAYS.days.ago
  end

  # Returns true if the subscription's expiry date has passed
  def expired?
    expires_at < Time.current
  end

  # Returns the number of whole days remaining before expiry (negative if expired)
  def days_remaining
    ((expires_at - Time.current) / 1.day).ceil
  end

  # Returns true if the subscription is active: not expired and confirmed by billing
  def active?
    !expired? && confirmed?
  end
end

=============== FILE: db/schema.rb (excerpt) ===============
create_table "subscriptions", force: :cascade do |t|
  t.bigint   "user_id",      null: false
  t.datetime "expires_at",   null: false
  t.boolean  "confirmed",    default: false, null: false
  t.datetime "created_at",   null: false
  t.datetime "updated_at",   null: false
end
