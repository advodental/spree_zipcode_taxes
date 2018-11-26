class Spree::Admin::TaxableZipcodesController < Spree::Admin::BaseController
  before_action :set_tax_rate, only: %i[index]

  private

  def set_tax_rate
    @tax_rate = Spree::TaxRate.find(params[:tax_rate_id])
  end
end