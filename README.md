# Receiptify

A Ruby application that calculates sales taxes and generates receipts based on different tax rules for various types of items. It handles basic sales tax, import duties, and provides tax exemptions for specific categories like books, food, and medical products.

## Projet Setup

This project was generated using:
```bash
bundle gem receiptify
```

## Features

- Calculates basic sales tax (10%) for applicable items
- Applies import duty (5%) for imported items
- Handles tax exemptions for books, food, and medical products
- Rounds up tax calculations to the nearest 0.05
- Formats receipts with proper item listing, tax totals, and final amounts
- Supports multiple items with different quantities
- Can generate random receipts for testing purposes

## Technical Design Decisions

### Item Classification Approach

One of the main challenges in this project was determining whether an item should be tax-exempt. In a production environment, we might use:
- Machine Learning classifiers to categorize items
- External product databases with category information
- Natural Language Processing (NLP) to analyze item descriptions

However, since this is a standalone application without external dependencies, we implemented a simpler but effective solution:

1. **Predefined Category Lists**
```ruby
TAX_EXEMPT_ITEMS = {
  food: ['chocolate', 'bread', 'milk', ...],
  book: ['book', 'novel', 'magazine', ...],
  medical: ['headache pills', 'medicine', ...]
}.freeze
```

2. **String Matching Strategy**
- Uses basic string inclusion to check if an item contains any exempt keywords
- Handles common variations of product names
- Case-insensitive matching for better reliability

3. **Limitations of Current Approach**
- Cannot handle unknown product types
- May incorrectly categorize items with similar names
- Requires manual updates to the exempt items list
- No fuzzy matching or spelling tolerance

4. **Potential Improvements**
With external libraries and services, we could implement more sophisticated classification:

a) **Machine Learning Solutions**:
- Use `classifier-reborn` for traditional ML-based categorization
- Train a model on a large dataset of products and their categories
- Use the model to classify new products

b) **Modern AI/LLM Integration**:
- Integrate ChatGPT/Claude/Other LLM APIs for intelligent product classification:
  The prompt could be something like:
  ```
  Classify the following item into one of these categories: food, book, medical, other.
  Item: chocolate-covered recipe book
  ```  
- That would be able to:
  - Complex product categorization
  - Handling ambiguous cases (e.g., "chocolate-covered recipe book")
  - Understanding context and variations in product descriptions
  - Multi-language support for international receipts

c) **Hybrid Approach**:
- Cache common classifications using traditional methods
- Fall back to LLM for uncertain or new items
- Build a learning system that improves classifications over time
- Use LLMs to periodically update and expand the predefined category lists

These improvements would make the system more robust and capable of handling:
- Complex or ambiguous product descriptions
- New products without manual updates
- Multiple languages and regional variations
- Context-dependent classifications

## Requirements

- Ruby 3.3.6
- Bundler

## Installation

1. Clone the repository:
```bash
git clone https://github.com/tgeselle/receiptify
cd receiptify
```

2. Install dependencies:
```bash
bin/setup
```

## Usage

The application can be run in two modes:

### Standard Mode
Run the application with three predefined receipt examples:
```bash
ruby main.rb
```

This will output three receipts:
1. Basic items (books, music CD, chocolate bar)
2. Imported items (chocolates and perfume)
3. Mixed items (imported and non-imported items with various tax rules)

### Random Receipt Mode
Generate a random receipt with 1-5 items:
```bash
ruby main.rb random
```

The random receipt generator will:
- Create 1-10 random items
- Randomly select from different categories (books, food, medical items, others)
- Have a 30% chance of making items imported
- Generate realistic prices between $5.00 and $50.00
- Apply appropriate tax rules based on item category and import status

Example random receipt output:
```
Random Receipt:
----------------------------------------
2 imported novel at 24.99
1 headache pills at 9.99
3 music CD at 15.49
Sales Taxes: 5.15
Total: 89.45
----------------------------------------
```

## Docker Usage

The project can be run in a Docker container:

1. Build the image:
```bash
docker build -t receiptify .
```

2. Run the application:
```bash
# Run standard mode (all receipts)
docker run receiptify

# Run with random receipt
docker run receiptify random

# Run benchmark
docker run receiptify benchmark
```

You can also build and run with docker-compose:

```bash
# Start the application
docker-compose up

# Run with different command
docker-compose run receiptify random
```

## Testing

Run the test suite:
```bash
bundle exec rspec
```

This will also generate a coverage report in the `coverage` directory.

### Performance Benchmarking

The application includes a benchmarking module to measure performance. You can use it in several ways:

1. From the command line:
```bash
ruby main.rb benchmark
```
This will run the default benchmark (100 iterations of processing a sample receipt).

2. From Ruby code:
```ruby
# Benchmark with default settings (100 iterations)
input = "1 book at 12.49\n1 music CD at 14.99"
Receiptify::Benchmarking.measure_performance(input)

# Benchmark with custom number of iterations
Receiptify::Benchmarking.measure_performance(input, 1000)
```

Example output:
```
Running Benchmark:
----------------------------------------
                          user     system      total        real
Receipt processing:    0.052000   0.004000   0.056000 (  0.056398)
----------------------------------------
```

The benchmark results show:
- user: CPU time spent in user mode
- system: CPU time spent in kernel mode
- total: sum of user and system time
- real: actual elapsed time
