RSpec.describe Receiptify::LineItem do
  describe '#initialize' do
    context 'with valid parameters' do
      it 'creates a line item successfully' do
        item = described_class.new(quantity: 1, name: 'book', price: 12.49)
        expect(item.quantity).to eq(1)
        expect(item.name).to eq('book')
        expect(item.price).to eq(12.49)
      end

      it 'strips whitespace from name' do
        item = described_class.new(quantity: 1, name: ' book ', price: 12.49)
        expect(item.name).to eq('book')
      end
    end

    context 'with invalid parameters' do
      it 'raises error for zero quantity' do
        expect {
          described_class.new(quantity: 0, name: 'book', price: 12.49)
        }.to raise_error(ArgumentError, 'Quantity must be positive')
      end

      it 'raises error for empty name' do
        expect {
          described_class.new(quantity: 1, name: '', price: 12.49)
        }.to raise_error(ArgumentError, 'Name cannot be empty')
      end

      it 'raises error for zero price' do
        expect {
          described_class.new(quantity: 1, name: 'book', price: 0)
        }.to raise_error(ArgumentError, 'Price must be positive')
      end
    end

    context 'with edge cases' do
      it 'handles very long item names' do
        name = 'a' * 1000
        expect {
          described_class.new(quantity: 1, name: name, price: 10.00)
        }.not_to raise_error
      end

      it 'handles floating point quantities' do
        item = described_class.new(quantity: "1.5", name: 'book', price: 10.00)
        expect(item.quantity).to eq(1) # Should truncate to integer
      end

      it 'handles string prices' do
        item = described_class.new(quantity: 1, name: 'book', price: "10.99")
        expect(item.price).to eq(10.99)
      end
    end
  end

  describe 'tax calculations' do
    context 'for tax exempt items' do
      let(:book) { described_class.new(quantity: 1, name: 'book', price: 12.49) }
      let(:chocolate) { described_class.new(quantity: 1, name: 'chocolate bar', price: 0.85) }
      let(:pills) { described_class.new(quantity: 1, name: 'packet of headache pills', price: 9.75) }

      it 'applies no basic tax' do
        [book, chocolate, pills].each do |item|
          expect(item.total_tax).to eq(0)
        end
      end
    end

    context 'for taxable items' do
      let(:cd) { described_class.new(quantity: 1, name: 'music CD', price: 14.99) }

      it 'applies basic tax correctly' do
        expect(cd.total_tax).to eq(1.50) # 10% of 14.99 rounded up to nearest 0.05
      end
    end

    context 'for imported items' do
      let(:imported_chocolate) { described_class.new(quantity: 1, name: 'imported box of chocolates', price: 10.00) }
      let(:imported_perfume) { described_class.new(quantity: 1, name: 'imported bottle of perfume', price: 47.50) }

      it 'applies import duty to exempt items' do
        expect(imported_chocolate.total_tax).to eq(0.50) # 5% of 10.00
      end

      it 'applies both taxes to non-exempt imported items' do
        expect(imported_perfume.total_tax).to eq(7.15) # (10% + 5%) of 47.50
      end
    end

    context 'with multiple quantities' do
      let(:books) { described_class.new(quantity: 2, name: 'book', price: 12.49) }
      let(:imported_chocolates) { described_class.new(quantity: 3, name: 'imported box of chocolates', price: 11.25) }

      it 'calculates total price correctly for tax exempt items' do
        expect(books.total_price).to eq(24.98)
      end

      it 'calculates total price correctly for imported items' do
        expect(imported_chocolates.total_price).to eq(35.55)
      end
    end

    context 'tax rounding' do
      it 'rounds tax up to nearest 0.05' do
        # Test various tax amounts
        [
          [0.99, 1.00],   # 0.099 -> 0.10
          [1.01, 1.05],   # 0.101 -> 0.105
          [1.02, 1.05],   # 0.102 -> 0.105
          [2.42, 2.45],   # 0.242 -> 0.245
        ].each do |price, expected_tax|
          item = described_class.new(quantity: 1, name: 'music CD', price: price * 10)
          expect(item.total_tax).to eq(expected_tax)
        end
      end
    end
  end
end
