# frozen_string_literal: true

class ApplicationController
  # Mock render method to test behavior
  def render(options = {})
    @_rendered = options
  end

  attr_reader :_rendered

  # Mock params
  def params
    @params ||= {}
  end

  def set_params(p)
    @params = p
  end
end
