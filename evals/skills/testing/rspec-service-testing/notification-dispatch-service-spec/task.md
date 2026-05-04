# Write RSpec Tests for a Notification Service Object

## Problem/Feature Description

The engineering team at PulseHR has a `NotificationDispatchService` that sends in-app and email notifications. The service was written without tests. Before refactoring it, the team needs a full RSpec spec suite covering its behavior.

The service is provided below. Extract it before beginning.

=============== FILE: app/services/notification_dispatch_service.rb ===============
# frozen_string_literal: true

class NotificationDispatchService
  CHANNELS = %w[email in_app].freeze

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @user    = params.fetch(:user)
    @message = params.fetch(:message)
    @channel = params.fetch(:channel, 'in_app')
  end

  def call
    validate!
    send_notification
    { success: true, response: { user_id: @user.id, channel: @channel } }
  rescue ArgumentError => e
    { success: false, response: { error: { message: e.message } } }
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.first(5).join("\n"))
    { success: false, response: { error: { message: 'An unexpected error occurred.' } } }
  end

  private

  def validate!
    raise ArgumentError, "user is required" unless @user
    raise ArgumentError, "message is required" if @message.blank?
    raise ArgumentError, "Invalid channel: #{@channel}" unless CHANNELS.include?(@channel)
  end

  def send_notification
    if @channel == 'email'
      UserMailer.notification_email(@user, @message).deliver_later
    else
      @user.notifications.create!(body: @message)
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `spec/services/notification_dispatch_service_spec.rb` — A complete RSpec spec suite for the service using the `rspec-service-testing` patterns.

The spec must cover:
- Missing user input
- Blank message
- Invalid channel
- Successful `in_app` dispatch (creates a notification record)
- Successful `email` dispatch (enqueues a mailer)
- Unexpected error in `send_notification`
