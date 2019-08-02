module Facter
  class LoadedFact
    @fact_name
    @fact_class
    @fact_attributes

    attr_reader :fact_name, :fact_class, :filter_tokens
    attr_writer :fact_name, :fact_class, :filter_tokens
  end
end
