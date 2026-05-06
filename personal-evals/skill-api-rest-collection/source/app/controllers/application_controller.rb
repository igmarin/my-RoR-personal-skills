# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Mock render method
  def render(options = {})
    @_rendered = options
  end

  attr_reader :_rendered

  def params
    @params ||= ActionController::Parameters.new({})
  end

  def set_params(p)
    @params = ActionController::Parameters.new(p)
  end
end
