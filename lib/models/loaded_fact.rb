module Facter
  class LoadedFact
    @fact_name
    @fact_class
    @fact_attributes

    attr_accessor :fact_name, :fact_class, :filter_tokens
  end
end
