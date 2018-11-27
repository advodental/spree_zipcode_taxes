require_dependency 'spree/calculator'

module Spree
  class Calculator::ZipCodeTax < Calculator
    include VatPriceCalculation
    def self.description
      Spree.t(:zipcode_tax)
    end

    # When it comes to computing shipments or line items: same same.
    def compute_shipment_or_line_item(item)
      applied_tax = Spree::TaxableZipcode.find_by(id: item.order.tax_zipcode)
      if rate.included_in_price
        deduced_total_by_rate(item.pre_tax_amount, applied_tax)
      else
        round_to_two_places(item.discounted_amount * applied_tax.amount)
      end
    end

    alias compute_line_item compute_shipment_or_line_item

    private

    def rate
      calculable
    end

    def deduced_total_by_rate(pre_tax_amount, applied_tax)
      round_to_two_places(pre_tax_amount * applied_tax.amount)
    end
  end
end
