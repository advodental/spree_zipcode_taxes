class Spree::TaxableZipcode < ApplicationRecord
  belongs_to :tax_rate
end