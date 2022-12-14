require 'spec_helper'

RSpec.describe SolidusPayTomorrow::PaymentMethod, type: :model do
  describe '#gateway_class' do
    it 'has correct gateway class' do
      expect(described_class.new.gateway_class).to eq SolidusPayTomorrow::Gateway
    end
  end

  describe '#payment_source_class' do
    it 'has correct payment_source class' do
      expect(described_class.new.payment_source_class).to eq SolidusPayTomorrow::PaymentSource
    end
  end

  describe '#partial_name' do
    it 'has correct partial name' do
      expect(described_class.new.partial_name).to eq 'pay_tomorrow'
    end
  end
end
