class CreateProductTechSpecsKeyTags < ActiveRecord::Migration[5.0]
  def change
    create_table :product_tech_specs_key_tags do |t|
      t.string :name, null: false, uniqueness: true
      t.text :description

      t.timestamps
    end

    create_table :product_tech_specs_key_tags_product_tech_specs_keys, :id => false do |t|
      t.references :product_tech_specs_key_tag, null: false, index: { name: 'tag' }
      t.references :product_tech_specs_key, null: false, index: { name: 'key' }
    end

    # Adding the index can massively speed up join tables. Don't use the
    # unique if you allow duplicates.
    add_index(:product_tech_specs_key_tags_product_tech_specs_keys, [:product_tech_specs_key_tag_id, :product_tech_specs_key_id], name: "join_key_key_tag", unique: true)
  end
end
