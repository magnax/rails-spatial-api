# frozen_string_literal: true

class ApplicationQuery
  private_class_method :new

  def self.call(...)
    new(...).call
  end
end