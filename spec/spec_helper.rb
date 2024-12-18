require "receiptify"
require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.before(:suite) do
    # Use a null logger that does nothing
    Receiptify.logger = Logger.new(File::NULL)
  end

  # Redirect stdout to null device during tests unless specifically testing output
  config.around(:each) do |example|
    if example.metadata[:capture_output] == false
      example.run
    else
      original_stdout = $stdout
      $stdout = File.new(File::NULL, 'w')
      example.run
      $stdout = original_stdout
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    # Disable logging during tests
    allow(Receiptify.logger).to receive(:info)
    allow(Receiptify.logger).to receive(:error)
  end
end
