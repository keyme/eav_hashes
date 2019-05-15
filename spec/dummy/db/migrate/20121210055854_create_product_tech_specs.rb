class CreateProductTechSpecs < ActiveRecord::Migration[5.0]
  def change
    create_table :product_tech_specs do |t|
      t.references :product, null: false
      t.references :product_tech_specs_key, :null => false
      t.text :value, null: false
      t.integer :value_type, null: false

      t.timestamps
    end
  end
end
