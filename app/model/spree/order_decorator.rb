module Spree::OrderDecorator
  def tax_zipcode
    @tax_zipcode ||= tax_address&.zipcode
  end
end

Spree::Order.prepend Spree::OrderDecorator
