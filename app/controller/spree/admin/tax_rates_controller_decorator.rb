Spree::Admin::TaxRatesController.class_eval do
  def import_tax_rates
    file = params[:tax_rates_file]
    Spree::TaxRate.import(file)
    redirect_to admin_tax_rates_path
  end
end