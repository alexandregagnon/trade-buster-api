# frozen_string_literal: true


module Helpers
  module Json
    def json
      @json ||= if defined?(response_body)
                  JSON.parse(response_body)
      else
                  JSON.parse(response.body)
      end
    end
  end
end
