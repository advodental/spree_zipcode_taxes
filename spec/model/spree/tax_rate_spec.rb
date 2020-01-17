# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::TaxRate do
  let(:country) { create(:country, iso: 'US') }
  let(:zone) { create(:zone, name: 'North America') }
  let(:state) { create(:state, abbr: 'UT') }
  let(:state1) { create(:state, abbr: 'CA') }
  before do
    zone.countries << country
    country.states << state
    country.states << state1
  end

  context '#import tax rates' do
    it 'should import tax rates from csv' do
      sample_csv = File.open('././example/tax_rate_zipcodes.csv', 'r')
      Spree::TaxRateDecorator.import(sample_csv)

      expect(Spree::TaxRate.count).to eq(2)
      expect(Spree::TaxableZipcode.count).to eq(4)
    end
  end

  it 'should have all correct configurations' do
    expect(Spree::ZipcodeTax.config[:tax_category_name]).to eq('Tax')
    expect(Spree::ZipcodeTax.config[:zone_name]).to eq('North America')
    expect(Spree::ZipcodeTax.config[:country_iso_name]).to eq('US')
  end

  it 'should apply tax on order based on zip code' do
    sample_csv = File.open('././example/tax_rate_zipcodes.csv', 'r')
    Spree::TaxRateDecorator.import(sample_csv)
    order = OrderWalkthrough.up_to(:complete)

    expect(order.all_adjustments.first.label).to eq('UT 6.2%')
    expect(order.all_adjustments.first.amount.to_f).to eq(1.24)
  end
end