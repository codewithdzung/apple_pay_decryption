# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-17

### Added
- Initial release of ApplePayDecryption gem
- Core decryption functionality for Apple Pay payment tokens
- Signature verification support
- Comprehensive error handling with specific error classes:
  - `ParseError` for invalid token format
  - `ValidationError` for missing required fields
  - `SignatureVerificationError` for invalid signatures
  - `DecryptionError` for decryption failures
- Well-structured architecture with separation of concerns:
  - `PaymentToken` class for token representation and validation
  - `Decryptor` class for handling decryption process
  - `SignatureVerifier` class for signature verification
- Comprehensive test suite with RSpec
- Complete documentation with usage examples
- Rails integration example
- Support for Ruby 3.1+

### Security
- Implements Apple's encryption standards (EC_v1)
- ECDH key agreement for secure key exchange
- AES-256-GCM encryption
- SHA-256 key derivation function
- PKCS7 signature verification

## [Unreleased]

### Planned Features
- Support for EC_v2 payment token format
- Integration with popular payment gateways
- CLI tool for testing token decryption
- Performance optimizations
- Additional validation options
- Support for Chinese payment networks
