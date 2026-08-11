# frozen_string_literal: true

module Formatters
  module FeatureCollection
    def self.render(objects)
      {
        type: 'FeatureCollection',
        features: objects
      }
    end
  end
end