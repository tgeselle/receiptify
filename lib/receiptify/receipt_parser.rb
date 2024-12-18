module Receiptify
  # Handles parsing of raw input text into Receipt objects
  # by extracting line item information and creating appropriate objects
  class ReceiptParser
    # Regular expression pattern for matching line item entries
    # Format: "{quantity} {name} at {price}"
    # Example: "1 book at 12.49"
    LINE_ITEM_PATTERN = /
      ^               # Start of line
      (\d+)          # Quantity (capture group 1)
      \s+            # Whitespace
      (.+?)          # Name (capture group 2, non-greedy)
      \s+at\s+       # " at "
      (\d+\.\d{2})   # Price (capture group 3)
      $              # End of line
    /x

    class << self
      # Parses raw input text into a Receipt object
      #
      # @param raw_input [String] The raw input text to parse
      # @return [Receipt] A new Receipt object containing the parsed line items
      # @raise [ParseError] If the input format is invalid
      def parse(raw_input)
        raise ArgumentError, "Input cannot be nil" if raw_input.nil?

        # Cache stripped input to avoid multiple strip operations
        @stripped_input ||= {}
        @stripped_input[raw_input] ||= raw_input.strip

        items = []
        @stripped_input[raw_input].each_line do |line|
          if (item = parse_line(line.strip))
            items << item
          end
        end
        Receipt.new(line_items: items)
      end

      private

      # Parses a single line of text into a LineItem object
      #
      # @param line [String] The line of text to parse
      # @return [LineItem, nil] A new LineItem object or nil if parsing fails
      # @example
      #   parse_line("1 book at 12.49") #=> #<LineItem @quantity=1, @name="book", @price=12.49>
      def parse_line(line)
        # Cache parsed lines to avoid reparsing identical lines
        @parsed_lines ||= {}
        return @parsed_lines[line] if @parsed_lines.key?(line)

        match = LINE_ITEM_PATTERN.match(line)
        return nil unless match

        quantity, name, price = match.captures
        @parsed_lines[line] = LineItem.new(
          quantity: quantity,
          name: name,
          price: price
        )
      end
    end
  end
end
