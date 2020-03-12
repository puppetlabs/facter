# frozen_string_literal: true

module Facter
  module FactsUtils
    class BytesConverter
      class << self
        def to_mb(value_in_bytes)
          (value_in_bytes / (1024.0 * 1024.0)).round(2)
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
