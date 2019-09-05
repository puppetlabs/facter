# frozen_string_literal: true

class Path
  attr_accessor :fact, :spec

  def initialize(fact, spec)
    @fact = fact
    @spec = spec
  end
end
