# frozen_string_literal: true

module ApplePayDecryption
  # Base error class for all ApplePayDecryption errors
  class Error < StandardError; end

  # Raised when decryption fails
  class DecryptionError < Error; end

  # Raised when signature verification fails
  class SignatureVerificationError < Error; end

  # Raised when token validation fails
  class ValidationError < Error; end

  # Raised when parsing fails
  class ParseError < Error; end
end
