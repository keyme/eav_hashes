p = Product.new
p.name = "Product 1"

[
  ["a_complex","A Complex"],
  ["a_float","A Float"],
  ["a_number","A Number"],
  ["a_rational","A Rational"],
  ["a_symbol","A Symbol"],
  ["a_string","A String"],
  ["an_array","An Array"],
  ["a_hash","A Hash"],
  ["an_object","An Object"],
  ["false","False"],
  ["true","True"],
  ["symbolic_key", :symbolic_key],
  ["only_in_product_2", :only_in_product_2]
].each do |key, display|
  ProductTechSpecsKey.create(key_name: key, display_name: display)
end


p.tech_specs << {
  "a_complex"   => Complex("3.141592653589793+42i"),
  "a_float"     => 3.141592653589793,
  "a_number"    => 42,
  "a_rational"  => Rational(Math::PI),
  "a_symbol"    => :symbol,
  "a_string"    => "Strings are for cats!",
  "an_array"    => ["blue", 42, :flux_capacitor],
  "a_hash"      => {:foo => :bar},
  "an_object"   => CustomTestObject.new(42),
  "false"       => false,
  "true"        => true,
  "symbolic_key" => "This key is SYMBOLIC!!!!!1!!"
}

p2 = Product.new

p2.name = "Product 2"
(p2.tech_specs << p.tech_specs) << { :only_in_product_2 => :mustard_pimp }
(p2.tech_specs << p.tech_specs) << { "only_in_product_2" => :relish_it_all }


ProductTechSpecsKey.create(key_name: "first_name", display_name: "First Name")
ProductTechSpecsKey.create(key_name: "last_name", display_name: "Last Name")


p3 = Product.new
p3.name = "Product 3"
p3.tech_specs[:delete_me] = "set me to nil in the tests, save the model, pull it again and ensure p3.tech_specs.keys.length == 0"

p.save
p2.save
p3.save

puts "Seeded the database."
