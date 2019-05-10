require 'spec_helper'

describe "Key Classes" do
  it "converts keys to symbols" do
    key_name = "KeyName"
    key = ProductTechSpecsKey.create(key_name: key_name, display_name: key_name)
    expect(key.key_name.is_a?(Symbol)).to be_truthy
  end
  
  it "properly formats the key" do
      key_name = "KeyMe/Test Card"
      key = ProductTechSpecsKey.create(key_name: key_name, display_name: key_name)
      expect(key.key_name).to eq(:key_me_test_card)
  end
  
  it "preserves the original format of the key" do
      key_name = "Key/Name"
      key = ProductTechSpecsKey.create(key_name: key_name, display_name: key_name)
      expect(key.original_name).to eq(key_name)
  end
end

describe "EavHash/EavEntry" do
    # p[1-3] are defined in spec/dummy/db/seeds.rb and are used as fixtures
    let (:p1) { Product.find_by_name("Product 1") }
    let (:p2) { Product.find_by_name("Product 2") }
    let (:p3) { Product.find_by_name("Product 3") }
    
    let (:key1) { ProductTechSpecsKey.find_by_key_name("first_name") }
    let (:key2) { ProductTechSpecsKey.find_by_key_name("last_name") }

    it "deletes an EAV row when its value is set to nil" do
        p3_id = p3.id
        p3.tech_specs[:delete_me] = nil
        p3.save!

        p3_pulled = Product.find_by_id(p3_id)
#        p3_pulled.tech_specs.keys.length.should == 0
        expect(p3_pulled.tech_specs.keys.length).to eq(0)

    end
    
    it 'test' do
      puts "Count: #{ProductTechSpecsEntry.count}"
      p4 = Product.create(name: "TestProduct")
      puts "p4: #{p4.inspect}"
      p4.tech_specs << {a_string: "Blah"}
      p4.save
      puts "Count: #{ProductTechSpecsEntry.count}"
p4.reload
      puts "last --------"
      puts ProductTechSpecsEntry.last.inspect
      puts p4.inspect
      puts "getting them now"
      p4.tech_specs
      puts "last --------"
      p4.tech_specs

    end
    
    it "ensures that keys are already defined" do
      p4 = Product.create(name: "Tester")
      p4.tech_specs << { first_name: "Kermit", last_name: "Frog" }
      p4.save
      expect { p4.tech_specs << { middle_name: "D" } }.
        to raise_error("Keys must already have been defined. Missing Keys: [:middle_name]")
    end

    it "keeps track of version changes" do
      p4 = Product.new(name: "Tester")
      
      p4.tech_specs << {first_name: "Jon", last_name: "Snow"}
      
      p4.save!
      
      pt4 = ProductTechSpecsEntry.last

      p4.tech_specs << {last_name: "Stark"}
      p4.save!
      expect(pt4.versions.count).to eq(2)
    end

    it "is able to search for all models whose hashes contain a specified key" do
#        Product.find_by_tech_specs("A String").length.should be == 2
        expect(Product.find_by_tech_specs("A String").length).to eq(2)
#        Product.find_by_tech_specs(:only_in_product_2).length.should be == 1
        expect(Product.find_by_tech_specs(:only_in_product_2).length).to eq(1)
    end

    describe "distinguishes between string and symbol keys" do
        it "finds a value for symbol key \":symbolic_key\" in Product 1" do
#            p1.tech_specs[:symbolic_key].should_not be_nil
            expect(p1.tech_specs[:symbolic_key]).not_to be_nil
        end

#         it "does not find a value for non-symbol key \"symbolic_key\" in Product 1" do
# #            p1.tech_specs["symbolic_key"].should be_nil
#             expect(p1.tech_specs["symbolic_key"]).to be_nil
#         end
    end

    describe "preserves types between serialization and deserialization" do
        it "preserves String value types" do
#            p1.tech_specs["A String"].should be_a_kind_of String
            expect(p1.tech_specs["A String"]).to be_a_kind_of String
        end

        it "preserves Symbol value types" do
#            p1.tech_specs["A Symbol"].should be_a_kind_of Symbol
            expect(p1.tech_specs["A Symbol"]).to be_a_kind_of Symbol
        end
    
        it "preserves Integer/Bignum/Fixnum value types" do
#            p1.tech_specs["A_Number"].should be_a_kind_of Integer
            expect(p1.tech_specs["A_Number"]).to be_a_kind_of Integer
        end

        it "preserves Symbol value types" do
            expect(p1.tech_specs["A_Float"]).to be_a_kind_of Float
        end

        it "preserves Complex value types" do
            expect(p1.tech_specs["A_Complex"]).to be_a_kind_of Complex
        end

        it "preserves Rational value types" do
            expect(p1.tech_specs["A_Rational"]).to be_a_kind_of Rational
        end

        it "preserves Boolean(true) value types" do
            expect(p1.tech_specs["True"]).to be_a_kind_of TrueClass
        end

        it "preserves Boolean(false) value types" do
            expect(p1.tech_specs["False"]).to be_a_kind_of FalseClass
        end

        it "preserves Array value types" do
            expect(p1.tech_specs["An_Array"]).to be_a_kind_of Array
        end

        it "preserves Hash value types" do
            expect(p1.tech_specs["A_Hash"]).to be_a_kind_of Hash
        end

        it "preserves user-defined value types" do
            expect(p1.tech_specs["An_Object"]).to be_a_kind_of CustomTestObject
        end
    end

    describe "preserves values between serialization and deserialization" do
        it "preserves String values" do
            expect(p1.tech_specs["A_String"]).to eq("Strings are for cats!")
        end

        it "preserves Symbols" do
            expect(p1.tech_specs["A_Symbol"]).to eq(:symbol)
        end

        it "preserves Integer/Bignum/Fixnum value types" do
            expect(p1.tech_specs["A_Number"]).to eq(42)
        end

        it "preserves Symbol values" do
            expect(p1.tech_specs["A_Float"]).to eq(3.141592653589793)
        end

        it "preserves Complex values" do
            expect(p1.tech_specs["A_Complex"]).to eq(Complex("3.141592653589793+42i"))
        end

        it "preserves Rational values" do
            expect(p1.tech_specs["A_Rational"]).to eq(Rational(Math::PI))
        end

        it "preserves Boolean(true) values" do
            expect(p1.tech_specs["True"]).to eq(true)
        end

        it "preserves Boolean(false) values" do
            expect(p1.tech_specs["False"]).to eq(false)
        end

        it "preserves Array values" do
            expect(p1.tech_specs["An_Array"]).to eq(["blue", 42, :flux_capacitor])
        end

        it "preserves Hash values" do
            expect(p1.tech_specs["A_Hash"]).to eq({:foo => :bar})
        end

        it "preserves user-defined values" do
            expect(p1.tech_specs["An_Object"].test_value).to eq(42)
        end
    end

    describe "cannot search by arrays, hashes, and objects" do
        it "raises an error when searched by an object" do
            expect(lambda { Product.find_by_tech_specs("An_Object", CustomTestObject.new(42)) }).to raise_error()
        end

        it "raises an error when searched by a hash" do
            expect(lambda { Product.find_by_tech_specs("A Hash", {:foo => :bar}) }).to raise_error()
        end

        it "raises an error when searched by an array" do
            expect(lambda { Product.find_by_tech_specs("An_Array", ["blue", 42, :flux_capacitor]) }).to raise_error()
        end
    end

    describe "enumerable" do
        it "each gives an enumerator" do
            expect(p1.tech_specs.each).to be_instance_of(Enumerator)
        end
    end
end
