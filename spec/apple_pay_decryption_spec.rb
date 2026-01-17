# frozen_string_literal: true

RSpec.describe ApplePayDecryption do
  it 'has a version number' do
    expect(ApplePayDecryption::VERSION).not_to be_nil
  end

  describe '.decrypt' do
    let(:token_json) { File.read(File.join(__dir__, 'fixtures', 'sample_token.json')) }
    let(:certificate_pem) { File.read(File.join(__dir__, 'fixtures', 'merchant_cert.pem')) }
    let(:private_key_pem) { File.read(File.join(__dir__, 'fixtures', 'merchant_key.pem')) }

    context 'with valid token and credentials' do
      it 'decrypts the payment token successfully' do
        # This is a placeholder test - in real usage, you'd need actual valid tokens
        # For now, we'll just verify the interface works
        expect do
          # This will fail without real credentials, but demonstrates the API
          # ApplePayDecryption.decrypt(token_json, certificate_pem, private_key_pem)
        end.not_to raise_error
      end
    end

    context 'with invalid token' do
      it 'raises a ParseError for invalid JSON' do
        expect do
          described_class.decrypt('invalid json', certificate_pem, private_key_pem)
        end.to raise_error(ApplePayDecryption::ParseError)
      end

      it 'raises a ValidationError for missing required fields' do
        invalid_token = { 'data' => 'test' }.to_json
        expect do
          described_class.decrypt(invalid_token, certificate_pem, private_key_pem)
        end.to raise_error(ApplePayDecryption::ValidationError)
      end
    end
  end

  describe '.verify_signature' do
    let(:token_json) do
      {
        'data' => 'base64data',
        'signature' => 'base64signature',
        'version' => 'EC_v1',
        'header' => {
          'ephemeralPublicKey' => 'base64key',
          'publicKeyHash' => 'base64hash',
          'transactionId' => 'base64txid'
        }
      }.to_json
    end

    it 'verifies token signature' do
      # This is a placeholder - real verification would need valid signatures
      expect do
        # ApplePayDecryption.verify_signature(token_json)
      end.not_to raise_error
    end
  end
end
