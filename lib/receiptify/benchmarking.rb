require 'benchmark'

module Receiptify
  # Provides performance measurement utilities for the Receiptify application
  module Benchmarking
    # Measures the performance of receipt processing
    #
    # @param input [String] The receipt input to process
    # @param iterations [Integer] Number of times to run the benchmark
    # @return [Benchmark::Tms] The benchmark results
    # @example
    #   input = "1 book at 12.49"
    #   Receiptify::Benchmarking.measure_performance(input, 1000)
    def self.measure_performance(input, iterations = 100)
      Benchmark.bm do |x|
        x.report("Receipt processing:") do
          iterations.times { Receiptify.process(raw_input: input) }
        end
      end
    end
  end
end
