Deface::Override.new(:virtual_path => "spree/admin/tax_rates/index",
                    :name => "add_zipcodes_button_to_admin_tax_rates_listing",
                    :insert_bottom => "[data-hook='rate_row']",
                    :text => "<td><%= link_to('ZipCodes', admin_tax_rate_taxable_zipcodes_path(tax_rate_id: tax_rate.id), class: 'btn btn-primary btn-sm') if can?(:edit, tax_rate) %></td>")