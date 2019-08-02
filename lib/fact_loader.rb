module Facter
  class FactLoader
    def self.load(os)
      # load facts/#{os}/*.rb
      loaded_facts = {}
      classes = Linux.constants.select {|c| Linux.const_get(c).is_a? Class}

      classes.each do |class_name|
        klass = Kernel.const_get("Facter::#{os.capitalize}::" + class_name.to_s)
        fact_name = klass::FACT_NAME
        loaded_facts.merge!(fact_name => klass)
      end

      loaded_facts
    end

    # def loadClasses()
    #   Dir["#{File.dirname(__FILE__)}/lib/facter/linux/*.rb"].each {|file| load file}
    # end
  end

  # FactLoader.new.loadClasses
  # classes = Linux.constants
  # puts classes
end



