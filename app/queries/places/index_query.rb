# frozen_string_literal: true

module Places
  class IndexQuery < ApplicationQuery
    def initialize(params = {})
      @params = params
    end

    def call
      return Formatters::SimpleJson.render(all_names) if simple_format?

      Formatters::FeatureCollection.render(all_names)
    end

    private

    def simple_format?
      @params[:json]&.downcase == 'simple'
    end

    def all_names
      return all_features unless order

      all_features.sort_by do |obj|
        obj[:properties][:text]
      end
    end

    def all_features
      @all_features ||= map_features(
        amenities + 
        point_by_type('shop') + 
        point_by_type('leisure') + 
        point_by_type('tourism') + 
        point_by_type('man_made')
      )
    end

    def map_features(objects)
      objects.map do |obj|
        {
          type: 'Feature',
          properties: {
            text: obj
          }
        }
      end
    end

    def amenities
      Point.pluck(:amenity).uniq.compact
    end

    def point_by_type(point_type)
      Point.pluck(point_type.to_sym).uniq.compact.map do |name|
        "#{point_type}/#{name}"
      end
    end

    def direction
      (%w[asc desc] & [order]).first || 'asc'
    end

    def order
      @params[:order]&.downcase
    end
  end
end