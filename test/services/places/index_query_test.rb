# frozen_string_literal: true

require 'test_helper'

class PlacesIndexQueryTest < ActiveSupport::TestCase
  def call_service(params)
    Places::IndexQuery.call(params)
  end

  test 'works' do
    create(:point, amenity: 'bench')
    create(:point, amenity: 'bench')

    res = call_service({})

    assert_equal 2, res.length
  end
end