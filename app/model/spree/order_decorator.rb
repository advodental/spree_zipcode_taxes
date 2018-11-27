Spree::Order.class_eval do
  def tax_zipcode
    @tax_zipcode ||= tax_address&.zipcode
  end
end
