module Facter
  class Base
    def initialize(searched_facts)
      facts = Facter::FactLoader.load(:linux)
      searched_facts ||= facts
      matched_facts = []

      searched_facts.each do |searched_fact|

        matched_facts << Facter::QueryParser.parse(searched_fact, facts)
      end

      resolve_matched_facts(matched_facts.flatten(1))
    end

    def resolve_matched_facts(matched_facts)
      threads = []
      results = {}

      matched_facts.each do |matched_fact|
        threads << Thread.new do
          fact_class = matched_fact.fact_class
          fact_class.new(matched_fact.filter_tokens).call_the_resolver!
        end
      end

      threads.each do |t|
        t.join
        results.merge!(t.value)
      end

      puts results.inspect
    end

    # def token_to_class(str)
    #   Kernel.const_get('Facter::Linux::'+str)
    # end
  end

  def self.new(args)
    Facter::Base.new(args)
  end
end



# class NetworkInterface < Fact

#   def initialize(search)

#   end

# end


# class Fact

# end
