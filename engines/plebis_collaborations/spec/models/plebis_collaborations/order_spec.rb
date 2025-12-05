# frozen_string_literal: true

require 'rails_helper'

# Note: The actual model class is Order in app/models, not PlebisCollaborations::Order
# The engine's model file defines the same Order class
RSpec.describe Order, type: :model do
  describe 'associations' do
    it 'belongs to parent' do
      order = create(:order)
      expect(order).to respond_to(:parent)
      expect(order.parent).to be_present
    end

    it 'belongs to user' do
      order = create(:order)
      expect(order).to respond_to(:user)
      expect(order.user).to be_present
    end
  end

  describe 'validations' do
    it 'validates presence of payment_type' do
      order = build(:order, payment_type: nil)
      expect(order).not_to be_valid
      expect(order.errors[:payment_type]).to be_present
    end

    it 'validates presence of amount' do
      order = build(:order, amount: nil)
      expect(order).not_to be_valid
      expect(order.errors[:amount]).to be_present
    end

    it 'validates presence of payable_at' do
      order = build(:order, payable_at: nil)
      expect(order).not_to be_valid
      expect(order.errors[:payable_at]).to be_present
    end
  end

  describe 'callbacks' do
    it 'sets initial status to 0 after initialization' do
      order = described_class.new
      expect(order.status).to eq(0)
    end
  end

  describe 'scopes' do
    before do
      @cc_order = create(:order, :credit_card, :nueva)
      @bank_order = create(:order, :iban, :nueva)
      @paid_order = create(:order, :ok)
      @charging_order = create(:order, :sin_confirmar)
      @error_order = create(:order, :error)
      @returned_order = create(:order, :devuelta)
      @warning_order = create(:order, :alerta)
      @deleted_order = create(:order, :deleted)
    end

    it '.created returns non-deleted orders' do
      expect(described_class.created).to include(@cc_order, @bank_order)
      expect(described_class.created).not_to include(@deleted_order)
    end

    it '.credit_cards returns credit card orders' do
      expect(described_class.credit_cards).to include(@cc_order)
      expect(described_class.credit_cards).not_to include(@bank_order)
    end

    it '.banks returns bank orders' do
      expect(described_class.banks).to include(@bank_order)
      expect(described_class.banks).not_to include(@cc_order)
    end

    it '.to_be_paid returns orders with status 0 or 1' do
      expect(described_class.to_be_paid).to include(@cc_order, @charging_order)
      expect(described_class.to_be_paid).not_to include(@paid_order)
    end

    it '.to_be_charged returns orders with status 0' do
      expect(described_class.to_be_charged).to include(@cc_order)
      expect(described_class.to_be_charged).not_to include(@charging_order)
    end

    it '.charging returns orders with status 1' do
      expect(described_class.charging).to include(@charging_order)
      expect(described_class.charging).not_to include(@cc_order)
    end

    it '.paid returns orders with status 2 or 3 and payed_at' do
      expect(described_class.paid).to include(@paid_order)
      expect(described_class.paid).not_to include(@cc_order)
    end

    it '.warnings returns orders with status 3' do
      expect(described_class.warnings).to include(@warning_order)
      expect(described_class.warnings).not_to include(@paid_order)
    end

    it '.errors returns orders with status 4' do
      expect(described_class.errors).to include(@error_order)
      expect(described_class.errors).not_to include(@paid_order)
    end

    it '.returned returns orders with status 5' do
      expect(described_class.returned).to include(@returned_order)
      expect(described_class.returned).not_to include(@paid_order)
    end

    describe '.by_date' do
      before do
        @jan_order = create(:order, payable_at: Date.new(2024, 1, 15))
        @feb_order = create(:order, payable_at: Date.new(2024, 2, 15))
        @mar_order = create(:order, payable_at: Date.new(2024, 3, 15))
      end

      it 'returns orders within date range' do
        orders = described_class.by_date(Date.new(2024, 1, 1), Date.new(2024, 2, 28))
        expect(orders).to include(@jan_order, @feb_order)
        expect(orders).not_to include(@mar_order)
      end
    end
  end

  describe 'status methods' do
    describe '#is_payable?' do
      it 'returns true for status 0 (nueva)' do
        order = create(:order, :nueva)
        expect(order.is_payable?).to be true
      end

      it 'returns true for status 1 (sin confirmar)' do
        order = create(:order, :sin_confirmar)
        expect(order.is_payable?).to be true
      end

      it 'returns false for status 2 (ok)' do
        order = create(:order, :ok)
        expect(order.is_payable?).to be false
      end
    end

    describe '#is_chargeable?' do
      it 'returns true for status 0' do
        order = create(:order, :nueva)
        expect(order.is_chargeable?).to be true
      end

      it 'returns false for status 1' do
        order = create(:order, :sin_confirmar)
        expect(order.is_chargeable?).to be false
      end
    end

    describe '#is_paid?' do
      it 'returns true when payed_at is set and status is 2' do
        order = create(:order, :ok)
        expect(order.is_paid?).to be true
      end

      it 'returns false when payed_at is nil' do
        order = create(:order, :nueva)
        expect(order.is_paid?).to be false
      end
    end

    describe '#has_warnings?' do
      it 'returns true for status 3' do
        order = create(:order, :alerta)
        expect(order.has_warnings?).to be true
      end

      it 'returns false for other statuses' do
        order = create(:order, :ok)
        expect(order.has_warnings?).to be false
      end
    end

    describe '#has_errors?' do
      it 'returns true for status 4' do
        order = create(:order, :error)
        expect(order.has_errors?).to be true
      end

      it 'returns false for other statuses' do
        order = create(:order, :ok)
        expect(order.has_errors?).to be false
      end
    end

    describe '#was_returned?' do
      it 'returns true for status 5' do
        order = create(:order, :devuelta)
        expect(order.was_returned?).to be true
      end

      it 'returns false for other statuses' do
        order = create(:order, :ok)
        expect(order.was_returned?).to be false
      end
    end
  end

  describe 'payment type methods' do
    describe '#is_credit_card?' do
      it 'returns true for payment_type 1' do
        order = create(:order, :credit_card)
        expect(order.is_credit_card?).to be true
      end

      it 'returns false for payment_type 3' do
        order = create(:order, :iban)
        expect(order.is_credit_card?).to be false
      end
    end

    describe '#is_bank?' do
      it 'returns true for payment_type 3' do
        order = create(:order, :iban)
        expect(order.is_bank?).to be true
      end

      it 'returns false for payment_type 1' do
        order = create(:order, :credit_card)
        expect(order.is_bank?).to be false
      end
    end

    describe '#is_bank_national?' do
      it 'returns true for Spanish IBAN' do
        order = create(:order, :iban, payment_identifier: 'ES9121000418450200051332/CAIXESBBXXX')
        expect(order.is_bank_national?).to be true
      end

      it 'returns false for international IBAN' do
        order = create(:order, :international_iban)
        expect(order.is_bank_international?).to be true
      end
    end

    describe '#has_ccc_account?' do
      it 'returns true for payment_type 2' do
        order = create(:order, :ccc)
        expect(order.has_ccc_account?).to be true
      end

      it 'returns false for payment_type 3' do
        order = create(:order, :iban)
        expect(order.has_ccc_account?).to be false
      end
    end

    describe '#has_iban_account?' do
      it 'returns true for payment_type 3' do
        order = create(:order, :iban)
        expect(order.has_iban_account?).to be true
      end

      it 'returns false for payment_type 1' do
        order = create(:order, :credit_card)
        expect(order.has_iban_account?).to be false
      end
    end
  end

  describe 'name methods' do
    describe '#status_name' do
      it 'returns status name' do
        order = create(:order, :ok)
        expect(order.status_name).to eq('OK')
      end
    end

    describe '#payment_type_name' do
      it 'returns payment type name' do
        order = create(:order, :credit_card)
        expect(order.payment_type_name).to eq('Suscripción con Tarjeta de Crédito/Débito')
      end
    end
  end

  describe 'bank payment methods' do
    describe '#due_code' do
      it 'returns FRST for first orders' do
        order = create(:order, :first_order)
        expect(order.due_code).to eq('FRST')
      end

      it 'returns RCUR for recurring orders' do
        order = create(:order, first: false)
        expect(order.due_code).to eq('RCUR')
      end
    end

    describe '#url_source' do
      it 'returns collaboration URL' do
        order = create(:order)
        expect(order.url_source).to be_present
      end
    end

    describe '#mark_as_charging' do
      it 'sets status to 1' do
        order = create(:order, :nueva)
        order.mark_as_charging
        expect(order.status).to eq(1)
      end
    end

    describe '#mark_as_paid!' do
      it 'sets status to 2 and payed_at' do
        order = create(:order, :nueva)
        date = Time.zone.now
        order.mark_as_paid!(date)
        expect(order.status).to eq(2)
        expect(order.payed_at).to eq(date)
      end

      it 'calls parent.payment_processed!' do
        order = create(:order, :nueva)
        expect(order.parent).to receive(:payment_processed!).with(order)
        order.mark_as_paid!(Time.zone.now)
      end
    end

    describe '#processed!' do
      let(:collaboration) { create(:collaboration, :active) }
      let(:order) { create(:order, :nueva, parent: collaboration, user: collaboration.user) }
      let(:mailer_double) { double('Mailer', deliver_now: true) }

      before do
        stub_const('PlebisCollaborations::CollaborationsMailer', Class.new)
        allow(PlebisCollaborations::CollaborationsMailer).to receive(:order_returned_user).and_return(mailer_double)
        allow(PlebisCollaborations::CollaborationsMailer).to receive(:order_returned_militant).and_return(mailer_double)
        allow(PlebisCollaborations::CollaborationsMailer).to receive(:collaboration_suspended_user).and_return(mailer_double)
        allow(PlebisCollaborations::CollaborationsMailer).to receive(:collaboration_suspended_militant).and_return(mailer_double)
      end

      it 'sets status to 5 (devuelta) without code' do
        result = order.processed!
        expect(result).to be true
        expect(order.reload.status).to eq(5)
      end

      it 'sets status to 4 (error) for error codes' do
        result = order.processed!('AC01')
        expect(result).to be true
        expect(order.reload.status).to eq(4)
        expect(order.payment_response).to eq('AC01')
      end

      it 'calls parent.processed_order! when parent exists' do
        expect(order.parent).to receive(:processed_order!)
        order.processed!
      end

      it 'handles SEPA error codes correctly' do
        order.processed!('AC04')
        expect(order.reload.status).to eq(4)
      end

      it 'does not call parent.processed_order! when parent is deleted' do
        order.parent.update_column(:deleted_at, Time.zone.now)
        order.reload
        expect { order.processed! }.not_to raise_error
      end
    end

    describe '#bank_text_status' do
      it 'returns error message for status 4' do
        order = create(:order, :error)
        expect(order.bank_text_status).to eq('Error')
      end

      it 'returns SEPA reason for returned orders with code' do
        order = create(:order, :devuelta, payment_response: 'AM04')
        expect(order.bank_text_status).to include('AM04')
        expect(order.bank_text_status).to include('Fondos insuficientes')
      end

      it 'returns generic message for returned orders without code' do
        order = create(:order, :devuelta, payment_response: nil)
        expect(order.bank_text_status).to eq('Orden devuelta')
      end
    end
  end

  describe 'class methods for bank orders' do
    describe '.mark_bank_orders_as_charged!' do
      before do
        @order1 = create(:order, :iban, :nueva, payable_at: Time.zone.today)
        @order2 = create(:order, :iban, :nueva, payable_at: Time.zone.today)
        @old_order = create(:order, :iban, :nueva, payable_at: 1.month.ago)
      end

      it 'updates status to 1 for current month bank orders' do
        described_class.mark_bank_orders_as_charged!(Time.zone.today)
        expect(@order1.reload.status).to eq(1)
        expect(@order2.reload.status).to eq(1)
        expect(@old_order.reload.status).to eq(0)
      end
    end

    describe '.mark_bank_orders_as_paid!' do
      before do
        @charging1 = create(:order, :iban, :sin_confirmar, payable_at: Time.zone.today)
        @charging2 = create(:order, :iban, :sin_confirmar, payable_at: Time.zone.today)
      end

      it 'updates status to 2 and sets payed_at' do
        described_class.mark_bank_orders_as_paid!(Time.zone.today)
        expect(@charging1.reload.status).to eq(2)
        expect(@charging1.payed_at).to eq(Time.zone.today.to_date)
      end
    end

    describe '.by_month_count' do
      before do
        @date = Date.new(2024, 1, 1)
        create_list(:order, 3, payable_at: @date)
        create(:order, payable_at: Date.new(2024, 2, 1))
      end

      it 'returns count of orders for month' do
        count = described_class.by_month_count(@date)
        expect(count).to eq(3)
      end
    end

    describe '.by_month_amount' do
      before do
        @date = Date.new(2024, 1, 1)
        create(:order, payable_at: @date, amount: 1000)
        create(:order, payable_at: @date, amount: 2000)
        create(:order, payable_at: Date.new(2024, 2, 1), amount: 5000)
      end

      it 'returns sum of amounts for month in euros' do
        amount = described_class.by_month_amount(@date)
        expect(amount).to eq(30.0)
      end
    end
  end

  describe 'redsys methods' do
    let(:order) { create(:order, :credit_card, :first_order, amount: 1000) }

    describe '#redsys_order_id' do
      it 'returns 12-digit padded ID for persisted orders' do
        expect(order.redsys_order_id.length).to eq(12)
        expect(order.redsys_order_id).to match(/^\d+$/)
      end

      it 'generates ID from parent for new orders' do
        new_order = build(:order, :credit_card)
        order_id = new_order.redsys_order_id
        expect(order_id).to be_present
      end
    end

    describe '#redsys_expiration' do
      it 'returns expiration date from redsys_response for first orders' do
        order.update_columns(payment_response: { 'Ds_ExpiryDate' => '2512' }.to_json, first: true)
        order.reload
        expiration = order.redsys_expiration
        expect(expiration).to be_a(DateTime)
        expect(expiration.year).to eq(2026)
        expect(expiration.month).to eq(1)
      end

      it 'returns nil when no redsys_response' do
        order.update_columns(payment_response: nil, first: true)
        order.reload
        expect(order.redsys_expiration).to be_nil
      end

      it 'returns nil for non-first orders' do
        order.update_columns(first: false, payment_response: { 'Ds_ExpiryDate' => '2512' }.to_json)
        order.reload
        expect(order.redsys_expiration).to be_nil
      end
    end

    describe '#redsys_merchant_url' do
      it 'returns callback URL for first orders' do
        url = order.redsys_merchant_url
        expect(url).to include('redsys_order_id')
      end

      it 'returns empty string for non-first orders' do
        order.first = false
        expect(order.redsys_merchant_url).to eq('')
      end
    end

    describe '#redsys_raw_params' do
      it 'includes merchant identifier for first orders' do
        params = order.redsys_raw_params
        expect(params['DS_MERCHANT_IDENTIFIER']).to be_present
      end

      it 'includes direct payment for recurring orders' do
        order.first = false
        order.payment_identifier = '123456'
        params = order.redsys_raw_params
        expect(params['DS_MERCHANT_DIRECTPAYMENT']).to eq('true')
      end

      it 'includes all required fields' do
        params = order.redsys_raw_params
        expect(params['DS_MERCHANT_AMOUNT']).to eq('1000')
        expect(params['DS_MERCHANT_ORDER']).to be_present
      end
    end

    describe '#redsys_merchant_params' do
      it 'returns base64 encoded JSON' do
        params = order.redsys_merchant_params
        expect(params).to be_present
        decoded = JSON.parse(Base64.strict_decode64(params))
        expect(decoded).to be_a(Hash)
      end
    end

    describe '#redsys_params' do
      it 'includes signature version' do
        params = order.redsys_params
        expect(params['Ds_SignatureVersion']).to eq('HMAC_SHA256_V1')
      end

      it 'includes merchant parameters' do
        params = order.redsys_params
        expect(params['Ds_MerchantParameters']).to be_present
      end

      it 'includes signature' do
        params = order.redsys_params
        expect(params['Ds_Signature']).to be_present
      end
    end

    describe '#redsys_response' do
      it 'parses payment_response as JSON' do
        order.update(payment_response: { 'Ds_Response' => '0000' }.to_json)
        response = order.redsys_response
        expect(response).to be_a(Hash)
        expect(response['Ds_Response']).to eq('0000')
      end

      it 'returns nil when payment_response is nil' do
        order.payment_response = nil
        expect(order.redsys_response).to be_nil
      end
    end

    describe '#redsys_parse_response!' do
      let(:collaboration) { create(:collaboration, :active, payment_type: 1) }
      let(:test_order) { create(:order, :credit_card, :first_order, parent: collaboration, user: collaboration.user) }
      let(:params) do
        {
          'Ds_Response' => '0000',
          'Ds_Date' => Time.zone.now.in_time_zone(described_class::REDSYS_SERVER_TIME_ZONE).strftime('%d/%m/%Y'),
          'Ds_Hour' => Time.zone.now.in_time_zone(described_class::REDSYS_SERVER_TIME_ZONE).strftime('%H:%M'),
          'Ds_Merchant_Identifier' => '999999999R'
        }
      end

      it 'sets status to 2 or 3 for successful payments' do
        test_order.redsys_parse_response!(params, '<Request></Request>')
        expect(test_order.reload.status).to be_in([2, 3])
      end

      it 'sets status to 4 for failed payments' do
        params['Ds_Response'] = '9999'
        test_order.redsys_parse_response!(params, '<Request></Request>')
        expect(test_order.reload.status).to eq(4)
      end

      it 'sets payed_at for successful payments' do
        test_order.redsys_parse_response!(params, '<Request></Request>')
        expect(test_order.reload.payed_at).to be_present
      end

      it 'calls parent.payment_processed!' do
        expect(test_order.parent).to receive(:payment_processed!).with(test_order)
        test_order.redsys_parse_response!(params, '<Request></Request>')
      end
    end

    describe '#redsys_text_status' do
      it 'returns message for successful transaction' do
        order.update(payment_response: { 'Ds_Response' => '0050' }.to_json, first: true)
        expect(order.redsys_text_status).to include('autorizada')
      end

      it 'returns message for expired card' do
        order.update(payment_response: { 'Ds_Response' => '101' }.to_json, first: true)
        expect(order.redsys_text_status).to include('101')
        expect(order.redsys_text_status).to include('caducada')
      end

      it 'returns message for insufficient funds' do
        order.update(payment_response: { 'Ds_Response' => '116' }.to_json, first: true)
        expect(order.redsys_text_status).to include('116')
        expect(order.redsys_text_status).to include('insuficiente')
      end

      it 'returns message for returned orders' do
        order.update(status: 5)
        expect(order.redsys_text_status).to eq('Orden devuelta')
      end
    end

    describe '#redsys_callback_response' do
      let(:collaboration) { create(:collaboration, :active, payment_type: 1) }
      let(:test_order) { create(:order, :credit_card, :first_order, parent: collaboration, user: collaboration.user) }

      it 'returns SOAP response with OK for paid orders' do
        test_order.update_columns(status: 2, payed_at: Time.zone.now)
        test_order.reload
        response = test_order.redsys_callback_response
        expect(response).to include('OK')
        expect(response).to include('SOAP-ENV:Envelope')
      end

      it 'returns SOAP response with KO for unpaid orders' do
        test_order.update_columns(status: 0, payed_at: nil)
        test_order.reload
        response = test_order.redsys_callback_response
        expect(response).to include('KO')
      end
    end
  end

  describe '#generate_target_territory' do
    let(:collaboration) { create(:collaboration, :active) }
    let(:order) { create(:order, parent: collaboration, user: collaboration.user) }

    it 'returns empty string when parent has no user' do
      allow(order.parent).to receive(:get_user).and_return(nil)
      expect(order.generate_target_territory).to eq('')
    end

    context 'with island code' do
      before do
        order.island_code = 'i_07'
        allow(order.parent).to receive(:get_vote_island_name).and_return('Mallorca')
      end

      it 'returns island territory' do
        territory = order.generate_target_territory
        expect(territory).to include('Isla')
        expect(territory).to include('Mallorca')
      end
    end

    context 'with town code' do
      before do
        order.town_code = 'm_28_079_6'
        allow(order.parent).to receive(:get_vote_town_name).and_return('Madrid')
      end

      it 'returns municipal territory' do
        territory = order.generate_target_territory
        expect(territory).to include('Municipal')
        expect(territory).to include('Madrid')
      end
    end

    context 'with autonomy code' do
      before do
        order.autonomy_code = 'c_01'
        allow(order.parent).to receive(:get_vote_autonomy_name).and_return('Andalucía')
      end

      it 'returns autonomic territory' do
        territory = order.generate_target_territory
        expect(territory).to include('Autonómico')
        expect(territory).to include('Andalucía')
      end
    end

    context 'without territorial codes' do
      it 'returns state territory' do
        territory = order.generate_target_territory
        expect(territory).to include('Estatal')
      end
    end
  end

  describe '#error_message' do
    it 'returns redsys_text_status for credit cards' do
      order = create(:order, :credit_card)
      expect(order.error_message).to eq(order.redsys_text_status)
    end

    it 'returns bank_text_status for bank payments' do
      order = create(:order, :iban)
      expect(order.error_message).to eq(order.bank_text_status)
    end
  end

  describe '.parent_from_order_id' do
    it 'extracts parent from order ID' do
      collaboration = create(:collaboration, :active)
      order_id = "#{collaboration.id.to_s.rjust(7, '0')}Ctest"
      parent = described_class.parent_from_order_id(order_id)
      expect(parent).to eq(collaboration)
    end
  end

  describe '.payment_day' do
    it 'returns payment day from secrets' do
      allow(Rails.application).to receive(:secrets).and_return(
        double(orders: { 'payment_day' => 15 })
      )
      day = described_class.payment_day
      expect(day).to eq(15)
    end
  end

  describe 'constants' do
    it 'has STATUS constant' do
      expect(described_class::STATUS).to be_a(Hash)
      expect(described_class::STATUS['OK']).to eq(2)
      expect(described_class::STATUS['Nueva']).to eq(0)
    end

    it 'has PAYMENT_TYPES constant' do
      expect(described_class::PAYMENT_TYPES).to be_a(Hash)
      expect(described_class::PAYMENT_TYPES['Suscripción con Tarjeta de Crédito/Débito']).to eq(1)
    end

    it 'has PARENT_CLASSES constant' do
      expect(described_class::PARENT_CLASSES).to be_a(Hash)
      expect(described_class::PARENT_CLASSES[Collaboration]).to eq('C')
    end

    it 'has SEPA_RETURNED_REASONS constant' do
      expect(described_class::SEPA_RETURNED_REASONS).to be_a(Hash)
      expect(described_class::SEPA_RETURNED_REASONS['AC01']).to be_a(Hash)
      expect(described_class::SEPA_RETURNED_REASONS['AC01'][:text]).to be_present
    end
  end

  describe 'SEPA error codes' do
    describe 'error classification' do
      it 'marks AC01 as error and warning' do
        reason = described_class::SEPA_RETURNED_REASONS['AC01']
        expect(reason[:error]).to be true
        expect(reason[:warn]).to be true
      end

      it 'marks AC04 as error only' do
        reason = described_class::SEPA_RETURNED_REASONS['AC04']
        expect(reason[:error]).to be true
        expect(reason[:warn]).to be_falsey
      end

      it 'marks AM04 as non-error' do
        reason = described_class::SEPA_RETURNED_REASONS['AM04']
        expect(reason[:error]).to be false
      end

      it 'marks MD06 as non-error' do
        reason = described_class::SEPA_RETURNED_REASONS['MD06']
        expect(reason[:error]).to be false
      end
    end

    it 'has text descriptions for all codes' do
      described_class::SEPA_RETURNED_REASONS.each do |code, reason|
        expect(reason[:text]).to be_present, "Missing text for code #{code}"
      end
    end
  end

  describe 'integration tests' do
    let(:mailer_double) { double('Mailer', deliver_now: true) }

    before do
      stub_const('PlebisCollaborations::CollaborationsMailer', Class.new)
      allow(PlebisCollaborations::CollaborationsMailer).to receive(:order_returned_user).and_return(mailer_double)
      allow(PlebisCollaborations::CollaborationsMailer).to receive(:order_returned_militant).and_return(mailer_double)
      allow(PlebisCollaborations::CollaborationsMailer).to receive(:collaboration_suspended_user).and_return(mailer_double)
      allow(PlebisCollaborations::CollaborationsMailer).to receive(:collaboration_suspended_militant).and_return(mailer_double)
    end

    describe 'order lifecycle for credit cards' do
      let(:collaboration) { create(:collaboration, :active, payment_type: 1) }
      let(:order) { create(:order, :credit_card, :first_order, parent: collaboration, user: collaboration.user) }

      it 'processes successful payment flow' do
        # Start as nueva
        expect(order.status).to eq(0)
        expect(order.is_chargeable?).to be true

        # Mark as charging
        order.mark_as_charging
        expect(order.status).to eq(1)

        # Process successful payment
        params = {
          'Ds_Response' => '0000',
          'Ds_Date' => Time.zone.now.in_time_zone(described_class::REDSYS_SERVER_TIME_ZONE).strftime('%d/%m/%Y'),
          'Ds_Hour' => Time.zone.now.in_time_zone(described_class::REDSYS_SERVER_TIME_ZONE).strftime('%H:%M'),
          'Ds_Merchant_Identifier' => '999999999R'
        }
        order.redsys_parse_response!(params, '<Request></Request>')

        expect(order.reload.is_paid?).to be true
        expect(order.payed_at).to be_present
      end

      it 'processes failed payment flow' do
        params = {
          'Ds_Response' => '9999',
          'Ds_Date' => Time.zone.now.in_time_zone(described_class::REDSYS_SERVER_TIME_ZONE).strftime('%d/%m/%Y'),
          'Ds_Hour' => Time.zone.now.in_time_zone(described_class::REDSYS_SERVER_TIME_ZONE).strftime('%H:%M')
        }
        order.redsys_parse_response!(params, '<Request></Request>')

        expect(order.reload.status).to eq(4)
        expect(order.has_errors?).to be true
      end
    end

    describe 'order lifecycle for bank payments' do
      let(:collaboration) { create(:collaboration, :active, payment_type: 3) }
      let(:order) { create(:order, :iban, parent: collaboration, user: collaboration.user, payable_at: Time.zone.today) }

      it 'processes successful payment flow' do
        # Start as nueva
        expect(order.status).to eq(0)

        # Mark all orders as charged
        described_class.mark_bank_orders_as_charged!(Time.zone.today)
        expect(order.reload.status).to eq(1)

        # Mark all orders as paid
        described_class.mark_bank_orders_as_paid!(Time.zone.today)
        expect(order.reload.status).to eq(2)
        expect(order.payed_at).to be_present
      end

      it 'processes returned payment flow' do
        order.update_columns(status: 1)
        order.reload
        result = order.processed!('AM04')

        expect(result).to be true
        expect(order.reload.status).to eq(5)
        expect(order.was_returned?).to be true
        expect(order.payment_response).to eq('AM04')
      end
    end
  end

  describe 'additional methods for coverage' do
    let(:order) { create(:order, :nueva) }

    describe '#is_bank_international?' do
      it 'returns true for international IBAN starting payment_identifier' do
        order.update_columns(payment_type: 3, payment_identifier: 'DE89370400440532013000/BIC')
        order.reload
        expect(order.is_bank_international?).to be true
      end

      it 'returns false for Spanish IBAN' do
        order.update_columns(payment_type: 3, payment_identifier: 'ES9121000418450200051332/BIC')
        order.reload
        expect(order.is_bank_international?).to be false
      end
    end

    describe '#redsys_merchant_request_signature' do
      let(:cc_order) { create(:order, :credit_card, :first_order) }

      it 'generates signature for request' do
        signature = cc_order.redsys_merchant_request_signature
        expect(signature).to be_present
        expect(signature).to be_a(String)
      end
    end

    describe '#redsys_secret' do
      let(:cc_order) { create(:order, :credit_card) }

      it 'retrieves secret from Rails secrets' do
        allow(Rails.application).to receive(:secrets).and_return(
          double(redsys: { 'post_url' => 'https://test.com' })
        )
        expect(cc_order.send(:redsys_secret, 'post_url')).to eq('https://test.com')
      end
    end

    describe '#redsys_post_url' do
      let(:cc_order) { create(:order, :credit_card) }

      it 'returns redsys post URL' do
        allow(Rails.application).to receive(:secrets).and_return(
          double(redsys: { 'post_url' => 'https://test.redsys.es/sis/realizarPago' })
        )
        expect(cc_order.redsys_post_url).to be_present
      end
    end

    describe '#admin_permalink' do
      it 'returns admin order path' do
        expect(order.admin_permalink).to be_present
        expect(order.admin_permalink).to include(order.id.to_s)
      end
    end

    describe '#url_source' do
      it 'returns new collaboration URL' do
        expect(order.url_source).to be_present
      end
    end
  end
end
