# frozen_string_literal: true

RSpec.describe ApplePayDecryption::Decryptor do
  let(:encrypted_data) { 'RU5DUllQVEVEREFUQQ==' }
  let(:ephemeral_public_key) { 'RVBIRU1FUkFMS0VZ' }
  let(:transaction_id) { 'VFJBTVNBQ1RJT04=' }
  let(:certificate_pem) { "-----BEGIN CERTIFICATE-----\nTEST\n-----END CERTIFICATE-----" }
  let(:private_key_pem) { "-----BEGIN EC PRIVATE KEY-----\nTEST\n-----END EC PRIVATE KEY-----" }

  describe '#initialize' do
    it 'initializes with required parameters' do
      decryptor = described_class.new(
        data: encrypted_data,
        certificate_pem: certificate_pem,
        private_key_pem: private_key_pem,
        ephemeral_public_key: ephemeral_public_key,
        transaction_id: transaction_id
      )

      expect(decryptor).to be_a(described_class)
    end
  end

  describe '#decrypt' do
    let(:decryptor) do
      described_class.new(
        data: encrypted_data,
        certificate_pem: certificate_pem,
        private_key_pem: private_key_pem,
        ephemeral_public_key: ephemeral_public_key,
        transaction_id: transaction_id
      )
    end

    context 'with invalid base64 data' do
      let(:encrypted_data) { 'not-valid-base64!' }

      it 'raises DecryptionError' do
        expect do
          decryptor.decrypt
        end.to raise_error(ApplePayDecryption::DecryptionError)
      end
    end

    context 'with invalid certificate' do
      let(:certificate_pem) { 'invalid certificate' }

      it 'raises DecryptionError' do
        expect do
          decryptor.decrypt
        end.to raise_error(ApplePayDecryption::DecryptionError)
      end
    end

    # NOTE: Full decryption testing would require valid Apple Pay test tokens
    # which are difficult to generate outside of Apple's ecosystem
  end
end
