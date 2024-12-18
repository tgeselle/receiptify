require_relative 'receiptify/version'
require_relative 'receiptify/line_item'
require_relative 'receiptify/receipt'
require_relative 'receiptify/receipt_parser'
require_relative 'receiptify/benchmarking'
require_relative 'receiptify/errors'
require 'logger'

# Main module for the Receiptify application
# Provides functionality for processing sales receipts with tax calculations
module Receiptify
  class Error < StandardError; end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    # Processes raw input text and prints a formatted receipt
    #
    # @param raw_input [String] The raw input text containing line items
    def process(raw_input:)
      logger.info "Processing receipt input"
      receipt = ReceiptParser.parse(raw_input)
      receipt.print
    rescue StandardError => e
      logger.error "Error processing receipt: #{e.message}"
      raise
    end
  end
end
