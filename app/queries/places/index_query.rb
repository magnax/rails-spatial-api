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

      result = all_features.sort_by do |obj|
        obj[:properties][:text]
      end

      result = result.reverse if order == 'desc'
      result
    end

    def all_features
      @all_features ||= map_features(features).uniq
    end
      
    def map_features(objects)
      objects.map do |obj|
        {
          type: 'Feature',
          properties: {
            text: obj.place_type == 'amenity' ? obj.place_name : "#{obj.place_type}/#{obj.place_name}"
          }
        }
      end
    end

    def features
      Point.where('COALESCE(amenity, leisure, man_made, shop, tourism) IS NOT NULL')
           .select('CASE WHEN amenity is not null THEN \'amenity\''\
                        'WHEN leisure is not null THEN \'leisure\''\
                        'WHEN man_made is not null THEN \'man_made\''\
                        'WHEN shop is not null THEN \'shop\''\
                        'WHEN tourism is not null THEN \'tourism\''\
                        'ELSE NULL '\
                   'END as place_type, '\
                   'COALESCE(amenity, leisure, man_made, shop, tourism) as place_name, name')
    end

    def direction
      (%w[asc desc] & [order]).first || 'asc'
    end

    def order
      @params[:order]&.downcase
    end
  end
end