# frozen_string_literal: true
require 'benchmark'

module Facter
  module Framework
    module Benchmarking
      class Timer
        class << self
          def measure
            time = Benchmark.measure { yield }

            puts "fact name:, took: #{time.format('%t')}"

            time
          end

          def measure_for_fact(fact_name)
            time = Benchmark.measure { yield }

            puts "fact name #{fact_name}, took: #{time.format('%t')}"

            time
          end
        end
      end
    end
  end
end


