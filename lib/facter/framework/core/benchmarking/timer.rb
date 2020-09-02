# frozen_string_literal: true
require 'benchmark'

module Facter
  module Framework
    module Benchmarking
      class Timer
        class << self
          def measure(fact_name)
            if Options[:timing]
              time = Benchmark.measure { yield }

              puts "fact `#{fact_name}`, took: #{time.format('%r')} seconds"
            else
              yield
            end
          end
        end
      end
    end
  end
end


