# frozen_string_literal: true

module SolidusPayTomorrow
  class OrderApplicationController < Spree::StoreController
    def success
      SolidusPayTomorrow::Handlers::SuccessHandler.call(current_order, payment)

      flash[:notice] = 'PayTomorrow Application Successful!'
      redirect_to checkout_state_path('confirm')
    end

    def cancel
      payment.update!(state: :invalid)

      flash[:error] = "PayTomorrow Application failed!"
      redirect_to checkout_state_path('payment')
    end

    private

    # There's only one payment in checkout state for a given source type
    def payment
      current_order.payments.where(state: :checkout,
        source_type: 'SolidusPayTomorrow::PaymentSource').take
    end
  end
end
