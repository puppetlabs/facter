# frozen_string_literal: true

module Facter
  module FactsOptions
    def augment_with_facts_options!
      @options[:blocked_facts] = Facter::BlockList.instance.blocked_facts
      @options[:ttls] = @conf_reade.ttls
    end
  end
end
