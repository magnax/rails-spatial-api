# frozen_string_literal: true

module Streets
  class IndexQuery < ApplicationQuery
    def initialize(params = {})
      @params = params
    end

    def call
      {
        type: 'FeatureCollection',
        features: names
      }
    end

    private

    def names
      Line.where(highway: 'residential')
          .where.not(name: nil)
          .select(:name)
          .order(name: direction)
          .group(:name)
          .uniq
          .map do |line|
            {
              type: 'Feature',
              properties: {
                name: line[:name]
              }
            }
          end
    end

    def direction
      (%w[asc desc] & [order]).first || 'asc'
    end

    def order
      @params[:order].downcase
    end
  end
end