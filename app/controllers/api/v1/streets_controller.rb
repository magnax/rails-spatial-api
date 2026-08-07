# frozen_string_literal: true

class Api::V1::StreetsController < ApiController
  def index
    render json: Streets::IndexQuery.call(index_params)
  end

  private

  def index_params
    params.permit(:order)
  end
end