# frozen_string_literal: true

module Facter
  module Resolvers
    class DmiDecode < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { run_dmidecode(fact_name) }
        end

        def run_dmidecode(fact_name)
          output = Facter::Core::Execution.execute('dmidecode', logger: log)

          @fact_list[:virtualbox_version] = output.match(/vboxVer_(\S+)/)&.captures&.first
          @fact_list[:virtualbox_revision] = output.match(/vboxRev_(\S+)/)&.captures&.first
          @fact_list[fact_name]
        end
      end
    end
  end
end
