p = Product.new
p.name = "Product 1"

[
  ["test/key","Test Key"],
  ["first_name","First Name"],
  ["last_name","Last Name"],
  ["a_complex","A Complex"],
  ["a_float","A Float"],
  ["a_number","A Number"],
  ["a_rational","A Rational"],
  ["a_symbol","A Symbol"],
  ["a_string","A String"],
  ["an_array","An Array"],
  ["a_hash","A Hash"],
  ["an_object","An Object"],
  ["delete_me","Delete Me"],
  ["false","False"],
  ["true","True"],
  ["symbolic_key", :symbolic_key],
  ["only_in_product_2", :only_in_product_2]
].each do |key, display|
  ProductTechSpecsKey.create(config_key: key, display_name: display)
end

p.tech_specs << {
  "A Complex"   => Complex("3.141592653589793+42i"),
  "A Float"     => 3.141592653589793,
  "A Number"    => 42,
  "A Rational"  => Rational(Math::PI),
  "A Symbol"    => :symbol,
  "A String"    => "Strings are for cats!",
  "An Array"    => ["blue", 42, :flux_capacitor],
  "A Hash"      => {:foo => :bar},
  "An Object"   => CustomTestObject.new(42),
  "False"       => false,
  "True"        => true,
  :symbolic_key => "This key is SYMBOLIC!!!!!1!!"
}

p2 = Product.new

p2.name = "Product 2"
(p2.tech_specs << p.tech_specs) << { :only_in_product_2 => :mustard_pimp }
(p2.tech_specs << p.tech_specs) << { :only_in_product_2 => :two_by_two }

p3 = Product.new
p3.name = "Product 3"
p3.tech_specs[:delete_me] = "set me to nil in the tests, save the model, pull it again and ensure p3.tech_specs.keys.length == 0"

p.save
p2.save
p3.save

puts "Seeded the database."
