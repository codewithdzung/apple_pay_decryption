# ApplePayDecryption

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.1.0-ruby.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

A modern, professional Ruby library for decrypting Apple Pay payment tokens. Built with best practices, comprehensive error handling, and production-ready code quality.

## Features

✨ **Modern Ruby** - Built for Ruby 3.1+ with modern syntax and patterns

🔒 **Secure** - Implements Apple's encryption standards with signature verification

🎯 **Well-Tested** - Comprehensive test suite with RSpec

📚 **Well-Documented** - Clear API documentation and usage examples

🚀 **Production-Ready** - Proper error handling and validation

🎨 **Clean Architecture** - Separation of concerns with dedicated classes for each responsibility

## Why ApplePayDecryption?

This gem improves upon existing solutions by providing:

- **Better Error Handling**: Specific error classes for different failure scenarios
- **Cleaner API**: Simple, intuitive interface with sensible defaults
- **Modern Code**: Uses Ruby 3.1+ features and follows current best practices
- **Comprehensive Validation**: Validates token structure before processing
- **Signature Verification**: Built-in support for verifying token signatures
- **Excellent Documentation**: Clear examples and API documentation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'apple_pay_decryption'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install apple_pay_decryption
```

## Prerequisites

To use this gem, you need:

1. **Apple Pay Merchant Certificate** - Obtained through your Apple Developer account
2. **Merchant Private Key** - Generated during the Apple Pay setup process
3. **Payment Token** - Received from Apple Pay in your iOS/web application

## Quick Start

```ruby
require 'apple_pay_decryption'

# Token received from Apple Pay
token_json = {
  "data" => "encrypted_payment_data",
  "signature" => "payment_signature",
  "version" => "EC_v1",
  "header" => {
    "ephemeralPublicKey" => "ephemeral_key",
    "publicKeyHash" => "key_hash",
    "transactionId" => "transaction_id"
  }
}.to_json

# Your merchant credentials
certificate_pem = File.read('merchant_cert.pem')
private_key_pem = File.read('merchant_key.pem')

# Decrypt the token
decrypted_data = ApplePayDecryption.decrypt(
  token_json,
  certificate_pem,
  private_key_pem
)

# Access payment information
puts decrypted_data['applicationPrimaryAccountNumber']  # Card number
puts decrypted_data['applicationExpirationDate']        # Expiration (YYMMDD)
puts decrypted_data['currencyCode']                     # Currency code
puts decrypted_data['transactionAmount']                # Amount
```

## Usage

### Basic Decryption

```ruby
# Simple decryption with signature verification
decrypted_data = ApplePayDecryption.decrypt(
  token_json,
  certificate_pem,
  private_key_pem
)
```

### Skip Signature Verification

```ruby
# Decrypt without signature verification (not recommended for production)
decrypted_data = ApplePayDecryption.decrypt(
  token_json,
  certificate_pem,
  private_key_pem,
  verify_signature: false
)
```

### Verify Signature Only

```ruby
# Verify the token signature without decrypting
if ApplePayDecryption.verify_signature(token_json)
  puts "Token signature is valid!"
end
```

### Using PaymentToken Class

```ruby
# Create a token object for more control
token = ApplePayDecryption::PaymentToken.new(token_json)

# Access token properties
puts "Version: #{token.version}"
puts "Header: #{token.header}"

# Decrypt
decrypted_data = token.decrypt(certificate_pem, private_key_pem)
```

### Error Handling

```ruby
begin
  decrypted_data = ApplePayDecryption.decrypt(
    token_json,
    certificate_pem,
    private_key_pem
  )
rescue ApplePayDecryption::ParseError => e
  # Invalid JSON or token format
  puts "Invalid token: #{e.message}"
rescue ApplePayDecryption::ValidationError => e
  # Missing required fields
  puts "Validation failed: #{e.message}"
rescue ApplePayDecryption::SignatureVerificationError => e
  # Signature verification failed
  puts "Invalid signature: #{e.message}"
rescue ApplePayDecryption::DecryptionError => e
  # Decryption failed
  puts "Decryption failed: #{e.message}"
rescue ApplePayDecryption::Error => e
  # Any other error
  puts "Error: #{e.message}"
end
```

## Decrypted Data Format

The decrypted payment data contains:

```ruby
{
  "applicationPrimaryAccountNumber" => "4109370251004320",  # Device account number
  "applicationExpirationDate" => "251231",                  # Expiration (YYMMDD)
  "currencyCode" => "840",                                  # ISO 4217 code (e.g., 840 = USD)
  "transactionAmount" => 1000,                              # Amount in smallest currency unit
  "deviceManufacturerIdentifier" => "040010030273",        # Device ID
  "paymentDataType" => "3DSecure",                         # Payment data type
  "paymentData" => {
    "onlinePaymentCryptogram" => "Af9x/QwAA/DjmU65oyc1MAABAAA=",  # 3DS cryptogram
    "eciIndicator" => "5"                                   # ECI indicator
  }
}
```

## Integration Examples

### Ruby on Rails

See [examples/rails_integration.rb](examples/rails_integration.rb) for a complete Rails integration example.

```ruby
class PaymentsController < ApplicationController
  def create
    token = params[:payment_token]
    
    decrypted_data = ApplePayDecryption.decrypt(
      token.to_json,
      MERCHANT_CERTIFICATE,
      MERCHANT_PRIVATE_KEY
    )
    
    # Process payment...
  rescue ApplePayDecryption::Error => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

### Sinatra

```ruby
post '/payments' do
  token = JSON.parse(request.body.read)
  
  decrypted_data = ApplePayDecryption.decrypt(
    token.to_json,
    settings.merchant_certificate,
    settings.merchant_private_key
  )
  
  # Process payment...
  
  json success: true
rescue ApplePayDecryption::Error => e
  status 422
  json error: e.message
end
```

## Development

After checking out the repo, run:

```bash
bin/setup     # Install dependencies
rake spec     # Run tests
bin/console   # Interactive console
```

To install this gem onto your local machine:

```bash
bundle exec rake install
```

## Testing

Run the test suite:

```bash
bundle exec rspec
```

With coverage:

```bash
bundle exec rspec --format documentation
```

## Architecture

The gem is organized into focused, single-responsibility classes:

- **`ApplePayDecryption`** - Main module with convenience methods
- **`PaymentToken`** - Represents and validates Apple Pay tokens
- **`Decryptor`** - Handles the decryption process
- **`SignatureVerifier`** - Verifies token signatures
- **`Errors`** - Custom error classes for different failure scenarios

## Security Considerations

1. **Always verify signatures in production** - Set `verify_signature: true` (default)
2. **Protect your private keys** - Never commit them to version control
3. **Use environment variables** - Store credentials securely
4. **Keep certificates updated** - Apple Pay certificates expire
5. **Validate decrypted data** - Always validate the decrypted payment information

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nguyentiendzung/apple_pay_decryption.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Make your changes and ensure tests pass
5. Commit your changes (`git commit -am 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Comparison with Other Gems

### vs. Gala

**ApplePayDecryption** improves upon [Gala](https://github.com/spreedly/gala) with:

- ✅ Better error handling with specific error classes
- ✅ Modern Ruby 3.1+ support
- ✅ Cleaner, more maintainable code architecture
- ✅ Comprehensive validation before processing
- ✅ Better documentation and examples
- ✅ More extensive test coverage
- ✅ Follows current Ruby best practices

## Resources

- [Apple Pay Documentation](https://developer.apple.com/apple-pay/)
- [Payment Token Format Reference](https://developer.apple.com/documentation/passkit/apple_pay/payment_token_format_reference)
- [Apple Pay on the Web](https://developer.apple.com/apple-pay/implementation/)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApplePayDecryption project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Author

**Nguyen Tien Dzung**

- GitHub: [@nguyentiendzung](https://github.com/nguyentiendzung)
- Email: dzung.nguyentien@every-pay.com

## Acknowledgments

- Inspired by the [Gala](https://github.com/spreedly/gala) gem by Spreedly
- Built with reference to Apple's official [Payment Token Format Reference](https://developer.apple.com/documentation/passkit/apple_pay/payment_token_format_reference)

---

**Note**: This is a professional-grade implementation suitable for production use. Always test thoroughly with your specific Apple Pay configuration before deploying to production.
