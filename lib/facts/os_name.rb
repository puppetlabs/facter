class LinuxFacter

  def initialize(searched_facts)
    facts = Facter::FactLoader.load(:linux)
    searched_facts ||= facts
    matched_facts = []

    matched_facts = {}
    searched_facts.each do |searched_fact|

      matched_facts << Facter::OptionParser.parse(searched_fact, facts)
    end

    resolve_matched_facts(matched_facts)
  end

  def create_fact_list
    {
      'networking' => 'Network',
      'networking.interface' => 'NetworkInterface'
    }
  end

  def resolve_matched_facts(matched_facts)
    threads = []
    results = {}

    matched_facts.each do |matched_fact|
      threads << Thread.new do
        matched_fact[0].new(matched_fact[1])
      end
    end

    threads.each do |t|
      t.join
      results.merge!(t.value)
    end
  end
end



class NetworkInterface < Fact

  def initialize(search)

  end

end


def Fact

end
