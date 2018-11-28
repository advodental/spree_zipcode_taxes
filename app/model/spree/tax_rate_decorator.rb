require_dependency 'spree/calculator'

Spree::TaxRate.class_eval do
  include Spree::VatPriceCalculation
  has_many :taxable_zipcodes, dependent: :destroy

  def self.import(file)
    zone = Spree::Zone.find_by(name: Spree::ZipcodeTax.config[:zone_name])
    country = Spree::Country.find_by(iso: Spree::ZipcodeTax.config[:country_iso_name])
    tax_category = Spree::TaxCategory.find_by(name: Spree::ZipcodeTax.config[:tax_category_name])
    unless tax_category
      tax_category = Spree::TaxCategory.create(name: Spree::ZipcodeTax.config[:tax_category_name], is_default: true)
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
                             calculator_type: "Spree::Calculator::ZipCodeTax")
      end

      zip_code = tax_rate.taxable_zipcodes.find_or_initialize_by(zipcode: zipcode)
      zip_code.amount = tax_rate_amount
      zip_code.region_name = row['TaxRegionName']
      zip_code.save
    end
  end

  # Deletes all tax adjustments, then applies all applicable rates
  # to relevant items.
  def self.adjust(order, items)
    rates = match(order.tax_zone)
    rates = rates.select('spree_tax_rates.*, spree_taxable_zipcodes.amount AS applied_tax_amount, spree_taxable_zipcodes.id AS applied_tax_id')
                 .joins(:taxable_zipcodes).where('spree_taxable_zipcodes.zipcode = ?', order.tax_zipcode) if rates.present?

    tax_categories = rates.map(&:tax_category)

    # using destroy_all to ensure adjustment destroy callback fires.
    Spree::Adjustment.where(adjustable: items).tax.destroy_all

    relevant_items = items.select do |item|
      tax_categories.include?(item.tax_category)
    end

    relevant_items.each do |item|
      relevant_rates = rates.select do |rate|
        rate.tax_category == item.tax_category
      end
      store_pre_tax_amount(item, relevant_rates)
      relevant_rates.each do |rate|
        rate.adjust(order, item)
      end
    end

    # updates pre_tax for items without any tax rates
    remaining_items = items - relevant_items
    remaining_items.each do |item|
      store_pre_tax_amount(item, [])
    end
  end

  private

  def amount_for_label
    return '' unless show_rate_in_label?
    ' ' + ActiveSupport::NumberHelper::NumberToPercentageConverter.convert(
      applied_tax_amount * 100,
      locale: I18n.locale
    )
  end
end