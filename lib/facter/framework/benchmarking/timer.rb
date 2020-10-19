# frozen_string_literal: true

require 'benchmark'

module Facter
  module Framework
    module Benchmarking
      class Timer
        class << self
          def measure(fact_name, prefix_message = '')
            if Options[:timing]
              time = Benchmark.measure { yield }

              log = "fact '#{fact_name}', took: #{time.format('%r')} seconds"
              prefix_message = "#{prefix_message} " unless prefix_message.empty?
              puts "#{prefix_message}#{log}"
            else
              yield
            end
          end
        end
      end
    end
  end
end
