# frozen_string_literal: true

class Api::V1::PlacesController < ApiController
  def index
    render json: Places::IndexQuery.call(index_params)
  end
  
  def search
    render json: Places::SearchQuery.call(search_params)
  end

  private

  def index_params
    params.permit(:json, :order)
  end

  def search_params
    params.permit(:amenity, :json, :loc, :order, :place_name, :place_type, :r, :radius)
  end
end