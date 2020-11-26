# frozen_string_literal: true

module Facter
  module Util
    module Macosx
      class SystemProfileExecutor
        @log = Log.new(self)

        class << self
          def execute(category_name)
            @log.debug "Executing command: system_profiler #{category_name}"
            output = Facter::Core::Execution.execute(
              "system_profiler #{category_name}", logger: @log
            )&.force_encoding('UTF-8')

            return unless output

            system_profiler_hash = output_to_hash(output)

            normalize_keys(system_profiler_hash)
          end

          private

          def output_to_hash(output)
            output.scan(/.*:[ ].*$/).map { |e| e.strip.match(/(.*?): (.*)/).captures }.to_h
          end

          def normalize_keys(system_profiler_hash)
            system_profiler_hash.map do |k, v|
              [k.downcase.tr(' ', '_').delete("\(\)").to_sym, v]
            end.to_h
          end
        end
      end
    end
  end
end
