# frozen_string_literal: true

require "apple_pay_decryption"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Filter out lines from RSpec backtrace
  config.filter_run_when_matching :focus
  
  # Use color in output
  config.color = true
  
  # Use documentation format for detailed output
  config.default_formatter = "doc" if config.files_to_run.one?
end
