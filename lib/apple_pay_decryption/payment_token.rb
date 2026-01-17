# frozen_string_literal: true

module ApplePayDecryption
  # Represents an Apple Pay payment token
  #
  # This class handles the structure and validation of Apple Pay payment tokens
  # according to Apple's PKPaymentToken format.
  #
  # @see https://developer.apple.com/documentation/passkit/pkpaymenttoken
  class PaymentToken
    attr_reader :data, :signature, :version, :header

    # Initialize a payment token from JSON or Hash
    #
    # @param token_data [String, Hash] The payment token data
    # @raise [ParseError] If the token data is invalid
    # @raise [ValidationError] If required fields are missing
    def initialize(token_data)
      @token_hash = parse_token(token_data)
      validate_structure!
      extract_fields
    end

    # Decrypt the payment token
    #
    # @param certificate_pem [String] The merchant certificate in PEM format
    # @param private_key_pem [String] The merchant private key in PEM format
    # @param verify_signature [Boolean] Whether to verify the signature first
    # @return [Hash] The decrypted payment data
    # @raise [DecryptionError] If decryption fails
    # @raise [SignatureVerificationError] If signature verification fails (when enabled)
    def decrypt(certificate_pem, private_key_pem, verify_signature: true)
      verify_signature() if verify_signature

      decryptor = Decryptor.new(
        data: @data,
        certificate_pem: certificate_pem,
        private_key_pem: private_key_pem,
        ephemeral_public_key: @ephemeral_public_key,
        transaction_id: @transaction_id
      )

      decryptor.decrypt
    end

    # Verify the payment token signature
    #
    # @return [Boolean] True if signature is valid
    # @raise [SignatureVerificationError] If signature verification fails
    def verify_signature
      verifier = SignatureVerifier.new(
        signature: @signature,
        data: @data,
        ephemeral_public_key: @ephemeral_public_key,
        transaction_id: @transaction_id
      )

      verifier.verify
    end

    # Get the token as a hash
    #
    # @return [Hash] The token data
    def to_h
      @token_hash
    end

    private

    def parse_token(token_data)
      case token_data
      when String
        JSON.parse(token_data)
      when Hash
        token_data
      else
        raise ParseError, "Token must be a JSON string or Hash, got #{token_data.class}"
      end
    rescue JSON::ParserError => e
      raise ParseError, "Invalid JSON: #{e.message}"
    end

    def validate_structure!
      required_fields = %w[data signature version header]
      missing_fields = required_fields.reject { |field| @token_hash.key?(field) }

      unless missing_fields.empty?
        raise ValidationError, "Missing required fields: #{missing_fields.join(', ')}"
      end

      required_header_fields = %w[ephemeralPublicKey publicKeyHash transactionId]
      header = @token_hash["header"]
      
      unless header.is_a?(Hash)
        raise ValidationError, "Header must be a hash"
      end

      missing_header_fields = required_header_fields.reject { |field| header.key?(field) }
      unless missing_header_fields.empty?
        raise ValidationError, "Missing required header fields: #{missing_header_fields.join(', ')}"
      end
    end

    def extract_fields
      @data = @token_hash["data"]
      @signature = @token_hash["signature"]
      @version = @token_hash["version"]
      @header = @token_hash["header"]
      @ephemeral_public_key = @header["ephemeralPublicKey"]
      @public_key_hash = @header["publicKeyHash"]
      @transaction_id = @header["transactionId"]
      @application_data = @header["applicationData"]
    end
  end
end
