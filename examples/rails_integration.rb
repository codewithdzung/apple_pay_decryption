# frozen_string_literal: true

# Example: Integrating Apple Pay Decryption in a Rails Application

# 1. Add to your Gemfile:
# gem 'apple_pay_decryption'

# 2. Create an initializer: config/initializers/apple_pay.rb
# APPLE_PAY_CERTIFICATE = File.read(Rails.root.join('config', 'certs', 'merchant_cert.pem'))
# APPLE_PAY_PRIVATE_KEY = File.read(Rails.root.join('config', 'certs', 'merchant_key.pem'))

# 3. Create a controller to handle Apple Pay payments
class ApplePayPaymentsController < ApplicationController
  # POST /apple_pay_payments
  def create
    token_data = params.require(:payment_token)
    
    begin
      # Decrypt the Apple Pay token
      decrypted_payment = ApplePayDecryption.decrypt(
        token_data.to_json,
        APPLE_PAY_CERTIFICATE,
        APPLE_PAY_PRIVATE_KEY
      )
      
      # Process the payment
      payment = process_payment(decrypted_payment)
      
      if payment.success?
        render json: { 
          success: true, 
          transaction_id: payment.id 
        }, status: :created
      else
        render json: { 
          success: false, 
          error: payment.error_message 
        }, status: :unprocessable_entity
      end
      
    rescue ApplePayDecryption::SignatureVerificationError => e
      # Token signature is invalid - possible tampering
      Rails.logger.error("Apple Pay signature verification failed: #{e.message}")
      render json: { 
        success: false, 
        error: "Invalid payment token signature" 
      }, status: :forbidden
      
    rescue ApplePayDecryption::DecryptionError => e
      # Decryption failed - invalid credentials or corrupted data
      Rails.logger.error("Apple Pay decryption failed: #{e.message}")
      render json: { 
        success: false, 
        error: "Unable to process payment token" 
      }, status: :unprocessable_entity
      
    rescue ApplePayDecryption::Error => e
      # Other gem-specific errors
      Rails.logger.error("Apple Pay processing error: #{e.message}")
      render json: { 
        success: false, 
        error: "Payment processing error" 
      }, status: :internal_server_error
    end
  end
  
  private
  
  def process_payment(decrypted_data)
    # Extract payment information
    card_number = decrypted_data['applicationPrimaryAccountNumber']
    expiration = decrypted_data['applicationExpirationDate']
    cryptogram = decrypted_data.dig('paymentData', 'onlinePaymentCryptogram')
    amount = decrypted_data['transactionAmount']
    
    # Create a payment record
    Payment.create!(
      card_number: mask_card_number(card_number),
      card_expiration: format_expiration(expiration),
      cryptogram: cryptogram,
      amount: amount,
      payment_method: 'apple_pay',
      status: 'pending'
    )
    
    # Process with your payment gateway
    # gateway.process(card_number, expiration, cryptogram, amount)
  end
  
  def mask_card_number(number)
    # Mask all but last 4 digits
    return nil if number.nil?
    "****#{number[-4..-1]}"
  end
  
  def format_expiration(expiration)
    # Convert YYMMDD to MM/YY format
    return nil if expiration.nil? || expiration.length != 6
    "#{expiration[2..3]}/#{expiration[0..1]}"
  end
end

# 4. Add routes (config/routes.rb)
# post '/apple_pay_payments', to: 'apple_pay_payments#create'

# 5. Create a model for payment records (optional)
class Payment < ApplicationRecord
  # Schema:
  # t.string :card_number
  # t.string :card_expiration
  # t.string :cryptogram
  # t.integer :amount
  # t.string :payment_method
  # t.string :status
  # t.timestamps
  
  validates :card_number, :amount, :payment_method, presence: true
  
  enum status: {
    pending: 'pending',
    processing: 'processing',
    completed: 'completed',
    failed: 'failed'
  }
end

# 6. Frontend JavaScript to send Apple Pay token to your server
# <script>
#   const paymentRequest = {
#     countryCode: 'US',
#     currencyCode: 'USD',
#     supportedNetworks: ['visa', 'masterCard', 'amex'],
#     merchantCapabilities: ['supports3DS'],
#     total: {
#       label: 'Your Store Name',
#       amount: '10.00'
#     }
#   };
#
#   const session = new ApplePaySession(3, paymentRequest);
#
#   session.onpaymentauthorized = (event) => {
#     const paymentToken = event.payment.token;
#     
#     fetch('/apple_pay_payments', {
#       method: 'POST',
#       headers: {
#         'Content-Type': 'application/json',
#       },
#       body: JSON.stringify({ payment_token: paymentToken })
#     })
#     .then(response => response.json())
#     .then(data => {
#       if (data.success) {
#         session.completePayment(ApplePaySession.STATUS_SUCCESS);
#       } else {
#         session.completePayment(ApplePaySession.STATUS_FAILURE);
#       }
#     });
#   };
#
#   session.begin();
# </script>
