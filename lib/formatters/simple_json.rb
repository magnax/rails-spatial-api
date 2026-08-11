# frozen_string_literal: true

module Formatters
  module SimpleJson
    def self.render(objects, render_type: 'text')
      return map_as_text(objects) if render_type == 'text'

      map_as_objects(objects)
    end
    
    private
    
    def self.map_as_text(objects)
      objects.map { |obj| obj[:properties][:text] }
    end

    def self.map_as_objects(objects)
      objects.map do |obj| 
        {
          name: obj[:properties][:name],
          type: obj[:properties][:place_type],
          coords: obj[:geometry][:coordinates]
        }
      end
    end
  end
end