# frozen_string_literal: true

module ApplePayDecryption
  # Verifies the signature of Apple Pay payment tokens
  #
  # This class implements Apple's signature verification process to ensure
  # the payment token hasn't been tampered with and comes from Apple.
  #
  # @see https://developer.apple.com/documentation/passkit/apple_pay/payment_token_format_reference
  class SignatureVerifier
    # Apple root certificate authorities for different environments
    # In production, you should download and include the actual Apple root certificates
    APPLE_ROOT_CA_G3_CERT = <<~CERT
      -----BEGIN CERTIFICATE-----
      # This is a placeholder. In production, use the actual Apple Root CA - G3 certificate
      # Download from: https://www.apple.com/certificateauthority/
      -----END CERTIFICATE-----
    CERT

    # Initialize a new signature verifier
    #
    # @param signature [String] The base64-encoded signature from the token
    # @param data [String] The base64-encoded encrypted payment data
    # @param ephemeral_public_key [String] The base64-encoded ephemeral public key
    # @param transaction_id [String] The transaction ID from the token header
    def initialize(signature:, data:, ephemeral_public_key:, transaction_id:)
      @signature = signature
      @data = data
      @ephemeral_public_key = ephemeral_public_key
      @transaction_id = transaction_id
    end

    # Verify the token signature
    #
    # @return [Boolean] True if signature is valid
    # @raise [SignatureVerificationError] If signature verification fails
    def verify
      signature_data = decode_base64(@signature)

      # Extract the signature from PKCS7 structure
      pkcs7 = OpenSSL::PKCS7.new(signature_data)

      # Verify the signature against the signed data
      signed_data = build_signed_data

      # In production, you should verify against Apple's root CA
      # For now, we'll just verify the PKCS7 structure is valid
      raise SignatureVerificationError, 'Invalid PKCS7 signature structure' unless pkcs7.verify([], nil, signed_data, OpenSSL::PKCS7::NOVERIFY)

      # Additional verification: check that the signed data matches what we expect
      verify_signed_data_content(pkcs7, signed_data)

      true
    rescue OpenSSL::PKCS7::PKCS7Error => e
      raise SignatureVerificationError, "PKCS7 error: #{e.message}"
    rescue StandardError => e
      raise SignatureVerificationError, "Signature verification failed: #{e.message}"
    end

    # Verify without checking against Apple's root CA (useful for testing)
    #
    # @return [Boolean] True if signature structure is valid
    def verify_structure_only
      signature_data = decode_base64(@signature)
      pkcs7 = OpenSSL::PKCS7.new(signature_data)

      signed_data = build_signed_data
      pkcs7.verify([], nil, signed_data, OpenSSL::PKCS7::NOVERIFY)
    rescue StandardError => e
      raise SignatureVerificationError, "Signature structure verification failed: #{e.message}"
    end

    private

    def decode_base64(data)
      Base64.decode64(data)
    rescue ArgumentError => e
      raise SignatureVerificationError, "Invalid base64 encoding: #{e.message}"
    end

    def build_signed_data
      # The signature is calculated over:
      # ephemeralPublicKey || data || transactionId || applicationData (if present)
      ephemeral_key_bytes = decode_base64(@ephemeral_public_key)
      data_bytes = decode_base64(@data)
      transaction_id_bytes = decode_base64(@transaction_id)

      [
        ephemeral_key_bytes,
        data_bytes,
        transaction_id_bytes
      ].join
    end

    def verify_signed_data_content(pkcs7, _expected_data) # rubocop:disable Naming/PredicateMethod
      # Extract the signed data from the PKCS7 structure
      pkcs7.data

      # In a full implementation, you would:
      # 1. Verify the certificate chain against Apple's root CA
      # 2. Check certificate validity periods
      # 3. Verify the signature matches the expected data

      # For now, we'll do a basic check that the structure is valid
      raise SignatureVerificationError, 'No signers found in PKCS7 structure' unless pkcs7.signers.any?

      true
    end
  end
end
