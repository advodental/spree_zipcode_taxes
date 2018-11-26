Deface::Override.new(
  virtual_path:  'spree/admin/tax_rates/index',
  name:          'add_import_button_in_admin_tax_rates_page',
  insert_bottom:  '[class="table"]',
  partial: "spree/admin/shared/import_tax_rates")