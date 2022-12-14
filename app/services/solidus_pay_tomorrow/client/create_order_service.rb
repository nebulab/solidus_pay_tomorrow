# frozen_string_literal: true

module SolidusPayTomorrow
  module Client
    class CreateOrderService < SolidusPayTomorrow::Client::BaseService
      attr_reader :order

      CREATE_ENDPOINT = 'api/application/ecommerce/orders'

      # @param order [Spree::Order] Spree order
      # @param payment_method [SolidusPayTomorrow::PaymentMethod]
      def initialize(order:, payment_method:)
        @order = order
        super
      end

      def call
        create
      end

      private

      def create
        handle_errors!(HTTParty.post(uri, headers: auth_headers, body: create_body.to_json))
      end

      def uri
        "#{api_base_url}/#{CREATE_ENDPOINT}"
      end

      def webhook_url(type)
        "#{SolidusPayTomorrow.config.base_url}/pay_tomorrow/#{type}"
      end

      def create_body
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
          notifyUrl: webhook_url('notify'),
          cellPhone: order.ship_address.phone,
          loanAmount: order.total,
          taxes: order.tax_total,
          shipping: order.shipment_total,
          applicationItems: items }
      end

      def full_name
        Spree::Address::Name.new(order.ship_address.name)
      end

      # Ref: https://docs.paytomorrow.com/docs/api-reference/api/create-order/
      # for API ref
      def items
        order.line_items.map do |line_item|
          { description: line_item.name,
            quantity: line_item.quantity,
            price: line_item.total,
            sku: line_item.sku }
        end
      end
    end
  end
end
