# frozen_string_literal: true

class BaseResolver
  def self.invalidate_cache
    @fact_list = {}
  end
end
