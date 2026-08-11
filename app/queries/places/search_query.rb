# frozen_string_literal: true

module Places
  class SearchQuery < ApplicationQuery
    def initialize(params = {})
      @params = params
    end

    def call
      return Formatters::ErrorResponseJson.render if invalid_params?
      return Formatters::SimpleJson.render(results, render_type: 'objects') if simple_format?

      Formatters::FeatureCollection.render(results)
    end

    private

    def invalid_params?
      radius.present? && (lon.blank? || lat.blank?)
    end

    def simple_format?
      @params[:json]&.downcase == 'simple'
    end
    
    def results
      @results ||= map_features(all_features)
    end

    def all_features
      q = query_by_type

      q = radius_query(q) if radius_query?
      q = q.order(name: direction) if order.present?
      
      q.select(fields)
    end

    def query_by_type
      return amenities if @params[:amenity].present?

      points_by_type
    end

    def map_features(objects)
      objects.map do |obj|
        {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [obj[:lon], obj[:lat]]
          },
          properties: {
            place_type: place_type,
            name: obj.name || obj.alt_name || amenity
          }
        }
      end
    end
    
    def amenities
      Point.where(amenity: amenity)
    end
    
    def points_by_type
      Point.where("#{place_type} = ?", @params[:place_name])
    end
    
    def fields
      "name, #{name_column} as alt_name, " \
      "ST_X(ST_Transform(way, 4326)) AS lon, " \
      "ST_Y(ST_Transform(way, 4326)) AS lat"
    end

    def radius_query?
      radius.present? && lon.present? && lat.present?
    end

    def radius_query(query)
      query.where("ST_DWithin(way, #{center}, #{radius})")
    end
    
    def center
      "ST_Transform(ST_SetSRID(ST_MakePoint(#{lon}, #{lat}), 4326), 3857)"
    end

    def lon
      location_param.try :[], 0
    end
    
    def lat
      location_param.try :[], 1
    end

    def location_param
      @location_param ||= @params[:loc]&.split(',')&.map(&:strip)
    end
    
    def radius
      @radius ||= decode_radius(@params[:radius] || @params[:r])
    end
    
    def decode_radius(value)
      return unless value.present?
      
      m = value.match(/\s*(\d{1,5})\s*(m|km|k)?/)
      return unless m

      v = m.try(:[], 1).to_i
      unit = m.try(:[], 2)

      v = v * 1000 if unit == 'km' || unit == 'k'

      v
    end

    def amenity
      @amenity ||= @params[:amenity]
    end

    def place_type
      @place_type ||= @params[:place_type]&.singularize || 'amenity'
    end

    def name_column
      Point::COLUMN_MAPPING[place_type] || 'name'
    end

    def direction
      (%w[asc desc] & [order]).first || 'asc'
    end

    def order
      @params[:order]&.downcase
    end
  end
end