module Receiptify
  # Represents a single item in a receipt, handling tax calculations and price computations
  # for both imported and domestic goods with different tax rates based on product category.
  class LineItem
    attr_reader :quantity, :name, :price

    # List of items that are exempt from basic sales tax, categorized by type
    TAX_EXEMPT_ITEMS = {
      food: Set.new(%w[chocolate bread milk potato tomato fruit vegetable rice meat egg cheese]),
      book: Set.new(%w[book novel magazine fiction literature]),
      medical: Set.new(%w[headache\ pills medicine band-aid ointment])
    }.freeze

    # Tax rates for different types of taxes
    TAX_RATES = {
      basic: 0.1,    # 10% basic sales tax
      import: 0.05   # 5% import duty
    }.freeze

    # Use Set for faster lookups
    TAX_EXEMPT_SET = Set.new(TAX_EXEMPT_ITEMS.values.reduce(:union)).freeze

    # Initializes a new line item with the given quantity, name, and price
    #
    # @param quantity [String, Integer] The quantity of items
    # @param name [String] The name/description of the item
    # @param price [String, Float] The unit price of the item
    # @raise [ArgumentError] If quantity is not positive, name is empty, or price is not positive
    def initialize(quantity:, name:, price:)
      @quantity = quantity.to_i
      @name = name.strip
      @price = price.to_f
      validate!
    end

    # Calculates the total price including all applicable taxes
    #
    # @return [Float] The total price including taxes
    def total_price
      @total_price ||= total_untaxed_price + total_tax
    end

    # Calculates the total tax amount (basic tax + import duty)
    #
    # @return [Float] The total tax amount
    def total_tax
      @total_tax ||= import_duty + basic_tax
    end

    private

    # Validates the line item attributes
    #
    # @raise [ArgumentError] If any of the validations fail
    def validate!
      raise ArgumentError, 'Quantity must be positive' unless quantity.positive?
      raise ArgumentError, 'Name cannot be empty' if name.empty?
      raise ArgumentError, 'Price must be positive' unless price.positive?
    end

    # Calculates the total price before taxes
    #
    # @return [Float] The total untaxed price
    def total_untaxed_price
      @total_untaxed_price ||= price * quantity
    end

    # Calculates the import duty if applicable
    #
    # @return [Float] The import duty amount
    def import_duty
      @import_duty ||= imported? ? calculate_tax(TAX_RATES[:import]) : 0
    end

    # Calculates the basic sales tax if applicable
    #
    # @return [Float] The basic tax amount
    def basic_tax
      @basic_tax ||= tax_exempt? ? 0 : calculate_tax(TAX_RATES[:basic])
    end

    # Calculates tax amount for a given rate
    #
    # @param rate [Float] The tax rate to apply
    # @return [Float] The calculated tax amount
    def calculate_tax(rate)
      @calculated_taxes ||= {}
      @calculated_taxes[rate] ||= round_up_to_nearest_five_cents(price * rate) * quantity
    end

    # Rounds up an amount to the nearest 0.05
    #
    # @param amount [Float] The amount to round
    # @return [Float] The rounded amount
    def round_up_to_nearest_five_cents(amount)
      (amount * 20).ceil / 20.0
    end

    # Checks if the item is exempt from basic sales tax
    #
    # @return [Boolean] true if the item is tax exempt
    def tax_exempt?
      @tax_exempt ||= TAX_EXEMPT_SET.any? { |item| downcased_name.include?(item) }
    end

    # Cache the downcased name for multiple uses
    def downcased_name
      @downcased_name ||= name.downcase
    end

    # Checks if the item is imported
    #
    # @return [Boolean] true if the item is imported
    def imported?
      @imported ||= downcased_name.include?('imported')
    end
  end
end
