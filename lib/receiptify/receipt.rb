module Receiptify
  # Handles the formatting and display of a complete receipt,
  # including multiple line items, tax calculations, and totals
  class Receipt
    attr_reader :line_items

    # Predefine format strings as constants
    CURRENCY_FORMAT = '%.2f'.freeze
    SALES_TAXES_FORMAT = 'Sales Taxes: %s'.freeze
    TOTAL_FORMAT = 'Total: %s'.freeze

    # Initializes a new receipt with the given line items
    #
    # @param line_items [Array<LineItem>] The line items for the receipt
    def initialize(line_items:)
      @line_items = line_items
    end

    # Calculates the total price of all items including taxes
    #
    # @return [Float] The total price including taxes
    def total_price
      @total_price ||= line_items.sum(&:total_price)
    end

    # Calculates the total tax amount for all items
    #
    # @return [Float] The total tax amount
    def total_tax
      @total_tax ||= line_items.sum(&:total_tax)
    end

    # Prints the complete receipt including all line items and totals
    def print
      line_items.each { |item| print_line_item(item) }
      print_summary
    end

    private

    # Prints a single line item
    #
    # @param item [LineItem] The line item to print
    def print_line_item(item)
      puts format_line_item(item)
    end

    # Prints the receipt summary including total taxes and total price
    def print_summary
      puts format(SALES_TAXES_FORMAT, format_currency(total_tax))
      puts format(TOTAL_FORMAT, format_currency(total_price))
    end

    # Formats a line item for display
    #
    # @param item [LineItem] The line item to format
    # @return [String] The formatted line item string
    def format_line_item(item)
      @formatted_line_items ||= {}
      @formatted_line_items[item] ||= "#{item.quantity} #{item.name}: #{format_currency(item.total_price)}"
    end

    # Formats a currency amount
    #
    # @param amount [Float] The amount to format
    # @return [String] The formatted currency string
    def format_currency(amount)
      @formatted_currencies ||= {}
      @formatted_currencies[amount] ||= format(CURRENCY_FORMAT, amount)
    end
  end
end
