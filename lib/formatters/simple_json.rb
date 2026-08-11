# frozen_string_literal: true

module Formatters
  module SimpleJson
    def self.render(objects)
      objects.map { |obj| obj[:properties][:text] }
    end
  end
end