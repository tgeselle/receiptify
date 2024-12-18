RSpec.describe Receiptify::ReceiptParser do
  describe '.parse' do
    context 'with valid input' do
      let(:input) do
        <<~INPUT
          2 book at 12.49
          1 music CD at 14.99
          1 chocolate bar at 0.85
        INPUT
      end

      it 'creates correct line items' do
        receipt = described_class.parse(input)
        expect(receipt.line_items.size).to eq(3)
        expect(receipt.line_items.first.quantity).to eq(2)
        expect(receipt.line_items.first.name).to eq('book')
        expect(receipt.line_items.first.price).to eq(12.49)
      end
    end

    context 'with invalid input' do
      it 'handles empty input' do
        receipt = described_class.parse("")
        expect(receipt.line_items).to be_empty
      end

      it 'skips malformed lines' do
        input = "invalid line\n1 book at 12.49"
        receipt = described_class.parse(input)
        expect(receipt.line_items.size).to eq(1)
      end
    end

    context 'with cached inputs' do
      let(:input) { "1 book at 12.49" }

      it 'reuses parsed results' do
        first_result = described_class.parse(input)
        second_result = described_class.parse(input)
        expect(first_result.line_items.first).to equal(second_result.line_items.first)
      end
    end

    context 'with malformed input' do
      it 'handles missing price' do
        input = "1 book at\n"
        receipt = described_class.parse(input)
        expect(receipt.line_items).to be_empty
      end

      it 'handles missing quantity' do
        input = "book at 12.49\n"
        receipt = described_class.parse(input)
        expect(receipt.line_items).to be_empty
      end

      it 'handles invalid price format' do
        input = "1 book at 12.4\n"
        receipt = described_class.parse(input)
        expect(receipt.line_items).to be_empty
      end
    end

    context 'with performance' do
      it 'caches parsed results efficiently' do
        input = "1 book at 12.49\n" * 1000
        time = Benchmark.realtime do
          described_class.parse(input)
        end
        expect(time).to be < 1.0 # Should parse 1000 lines in under 1 second
      end
    end
  end
end
