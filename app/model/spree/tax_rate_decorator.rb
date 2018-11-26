require_dependency 'spree/calculator'

Spree::TaxRate.class_eval do
  include Spree::VatPriceCalculation
  has_many :taxable_zipcodes, dependent: :destroy

  def self.import(file)
    zone = Spree::Zone.find_by(name: 'North America')
    country = Spree::Country.find_by(iso: 'US')
    tax_category = Spree::TaxCategory.find_by(name: 'Tax')
    unless tax_category
      tax_category = Spree::TaxCategory.create(name: 'Tax', is_default: true)
    end

    CSV.foreach(file.path, headers: true) do |row|
      state_name = row['State']
      zipcode = row['ZipCode']
      tax_rate_amount = row['EstimatedCombinedRate']
      state = Spree::State.find_by(abbr: state_name, country_id: country.id)
      next unless state.present?

      tax_rate = Spree::TaxRate.where(name: state_name).first
      unless tax_rate.present?
        tax_rate = Spree::TaxRate.create(name: state_name, tax_category_id: tax_category.id, zone_id: zone.id, amount: 0.00,
                             calculator_type: "Spree::Calculator::DefaultTax")
      end

      zip_code = tax_rate.taxable_zipcodes.find_or_initialize_by(zipcode: zipcode)
      zip_code.amount = tax_rate_amount
      zip_code.region_name = row['TaxRegionName']
      zip_code.save
    end
  end
end