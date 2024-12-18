require_relative 'lib/receiptify'

SAMPLE_INPUTS = <<~INPUTS.split("\n\n").map(&:strip).freeze
  2 book at 12.49
  1 music CD at 14.99
  1 chocolate bar at 0.85

  1 imported box of chocolates at 10.00
  1 imported bottle of perfume at 47.50

  1 imported bottle of perfume at 27.99
  1 bottle of perfume at 18.99
  1 packet of headache pills at 9.75
  3 imported boxes of chocolates at 11.25
INPUTS

def generate_random_receipt
  items = []
  rand(1..10).times do
    items << generate_random_item
  end
  items.join("\n")
end

def generate_random_item
  quantity = rand(1..10)
  imported = rand < 0.3 ? 'imported ' : '' # 30% chance of being imported

  items = {
    books: ['book', 'novel', 'magazine'],
    food: ['chocolate bar', 'box of chocolates', 'candy'],
    medical: ['headache pills', 'bandages', 'cough syrup'],
    others: ['perfume', 'music CD', 'lamp', 'watch']
  }

  category = items.keys.sample
  name = "#{imported}#{items[category].sample}"
  price = (rand(5.0..50.0) * 2).round(2) / 2.0 # Generate prices like 12.49, 14.99

  "#{quantity} #{name} at #{format('%.2f', price)}"
end

def process_receipts
  case ARGV.first
  when 'random'
    puts "\nRandom Receipt:"
    puts '-' * 40
    Receiptify.process(raw_input: generate_random_receipt)
    puts '-' * 40
  when 'benchmark'
    puts "\nRunning Benchmark:"
    puts '-' * 40
    Receiptify::Benchmarking.measure_performance(SAMPLE_INPUTS.first)
    puts '-' * 40
  else
    SAMPLE_INPUTS.each_with_index do |input, index|
      puts "\nReceipt #{index + 1}:"
      puts '-' * 40
      Receiptify.process(raw_input: input)
      puts '-' * 40
    end
  end
end

process_receipts
