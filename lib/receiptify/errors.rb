module Receiptify
  # Base error class for all Receiptify errors
  class Error < StandardError; end

  # Raised when input validation fails
  class ValidationError < Error; end

  # Raised when input parsing fails
  class ParseError < Error; end

  # Raised when tax calculation fails
  class TaxCalculationError < Error; end
end
