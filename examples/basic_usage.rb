#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "apple_pay_decryption"

# Example 1: Basic decryption
puts "Example 1: Basic Apple Pay Token Decryption"
puts "=" * 50

# The payment token you receive from your iOS app
token_json = {
  "data" => "encrypted_payment_data_from_apple_pay",
  "signature" => "payment_token_signature",
  "version" => "EC_v1",
  "header" => {
    "ephemeralPublicKey" => "ephemeral_public_key_from_apple",
    "publicKeyHash" => "hash_of_your_merchant_public_key",
    "transactionId" => "unique_transaction_identifier"
  }
}.to_json

# Your merchant certificate and private key (obtained from Apple Pay setup)
certificate_pem = File.read("path/to/your/merchant_certificate.pem")
private_key_pem = File.read("path/to/your/merchant_private_key.pem")

begin
  # Decrypt the payment token
  decrypted_data = ApplePayDecryption.decrypt(
    token_json,
    certificate_pem,
    private_key_pem
  )

  puts "Decryption successful!"
  puts "Decrypted payment data:"
  puts JSON.pretty_generate(decrypted_data)
  
  # The decrypted data will contain:
  # - applicationPrimaryAccountNumber: The device-specific account number
  # - applicationExpirationDate: Card expiration date (YYMMDD format)
  # - currencyCode: ISO 4217 numeric currency code
  # - transactionAmount: Transaction amount
  # - deviceManufacturerIdentifier: Device manufacturer identifier
  # - paymentDataType: Type of payment data (e.g., "3DSecure")
  # - paymentData: Additional payment data including cryptogram
  
rescue ApplePayDecryption::DecryptionError => e
  puts "Decryption failed: #{e.message}"
rescue ApplePayDecryption::SignatureVerificationError => e
  puts "Signature verification failed: #{e.message}"
end

# Example 2: Verify signature without decryption
puts "\n"
puts "Example 2: Signature Verification Only"
puts "=" * 50

begin
  if ApplePayDecryption.verify_signature(token_json)
    puts "Token signature is valid!"
  end
rescue ApplePayDecryption::SignatureVerificationError => e
  puts "Signature verification failed: #{e.message}"
end

# Example 3: Using the PaymentToken class directly
puts "\n"
puts "Example 3: Using PaymentToken Class Directly"
puts "=" * 50

begin
  token = ApplePayDecryption::PaymentToken.new(token_json)
  
  puts "Token version: #{token.version}"
  puts "Token header: #{token.header}"
  
  # Decrypt with options
  decrypted_data = token.decrypt(
    certificate_pem,
    private_key_pem,
    verify: true  # Set to false to skip signature verification
  )
  
  puts "Successfully decrypted!"
rescue ApplePayDecryption::ValidationError => e
  puts "Token validation failed: #{e.message}"
rescue ApplePayDecryption::ParseError => e
  puts "Token parsing failed: #{e.message}"
end

# Example 4: Error handling
puts "\n"
puts "Example 4: Comprehensive Error Handling"
puts "=" * 50

def process_apple_pay_token(token_data, cert, key)
  ApplePayDecryption.decrypt(token_data, cert, key)
rescue ApplePayDecryption::ParseError => e
  # Handle invalid JSON or token format
  puts "Invalid token format: #{e.message}"
  nil
rescue ApplePayDecryption::ValidationError => e
  # Handle missing required fields
  puts "Token validation failed: #{e.message}"
  nil
rescue ApplePayDecryption::SignatureVerificationError => e
  # Handle signature verification failures
  puts "Signature verification failed: #{e.message}"
  nil
rescue ApplePayDecryption::DecryptionError => e
  # Handle decryption failures
  puts "Decryption failed: #{e.message}"
  nil
rescue ApplePayDecryption::Error => e
  # Handle any other gem-specific errors
  puts "Apple Pay processing error: #{e.message}"
  nil
end

result = process_apple_pay_token(token_json, certificate_pem, private_key_pem)
if result
  puts "Payment processed successfully!"
  puts "Card number: #{result['applicationPrimaryAccountNumber']}"
  puts "Expiration: #{result['applicationExpirationDate']}"
end
