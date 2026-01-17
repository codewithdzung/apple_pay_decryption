# frozen_string_literal: true

require_relative "lib/apple_pay_decryption/version"

Gem::Specification.new do |spec|
  spec.name = "apple_pay_decryption"
  spec.version = ApplePayDecryption::VERSION
  spec.authors = ["Nguyen Tien Dzung"]
  spec.email = ["dzung.nguyentien@every-pay.com"]

  spec.summary = "Ruby library for decrypting Apple Pay payment tokens"
  spec.description = <<~DESC
    A modern, well-tested Ruby library for decrypting Apple Pay payment tokens.
    Provides comprehensive error handling, signature verification, and a clean API
    for processing Apple Pay payments in your Ruby applications.
  DESC
  
  spec.homepage = "https://github.com/nguyentiendzung/apple_pay_decryption"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nguyentiendzung/apple_pay_decryption"
  spec.metadata["changelog_uri"] = "https://github.com/nguyentiendzung/apple_pay_decryption/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://github.com/nguyentiendzung/apple_pay_decryption/blob/master/README.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/nguyentiendzung/apple_pay_decryption/issues"

  # Specify which files should be added to the gem when it is released.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "openssl", "~> 3.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
  spec.add_development_dependency "yard", "~> 0.9"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
