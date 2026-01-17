# frozen_string_literal: true

RSpec.describe ApplePayDecryption::PaymentToken do
  let(:valid_token_hash) do
    {
      'data' => 'QklOQVJZREFUQQ==',
      'signature' => 'U0lHTkFUVVJF',
      'version' => 'EC_v1',
      'header' => {
        'ephemeralPublicKey' => 'RVBIRU1FUkFMS0VZ',
        'publicKeyHash' => 'UFVCTEVZS0VZ',
        'transactionId' => 'VFJBTVNBQ1RJT04='
      }
    }
  end

  describe '#initialize' do
    context 'with valid hash' do
      it 'creates a payment token from hash' do
        token = described_class.new(valid_token_hash)
        expect(token.data).to eq('QklOQVJZREFUQQ==')
        expect(token.signature).to eq('U0lHTkFUVVJF')
        expect(token.version).to eq('EC_v1')
      end
    end

    context 'with valid JSON string' do
      it 'creates a payment token from JSON' do
        token = described_class.new(valid_token_hash.to_json)
        expect(token.data).to eq('QklOQVJZREFUQQ==')
        expect(token.version).to eq('EC_v1')
      end
    end

    context 'with invalid input' do
      it 'raises ParseError for invalid JSON' do
        expect do
          described_class.new('invalid json {')
        end.to raise_error(ApplePayDecryption::ParseError, /Invalid JSON/)
      end

      it 'raises ParseError for non-string/hash input' do
        expect do
          described_class.new(123)
        end.to raise_error(ApplePayDecryption::ParseError, /must be a JSON string or Hash/)
      end
    end

    context 'with missing required fields' do
      it 'raises ValidationError when data is missing' do
        token_hash = valid_token_hash.dup
        token_hash.delete('data')

        expect do
          described_class.new(token_hash)
        end.to raise_error(ApplePayDecryption::ValidationError, /Missing required fields: data/)
      end

      it 'raises ValidationError when header fields are missing' do
        token_hash = valid_token_hash.dup
        token_hash['header'].delete('ephemeralPublicKey')

        expect do
          described_class.new(token_hash)
        end.to raise_error(ApplePayDecryption::ValidationError, /Missing required header fields/)
      end

      it 'raises ValidationError when header is not a hash' do
        token_hash = valid_token_hash.dup
        token_hash['header'] = 'invalid'

        expect do
          described_class.new(token_hash)
        end.to raise_error(ApplePayDecryption::ValidationError, /Header must be a hash/)
      end
    end
  end

  describe '#to_h' do
    it 'returns the token as a hash' do
      token = described_class.new(valid_token_hash)
      expect(token.to_h).to eq(valid_token_hash)
    end
  end

  describe 'attribute readers' do
    let(:token) { described_class.new(valid_token_hash) }

    it 'exposes token attributes' do
      expect(token.data).to eq('QklOQVJZREFUQQ==')
      expect(token.signature).to eq('U0lHTkFUVVJF')
      expect(token.version).to eq('EC_v1')
      expect(token.header).to be_a(Hash)
      expect(token.header['ephemeralPublicKey']).to eq('RVBIRU1FUkFMS0VZ')
    end
  end
end
