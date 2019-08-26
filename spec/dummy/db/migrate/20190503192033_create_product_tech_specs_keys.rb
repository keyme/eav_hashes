class CreateProductTechSpecsKeys < ActiveRecord::Migration[5.0]

	def change
		create_table :product_tech_specs_keys do |t|
			t.string :config_key, null: false
			t.string :display_name
			t.string :config_name
			t.text :description
			t.boolean :enabled
			t.boolean :visible

			t.timestamps
		end

		add_index :product_tech_specs_keys, :config_key
	end
end
