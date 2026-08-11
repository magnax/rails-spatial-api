# frozen_string_literal: true

module Formatters
  module ErrorResponseJson
    def self.render()
      {
        type: 'Error',
        description: 'Wrong or missing location params. They should be in format: '\
        "'loc=[longitute],[latitude]', eg. 'loc=15.456789,53.123456'"
      }
    end
  end
end