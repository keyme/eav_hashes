class CreateProductTechSpecsKeys < ActiveRecord::Migration[5.0]
	
	def change
		create_table :product_tech_specs_keys do |t|
			t.string :key_name
			t.string :display_name
			t.string :original_name
			t.text :description
			t.boolean :enabled

			t.timestamps
		end
	end
end
