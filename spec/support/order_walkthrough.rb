class OrderWalkthrough
  def self.up_to(state)
    # A default store must exist to provide store settings
    FactoryBot.create(:store) unless Spree::Store.exists?

    # A payment method must exist for an order to proceed through the Address state
    unless Spree::PaymentMethod.exists?
      FactoryBot.create(:check_payment_method)
    end

    # Need to create a valid zone too...
    zone = FactoryBot.create(:zone)
    country = FactoryBot.create(:country)
    zone.members << Spree::ZoneMember.create(zoneable: country)
    country.states << FactoryBot.create(:state, country: country)

    # Default stock location for non supplier products
    FactoryBot.create(:stock_location, default: true, backorderable_default: true)
    # A shipping method must exist for rates to be displayed on checkout page
    unless Spree::ShippingMethod.exists?
      FactoryBot.create(:shipping_method).tap do |sm|
        sm.calculator.preferred_amount = 0
        sm.calculator.preferred_currency = Spree::Config[:currency]
        sm.calculator.save
      end
    end

    user =  FactoryBot.create(:user_with_addresses)
    user.ship_address.update_attributes(state_id: 1, zipcode: '84001')
    order = Spree::Order.create!(email: 'spree@example.com')
    add_line_item!(order)
    order.associate_user!(user)
    order.next!

    end_state_position = states.index(state.to_sym)
    states[0...end_state_position].each do |state|
      send(state, order)
    end

    order
  end

  private

  def self.add_line_item!(order)
    FactoryBot.create(:line_item, order: order)
    order.reload
  end

  def self.delivery(order)
    order.next!
  end

  def self.complete(_order)
    # noop?
  end

  def self.states
    [:delivery, :complete]
  end
end