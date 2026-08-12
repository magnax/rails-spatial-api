# frozen_string_literal: true

require 'test_helper'

class PlacesIndexQueryTest < ActiveSupport::TestCase
  def call_service(params = {})
    Places::IndexQuery.call(params)
  end

  test 'response with empty params' do
    create(:point, amenity: 'bench')
    create(:point, amenity: 'parking')

    res = call_service

    assert_equal 2, res.length
    assert_equal 'FeatureCollection', res[:type]
    assert_equal 2, res[:features].length
    assert_equal 2, res[:features].pluck(:properties).length
    assert_equal ['bench', 'parking'], res[:features].pluck(:properties).pluck(:text).sort
  end

  test 'response with sorting' do
    create(:point, amenity: 'bench')
    create(:point, amenity: 'parking')

    params = {
      order: 'desc'
    }

    res = call_service(params)

    assert_equal 2, res.length
    assert_equal 'parking', res[:features].first[:properties][:text]
    assert_equal 'bench', res[:features].last[:properties][:text]
  end
end