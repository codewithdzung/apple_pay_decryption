# frozen_string_literal: true

RSpec.describe ApplePayDecryption::SignatureVerifier do
  let(:signature) { 'U0lHTkFUVVJF' }
  let(:data) { 'RU5DUllQVEVEREFUQQ==' }
  let(:ephemeral_public_key) { 'RVBIRU1FUkFMS0VZ' }
  let(:transaction_id) { 'VFJBTVNBQ1RJT04=' }

  describe '#initialize' do
    it 'initializes with required parameters' do
      verifier = described_class.new(
        signature: signature,
        data: data,
        ephemeral_public_key: ephemeral_public_key,
        transaction_id: transaction_id
      )

      expect(verifier).to be_a(described_class)
    end
  end

  describe '#verify' do
    let(:verifier) do
      described_class.new(
        signature: signature,
        data: data,
        ephemeral_public_key: ephemeral_public_key,
        transaction_id: transaction_id
      )
    end

    context 'with invalid signature format' do
      let(:signature) { 'not-valid-pkcs7!' }

      it 'raises SignatureVerificationError' do
        expect do
          verifier.verify
        end.to raise_error(ApplePayDecryption::SignatureVerificationError)
      end
    end

    # NOTE: Full signature verification testing would require valid Apple Pay tokens
    # with proper PKCS7 signatures from Apple's infrastructure
  end
end
