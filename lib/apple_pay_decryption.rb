# frozen_string_literal: true

require "openssl"
require "json"
require "base64"

require_relative "apple_pay_decryption/version"
require_relative "apple_pay_decryption/errors"
require_relative "apple_pay_decryption/payment_token"
require_relative "apple_pay_decryption/decryptor"
require_relative "apple_pay_decryption/signature_verifier"

module ApplePayDecryption
  class << self
    # Decrypt an Apple Pay payment token
    #
    # @param token_json [String, Hash] The payment token data from Apple Pay
    # @param certificate_pem [String] The merchant certificate in PEM format
    # @param private_key_pem [String] The merchant private key in PEM format
    # @param verify_signature [Boolean] Whether to verify the token signature (default: true)
    # @return [Hash] The decrypted payment data
    # @raise [DecryptionError] If decryption fails
    # @raise [SignatureVerificationError] If signature verification fails
    #
    # @example
    #   decrypted_data = ApplePayDecryption.decrypt(
    #     token_json,
    #     certificate_pem,
    #     private_key_pem
    #   )
    #
    def decrypt(token_json, certificate_pem, private_key_pem, verify_signature: true)
      token = PaymentToken.new(token_json)
      token.decrypt(certificate_pem, private_key_pem, verify_signature: verify_signature)
    end

    # Verify the signature of an Apple Pay payment token
    #
    # @param token_json [String, Hash] The payment token data from Apple Pay
    # @return [Boolean] True if signature is valid
    # @raise [SignatureVerificationError] If signature verification fails
    #
    def verify_signature(token_json)
      token = PaymentToken.new(token_json)
      token.verify_signature
      true
    end
  end
end
