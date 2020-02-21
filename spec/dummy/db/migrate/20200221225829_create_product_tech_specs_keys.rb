class CreateProductTechSpecsKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :product_tech_specs_keys do |t|
      t.string :config_key, null: false, uniqueness: true
      t.string :display_name, null: false
      t.string :config_name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :enabled, null: false, default: true
      t.boolean :visible, null: false, default: false

      t.timestamps
    end
    add_index :product_tech_specs_keys, :config_key, unique: true
    add_index :product_tech_specs_keys, :slug, unique: true
  end
end
