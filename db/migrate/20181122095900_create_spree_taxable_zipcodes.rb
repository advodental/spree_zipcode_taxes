class CreateSpreeTaxableZipcodes < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_taxable_zipcodes do |t|
      t.references :tax_rate
      t.decimal :amount
      t.string  :zipcode
      t.string  :region_name

      t.timestamps
    end
  end
end
