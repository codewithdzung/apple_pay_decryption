# Contributing to ApplePayDecryption

First off, thank you for considering contributing to ApplePayDecryption! It's people like you that make this gem better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, test cases)
- **Describe the behavior you observed** and what you expected to see
- **Include Ruby version, gem version**, and OS information

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **Provide code examples** if applicable

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Add tests** for any new functionality
3. **Ensure all tests pass** (`bundle exec rspec`)
4. **Follow the Ruby style guide** (run `bundle exec rubocop`)
5. **Update documentation** as needed
6. **Write clear commit messages**

#### Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the CHANGELOG.md with your changes
3. Increase version numbers following [Semantic Versioning](https://semver.org/)
4. Your PR will be merged once it has been reviewed and approved

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/apple_pay_decryption.git
cd apple_pay_decryption

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Open console for testing
bundle exec rake console
```

## Coding Standards

### Ruby Style Guide

We follow the [Ruby Style Guide](https://rubystyle.guide/) with some modifications defined in `.rubocop.yml`.

### Testing

- Write tests for all new features
- Maintain or improve code coverage
- Use RSpec's expect syntax
- Group related tests with `describe` and `context`
- Use meaningful test descriptions

Example:

```ruby
RSpec.describe MyClass do
  describe "#my_method" do
    context "when valid input is provided" do
      it "returns expected result" do
        expect(subject.my_method("input")).to eq("output")
      end
    end

    context "when invalid input is provided" do
      it "raises an error" do
        expect { subject.my_method(nil) }.to raise_error(ArgumentError)
      end
    end
  end
end
```

### Documentation

- Add YARD documentation for public methods
- Include parameter types and return types
- Provide usage examples in documentation
- Update README.md for significant changes

Example:

```ruby
# Decrypt an Apple Pay payment token
#
# @param token [String] The payment token JSON
# @param cert [String] The merchant certificate PEM
# @param key [String] The merchant private key PEM
# @return [Hash] The decrypted payment data
# @raise [DecryptionError] If decryption fails
#
# @example
#   result = decrypt(token, cert, key)
#   puts result['applicationPrimaryAccountNumber']
#
def decrypt(token, cert, key)
  # implementation
end
```

## Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests after the first line

Example:

```
Add signature verification for payment tokens

- Implement PKCS7 signature verification
- Add SignatureVerificationError class
- Update tests and documentation

Fixes #123
```

## Testing Apple Pay Integration

Since Apple Pay tokens require Apple's infrastructure to generate:

1. Use the provided test fixtures for unit tests
2. For integration testing, use Apple's sandbox environment
3. Never commit real payment credentials or tokens
4. Document any special test setup requirements

## Release Process

Maintainers will handle releases following these steps:

1. Update version in `lib/apple_pay_decryption/version.rb`
2. Update CHANGELOG.md with release notes
3. Commit changes: `git commit -am "Release v0.x.0"`
4. Create tag: `git tag v0.x.0`
5. Push changes: `git push && git push --tags`
6. Build and push gem: `bundle exec rake release`

## Questions?

Feel free to open an issue with your question, or contact the maintainers directly.

## Recognition

Contributors will be recognized in:
- README.md Contributors section
- CHANGELOG.md for significant contributions
- GitHub's contributor graph

Thank you for contributing! 🎉
