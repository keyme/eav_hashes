class CreateProductTechSpecsKeys < ActiveRecord::Migration[5.0]
	
	def change
		create_table :product_tech_specs_keys do |t|
			t.string :key_name, null: false
			t.string :display_name
			t.string :original_name
			t.text :description
			t.boolean :enabled

			t.timestamps
		end

		add_index :product_tech_specs_keys, :key_name
	end
end
