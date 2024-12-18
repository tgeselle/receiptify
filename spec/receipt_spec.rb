RSpec.describe Receiptify::Receipt do
  let(:book) { Receiptify::LineItem.new(quantity: 2, name: 'book', price: 12.49) }
  let(:cd) { Receiptify::LineItem.new(quantity: 1, name: 'music CD', price: 14.99) }
  let(:chocolate) { Receiptify::LineItem.new(quantity: 1, name: 'chocolate bar', price: 0.85) }

  describe '#total_price' do
    let(:receipt) { described_class.new(line_items: [book, cd, chocolate]) }

    it 'calculates total price correctly' do
      expect(receipt.total_price).to eq(42.32) # (2 * 12.49) + (14.99 + 1.50) + 0.85
    end

    it 'memoizes the result' do
      first_call = receipt.total_price
      allow(receipt.line_items).to receive(:sum).and_raise('Should not be called twice')
      expect(receipt.total_price).to eq(first_call)
    end
  end

  describe '#total_tax' do
    let(:receipt) { described_class.new(line_items: [book, cd, chocolate]) }

    it 'calculates total tax correctly' do
      expect(receipt.total_tax).to eq(1.50) # No tax on books and chocolate, 1.50 on CD
    end
  end

  describe '#print' do
    let(:receipt) { described_class.new(line_items: [book, cd, chocolate]) }

    it 'outputs the correct format', capture_output: false do
      expected_output = <<~OUTPUT
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      OUTPUT

      expect { receipt.print }.to output(expected_output).to_stdout
    end
  end
end
