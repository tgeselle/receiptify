RSpec.describe Receiptify do
  describe '.process' do
    let(:fixed_time) { Time.new(2024, 12, 17, 20, 24, 16) }

    let(:input1) do
      <<~INPUT
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT
    end

    let(:expected_output1) do
      <<~OUTPUT
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      OUTPUT
    end

    it 'processes input and prints correct receipt', capture_output: false do
      expect { described_class.process(raw_input: input1) }.to output(expected_output1).to_stdout
    end

    let(:input2) do
      <<~INPUT
        1 imported box of chocolates at 10.00
        1 imported bottle of perfume at 47.50
      INPUT
    end

    let(:expected_output2) do
      <<~OUTPUT
        1 imported box of chocolates: 10.50
        1 imported bottle of perfume: 54.65
        Sales Taxes: 7.65
        Total: 65.15
      OUTPUT
    end

    it 'handles imported items correctly', capture_output: false do
      expect { described_class.process(raw_input: input2) }.to output(expected_output2).to_stdout
    end

    let(:input3) do
      <<~INPUT
        1 imported bottle of perfume at 27.99
        1 bottle of perfume at 18.99
        1 packet of headache pills at 9.75
        3 imported boxes of chocolates at 11.25
      INPUT
    end

    let(:expected_output3) do
      <<~OUTPUT
        1 imported bottle of perfume: 32.19
        1 bottle of perfume: 20.89
        1 packet of headache pills: 9.75
        3 imported boxes of chocolates: 35.55
        Sales Taxes: 7.90
        Total: 98.38
      OUTPUT
    end

    it 'handles mixed items correctly', capture_output: false do
      expect { described_class.process(raw_input: input3) }.to output(expected_output3).to_stdout
    end

    context 'with invalid input' do
      it 'handles empty input' do
        expect { described_class.process(raw_input: '') }.to output(/Sales Taxes: 0.00\nTotal: 0.00/).to_stdout
      end

      it 'raises error for nil input' do
        expect { described_class.process(raw_input: nil) }.to raise_error(ArgumentError)
      end
    end

    context 'with edge cases' do
      it 'handles input with extra whitespace' do
        input = "  1 book at 12.49  \n  1 music CD at 14.99  "
        expect { described_class.process(raw_input: input) }.not_to raise_error
      end

      it 'handles very large quantities' do
        input = "999999 book at 12.49"
        expect { described_class.process(raw_input: input) }.not_to raise_error
      end

      it 'handles very large prices' do
        input = "1 book at 9999999.99"
        expect { described_class.process(raw_input: input) }.not_to raise_error
      end
    end
  end

  describe '.logger' do
    it 'returns a logger instance' do
      expect(described_class.logger).to be_a(Logger)
    end

    it 'memoizes the logger' do
      logger = described_class.logger
      expect(described_class.logger).to equal(logger)
    end
  end
end
