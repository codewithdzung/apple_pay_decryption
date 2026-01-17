# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# Rubocop tasks
begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # Rubocop is optional for development
end

# YARD documentation tasks
begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.files = ["lib/**/*.rb"]
    t.options = ["--markup=markdown", "--output-dir=doc"]
  end
rescue LoadError
  # YARD is optional for development
end

# Default task
task default: %i[spec]

# Quality task: runs tests and linting
desc "Run tests and code quality checks"
task :quality do
  Rake::Task[:spec].invoke
  
  if defined?(RuboCop)
    Rake::Task[:rubocop].invoke
  else
    puts "⚠️  Rubocop not installed. Run 'bundle install' to enable code quality checks."
  end
end

# Console task for quick testing
desc "Open an interactive console with the gem loaded"
task :console do
  require "irb"
  require "apple_pay_decryption"
  ARGV.clear
  IRB.start
end

# Installation verification
desc "Verify gem installation and dependencies"
task :verify do
  require "apple_pay_decryption"
  
  puts "✅ ApplePayDecryption gem loaded successfully"
  puts "   Version: #{ApplePayDecryption::VERSION}"
  puts "   Ruby Version: #{RUBY_VERSION}"
  puts "   OpenSSL Version: #{OpenSSL::OPENSSL_VERSION}"
  
  # Check if OpenSSL supports required ciphers
  cipher = OpenSSL::Cipher.new("aes-256-gcm")
  puts "✅ AES-256-GCM cipher available"
  
  puts "\n🎉 All checks passed! The gem is ready to use."
rescue LoadError => e
  puts "❌ Failed to load gem: #{e.message}"
  exit 1
rescue StandardError => e
  puts "❌ Verification failed: #{e.message}"
  exit 1
end
