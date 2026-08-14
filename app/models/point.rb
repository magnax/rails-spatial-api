# frozen_string_literal: true

class Point < ApplicationRecord
  self.table_name = 'planet_osm_point'
  self.primary_key = 'osm_id'

  COLUMN_MAPPING = {
    'leisure' => 'sport',
    'shop' => 'shop',
    'tourism' => 'tourism',
    'man_made' => 'man_made'
  }
end