# frozen_string_literal: true

module ApplePayDecryption
  # Handles the decryption of Apple Pay payment tokens
  #
  # This class implements the decryption algorithm specified by Apple for
  # processing payment tokens using merchant certificates and private keys.
  #
  # @see https://developer.apple.com/documentation/passkit/apple_pay/payment_token_format_reference
  class Decryptor
    APPLE_OID = "1.2.840.113635.100.6.32"
    MERCHANT_ID_FIELD = "1.2.840.113635.100.6.32"
    COUNTER = "\x00\x00\x00\x01"

    # Initialize a new decryptor
    #
    # @param data [String] The base64-encoded encrypted payment data
    # @param certificate_pem [String] The merchant certificate in PEM format
    # @param private_key_pem [String] The merchant private key in PEM format
    # @param ephemeral_public_key [String] The base64-encoded ephemeral public key
    # @param transaction_id [String] The transaction ID from the token header
    def initialize(data:, certificate_pem:, private_key_pem:, ephemeral_public_key:, transaction_id:)
      @data = data
      @certificate_pem = certificate_pem
      @private_key_pem = private_key_pem
      @ephemeral_public_key = ephemeral_public_key
      @transaction_id = transaction_id
    end

    # Decrypt the payment data
    #
    # @return [Hash] The decrypted payment data
    # @raise [DecryptionError] If decryption fails
    def decrypt
      encrypted_data = decode_base64(@data)
      ephemeral_public_key = load_ephemeral_public_key
      merchant_private_key = load_merchant_private_key

      # Perform ECDH key agreement
      shared_secret = perform_ecdh(merchant_private_key, ephemeral_public_key)

      # Derive symmetric encryption key
      symmetric_key = derive_symmetric_key(shared_secret)

      # Decrypt the data
      decrypted_json = decrypt_aes(symmetric_key, encrypted_data)

      # Parse and return the decrypted data
      JSON.parse(decrypted_json)
    rescue OpenSSL::OpenSSLError => e
      raise DecryptionError, "OpenSSL error during decryption: #{e.message}"
    rescue JSON::ParserError => e
      raise DecryptionError, "Failed to parse decrypted data: #{e.message}"
    rescue StandardError => e
      raise DecryptionError, "Decryption failed: #{e.message}"
    end

    private

    def decode_base64(data)
      Base64.decode64(data)
    rescue ArgumentError => e
      raise DecryptionError, "Invalid base64 encoding: #{e.message}"
    end

    def load_ephemeral_public_key
      key_data = decode_base64(@ephemeral_public_key)
      
      # The ephemeral public key is in X9.63 format
      # Create an EC key and set the public key point
      group = OpenSSL::PKey::EC::Group.new("prime256v1")
      point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(key_data, 2))
      
      ec_key = OpenSSL::PKey::EC.new(group)
      ec_key.public_key = point
      ec_key
    rescue OpenSSL::OpenSSLError => e
      raise DecryptionError, "Invalid ephemeral public key: #{e.message}"
    end

    def load_merchant_private_key
      OpenSSL::PKey::EC.new(@private_key_pem)
    rescue OpenSSL::OpenSSLError => e
      raise DecryptionError, "Invalid merchant private key: #{e.message}"
    end

    def perform_ecdh(private_key, public_key)
      private_key.dh_compute_key(public_key.public_key)
    rescue OpenSSL::OpenSSLError => e
      raise DecryptionError, "ECDH key agreement failed: #{e.message}"
    end

    def derive_symmetric_key(shared_secret)
      # Use KDF (Key Derivation Function) as specified by Apple
      # kdf = KDF(SHA256, sharedSecret, algorithm, partyU, partyV)
      merchant_id = extract_merchant_id
      
      kdf_input = [
        COUNTER,
        shared_secret,
        "\x0d", "id-aes256-GCM", # algorithm identifier
        "Apple",                  # partyU info
        merchant_id              # partyV info (merchant ID)
      ].join

      OpenSSL::Digest::SHA256.digest(kdf_input)
    end

    def extract_merchant_id
      certificate = OpenSSL::X509::Certificate.new(@certificate_pem)
      
      # Extract merchant ID from certificate extensions
      certificate.extensions.each do |ext|
        next unless ext.oid == MERCHANT_ID_FIELD
        
        # Parse the extension value to extract the merchant ID
        merchant_id_hex = ext.value.unpack1("H*")
        return [merchant_id_hex].pack("H*")
      end

      # Fallback: use transaction ID
      decode_base64(@transaction_id)
    rescue OpenSSL::OpenSSLError => e
      raise DecryptionError, "Failed to extract merchant ID: #{e.message}"
    end

    def decrypt_aes(symmetric_key, encrypted_data)
      # Extract initialization vector and encrypted data
      # The first 16 bytes are the IV, the rest is ciphertext + tag
      iv = encrypted_data[0...16]
      ciphertext_and_tag = encrypted_data[16..-1]
      
      # The last 16 bytes are the authentication tag
      auth_tag = ciphertext_and_tag[-16..-1]
      ciphertext = ciphertext_and_tag[0...-16]

      # Decrypt using AES-256-GCM
      cipher = OpenSSL::Cipher.new("aes-256-gcm")
      cipher.decrypt
      cipher.key = symmetric_key
      cipher.iv = iv
      cipher.auth_tag = auth_tag
      cipher.auth_data = ""

      cipher.update(ciphertext) + cipher.final
    rescue OpenSSL::Cipher::CipherError => e
      raise DecryptionError, "AES decryption failed: #{e.message}"
    end
  end
end
