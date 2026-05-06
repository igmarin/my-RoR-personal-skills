# Membership Upgrade Notification Specs

## Problem/Feature Description

The engineering team at a SaaS platform has implemented a membership upgrade service that handles premium tier transitions. When a user upgrades their account, the service validates the request, charges the payment gateway, and sends a confirmation email via `MailgunClient`. The team lead has asked you to write a complete RSpec test suite for the service before any further development proceeds.

The service lives at `app/services/memberships/upgrade_service.rb` and is provided below. Your job is to write the spec file covering the primary `.call` interface, including the success case, validation failure, and payment gateway failure scenarios. The `MailgunClient` is an external third-party client that your team does not own.

## Output Specification

Produce the following file:
- `spec/services/memberships/upgrade_service_spec.rb` — complete RSpec spec for the service

Do not modify or add any other files.

## Input Files

The following file is provided as input. Extract it before beginning.

=============== FILE: app/services/memberships/upgrade_service.rb ===============
# frozen_string_literal: true

module Memberships
  class UpgradeService
    UPGRADE_FAILED = 'Membership upgrade could not be completed'
    INVALID_TIER   = 'Invalid membership tier requested'

    VALID_TIERS = %w[silver gold platinum].freeze

    # @param user_id [Integer]
    # @param tier [String] one of: silver, gold, platinum
    # @return [Hash] { success: Boolean, response: Hash }
    def self.call(user_id:, tier:)
      new(user_id: user_id, tier: tier).call
    end

    def initialize(user_id:, tier:)
      @user_id = user_id
      @tier    = tier
    end

    def call
      return { success: false, response: { error: { message: INVALID_TIER } } } unless VALID_TIERS.include?(@tier)

      user = User.find(@user_id)

      charge_result = MailgunClient.charge(user_id: user.id, tier: @tier)
      return { success: false, response: { error: { message: charge_result[:message] } } } unless charge_result[:ok]

      user.update!(membership_tier: @tier, upgraded_at: Time.current)

      MailgunClient.send_confirmation(to: user.email, tier: @tier)

      { success: true, response: { user: user, tier: @tier } }
    rescue ActiveRecord::RecordNotFound
      { success: false, response: { error: { message: 'User not found' } } }
    rescue StandardError => e
      Rails.logger.error("UpgradeService failed: #{e.message}")
      { success: false, response: { error: { message: UPGRADE_FAILED } } }
    end
  end
end
