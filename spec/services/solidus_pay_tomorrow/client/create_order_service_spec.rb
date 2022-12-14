# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPayTomorrow::Client::CreateOrderService do
  let(:order) { create(:order_with_line_items, line_items_count: 2) }
  let(:payment_method) { create(:pt_payment_method) }
  let(:success_response) do
    { url: "https://subdomain.paytomorrow.com/verify/personal?app=11171280-8e2a-4b2e-8855-76285fc578c6&auth=e3de6c12-ed9a-4bb1-a066-5c62a1ba19d4",
      token: "11171280-8e2a-4b2e-8855-76285fc578c6" }.stringify_keys!
  end
  let(:http_response) { instance_double(HTTParty::Response, parsed_response: success_response, success?: true) }
  let(:full_name) { Spree::Address::Name.new(order.bill_address.name) }

  before do
    url = 'https://api-staging.paytomorrow.com/api/application/ecommerce/orders'
    headers = { 'Authorization': "Bearer access-token",
                'Content-Type': 'application/json' }
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(SolidusPayTomorrow::Client::BaseService).to receive(:valid_token).and_return('access-token')
    # rubocop:enable RSpec/AnyInstance
    allow(HTTParty).to receive(:post).with(url, headers: headers, body: expected_body).and_return(http_response)
  end

  describe '#call' do
    it 'creates successful order' do
      response = described_class.call(order: order, payment_method: payment_method)
      expect(response).to match(hash_including('url', 'token'))
    end

    def expected_body
      line_item1 = order.line_items.first
      line_item2 = order.line_items.last
      { orderId: order.number,
        firstName: full_name.first_name,
        lastName: full_name.last_name,
        street: order.ship_address.address1,
        city: order.ship_address.city,
        zip: order.ship_address.zipcode,
        state: order.ship_address.state.abbr,
        email: order.email,
        returnUrl: webhook_url('return'),
        cancelUrl: webhook_url('cancel'),
        notifyUrl: "#{SolidusPayTomorrow.config.base_url}/pay_tomorrow/notify",
        cellPhone: order.ship_address.phone,
        loanAmount: order.total,
        taxes: order.tax_total,
        shipping: order.shipment_total,
        applicationItems:
          [{ description: line_item1.name, quantity: line_item1.quantity,
             price: line_item1.total, sku: line_item1.sku },
           { description: line_item2.name, quantity: line_item2.quantity,
             price: line_item2.total, sku: line_item2.sku }] }.to_json
    end

    def webhook_url(type)
      "#{SolidusPayTomorrow.config.base_url}#{spree.public_send("pay_tomorrow_#{type}_path")}"
    end
  end
end
