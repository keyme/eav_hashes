module ActiveRecord
  module EavHashes
    module Util
      # Sanity checks!
      # @param [Hash] options the options hash to check for emptyness and Hashiness
      def self.sanity_check(options)
        raise "options cannot be empty (and you shouldn't be calling this since you left options blank)" if
            (!options.is_a? Hash) or options.empty?
      end

      # Fills in any options not explicitly passed to eav_hash_for and creates an EavEntry type for the table
      # @param [Hash] options the options hash to be filled with defaults on unset keys.
      def self.fill_options_hash(options)
        sanity_check options

        # Generate a unique class name based on the eav_hash's name and owner
        options[:entry_class_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name]}_entry".camelize.to_sym
        options[:key_class_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name].to_s}_key".camelize.to_sym
        options[:key_tag_class_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name].to_s}_key_tag".camelize.to_sym
        options[:paper_trail_abstract_class] ||= "PaperTrail::Version".camelize.to_sym
        options[:version_class_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name]}_version".camelize.to_sym

        options[:key_table_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name].to_s}_key".tableize.to_sym
        options[:key_tag_table_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name].to_s}_key_tag".tableize.to_sym

        # Strip "_entries" from the table name
        if /Entry$/.match options[:entry_class_name]
          options[:table_name] ||= options[:entry_class_name].to_s.tableize.slice(0..-9).to_sym
        else
          options[:table_name] ||= options[:entry_class_name].to_s.tableize.to_sym
        end

        options[:version_table_name] ||= "#{options[:table_name]}_versions"

        # Create the symbol name for the "belongs_to" association in the entry model
        options[:parent_assoc_name] ||= "#{options[:parent_class_name].to_s.underscore}".to_sym

        # Create the symbol name for the "belongs_to" association in the entry key model
        options[:key_assoc_name] ||= "#{options[:key_class_name].to_s.underscore}".to_sym

        # Create the symbol name for the "has_and_belongs_to_many" association in the entry key model
        options[:key_tag_assoc_name] ||= "#{options[:key_tag_class_name].to_s.underscore}".tableize.to_sym

        # Create the symbol name for the "has_and_belongs_to_many" association in the entry key_tag model
        options[:key_many_assoc_name] ||= "#{options[:key_class_name].to_s.underscore}".tableize.to_sym

        # Create the symbol name for the "has_many" association in the parent model
        options[:entry_assoc_name] = options[:entry_class_name].to_s.tableize.to_sym

        # Change slashes to underscores in options to match what's output by the generator
        # TODO: Refactor table naming into one location
        options[:table_name] = options[:table_name].to_s.gsub(/\//,'_').to_sym
        options[:parent_assoc_name] = options[:parent_assoc_name].to_s.gsub(/\//,'_').to_sym
        options[:key_assoc_name] = options[:key_assoc_name].to_s.gsub(/\//,'_').to_sym
        options[:key_tag_assoc_name] = options[:key_tag_assoc_name].to_s.gsub(/\//,'_').to_sym
        options[:key_many_assoc_name] = options[:key_many_assoc_name].to_s.gsub(/\//,'_').to_sym
        options[:entry_assoc_name] = options[:entry_assoc_name].to_s.gsub(/\//,'_').to_sym

        # Create our custom type if it doesn't exist already
        options[:key_class] = create_eav_key_class options
        options[:key_tag_class] = create_eav_key_tag_class options
        options[:paper_trail_class] = create_paper_trail_abstract_class options
        options[:version_class] = create_eav_version_class options
        options[:entry_class] = create_eav_table_class options

        return options
      end

      # Creates a new type subclassed from ActiveRecord:::EavEntry which represents an eav_hash key-value pair
      def self.create_eav_key_class (options)
        sanity_check options

        # Don't overwrite an existing type
        return class_from_string(options[:key_class_name].to_s) if class_from_string_exists?(options[:key_class_name])

        # Create our type
        klass = set_constant_from_string options[:key_class_name].to_s, Class.new(ActiveRecord::Base)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          self.table_name = "#{options[:key_table_name]}"
          validates :config_key, uniqueness: true, presence: true
          validates :slug, uniqueness: true, presence: true
          validates :display_name, presence: true
          before_validation :prepare_key
          has_and_belongs_to_many :#{options[:key_tag_assoc_name]}, join_table: "#{options[:key_tag_table_name]}_#{options[:key_table_name]}"
          has_many :#{options[:entry_assoc_name]}, 
            class_name: "#{options[:entry_class_name]}", 
            foreign_key: "#{options[:key_assoc_name]}_id", 
            dependent: :delete_all

          def prepare_key
            return if config_key.nil?
            self.config_name ||= config_key.to_s.gsub(' ', '_')
            placeholder = Util.clean_up_key(config_key)
            possible_slugs = self.config_name.split('/')
            provisional_slug = nil
            until possible_slugs.empty?
              provisional_slug = [possible_slugs.pop, provisional_slug].compact.join("_")
              break unless #{klass}.find_by(slug: provisional_slug)
            end
            self.slug ||= provisional_slug
            self.config_key = placeholder
          end
          def config_key
             super.to_s.to_sym
          end
        END_EVAL

        return klass
      end

      # Creates a new type subclassed from ActiveRecord:::EavEntry which represents an eav_hash key-value pair
      def self.create_eav_key_tag_class (options)
        sanity_check options

        # Don't overwrite an existing type
        return class_from_string(options[:key_tag_class_name].to_s) if class_from_string_exists?(options[:key_tag_class_name])

        # Create our type
        # puts "options[:key_tag_class_name]: #{options[:key_tag_class_name]}"
        klass = set_constant_from_string options[:key_tag_class_name].to_s, Class.new(ActiveRecord::Base)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          self.table_name = "#{options[:key_tag_table_name]}"
          
          has_and_belongs_to_many :"#{options[:key_many_assoc_name]}", join_table: "#{options[:key_tag_table_name]}_#{options[:key_table_name]}"

          has_many :#{options[:entry_assoc_name]}, 
            class_name: "#{options[:entry_class_name]}", 
            foreign_key: "#{options[:key_assoc_name]}_id", 
            through: "#{options[:key_many_assoc_name]}",
            dependent: :delete_all
        END_EVAL

        return klass
      end

      def self.create_paper_trail_abstract_class (options)
        sanity_check options

        # Create our type
        klass = set_constant_from_string options[:paper_trail_abstract_class].to_s, Class.new(ActiveRecord::Base)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          include PaperTrail::VersionConcern
          self.abstract_class = true
        END_EVAL

        return klass
      end

      # Creates a new type subclassed from PaperTrail::Version which allows us to have unique tables for each eav_hash
      def self.create_eav_version_class (options)
        sanity_check options

        # Don't overwrite an existing type
        #
        # NOTE: This does not work because class_from_string_exists? expects a string not a symbol
        # IF you want it to work, replace it with the commented line below; WARNING: it's not fully
        # tested, hence why it's still commented out.  At a minimum your existing class needs to
        # include the PaperTrail::Version concern.
        # return class_from_string(options[:version_class_name].to_s) if class_from_string_exists?(options[:version_class_name].to_s)
        return class_from_string(options[:version_class_name].to_s) if class_from_string_exists?(options[:version_class_name])

        # Create our type
        klass = set_constant_from_string options[:version_class_name].to_s, Class.new(PaperTrail::Version)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          self.table_name = "#{options[:version_table_name]}"
        END_EVAL

        return klass
      end

      # Creates a new type subclassed from ActiveRecord::EavHashes::EavEntry which represents an eav_hash key-value pair
      def self.create_eav_table_class (options)
        sanity_check options

        # Don't overwrite an existing type
        #
        # NOTE: This does not work because class_from_string_exists? expects a string not a symbol
        # IF you want it to work, replace it with the commented line below; WARNING: it's not fully
        # tested, hence why it's still commented out.
        # return class_from_string(options[:entry_class_name].to_s) if class_from_string_exists?(options[:entry_class_name].to_s)
        return class_from_string(options[:entry_class_name].to_s) if class_from_string_exists?(options[:entry_class_name])

        # Create our type
        klass = set_constant_from_string options[:entry_class_name].to_s, Class.new(ActiveRecord::EavHashes::EavEntry)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          has_paper_trail class_name: '#{options[:version_class_name]}' if #{options[:use_versioning]}
          self.table_name = "#{options[:table_name]}"
          belongs_to :#{options[:parent_assoc_name]}
          belongs_to :#{options[:key_assoc_name]}

          # Let the key be assignable only once on creation
          attr_readonly :#{options[:key_assoc_name]}_id
    
          def key
            k = #{options[:key_class]}.find(read_attribute(:#{options[:key_assoc_name]}_id)).config_key
          end
    
          def key_name
            k = #{options[:key_class]}.find(read_attribute(:#{options[:key_assoc_name]}_id)).config_name
          end
    
          # Raises an error if you try changing the key (unless no key is set)
          def key= (val)
            raise "Keys are immutable!" if read_attribute(:#{options[:key_assoc_name]}_id)
            # raise "Key must be a string!" unless val.is_a?(String) or val.is_a?(Symbol)
            write_attribute :#{options[:key_assoc_name]}_id, val
          end

        END_EVAL

        return klass
      end

      # Searches an EavEntry's table for the specified key/value pair and returns an
      # array containing the IDs of the models whose eav_hash key/value pair.
      # You should not run this directly.
      # @param [String, Symbol] key the key to search by
      # @param [Object] value the value to search by. if this is nil, it will return all models which contain `key`
      # @param [Hash] options the options hash which eav_hash_for hash generated.
      # #
      # #
      # We are using key objects instead of just strings or symbols so we need to find the proper key object first
      def self.run_find_expression (key, value, options)
        sanity_check options
        raise "Can't search for a nil key!" if key.nil?
        key_id = options[:key_class].find_by(config_key: Util.clean_up_key(key)).id
        if value.nil?
          options[:entry_class].where(
              "#{options[:key_assoc_name]}_id = ?",
              key_id
          ).pluck("#{options[:parent_assoc_name]}_id")
        else
          val_type = EavEntry.get_value_type value
          if val_type == EavEntry::SUPPORTED_TYPES[:Object]
            raise "Can't search by Objects/Hashes/Arrays!"
          else
            options[:entry_class].where(
                "#{options[:parent_assoc_name]}_id = ? and value = ? and value_type = ?",
                key,
                value.to_s,
                val_type
            ).pluck("#{options[:parent_assoc_name]}_id")
          end
        end
      end

      # Find a class even if it's contained in one or more modules.
      # See http://stackoverflow.com/questions/3163641/get-a-class-by-name-in-ruby
      def self.class_from_string(str)
        str.split('::').inject(Object) do |mod, class_name|
          mod.const_get(class_name)
        end
      end

      # Check whether a class exists, even if it's contained in one or more modules.
      def self.class_from_string_exists?(str)
        begin
          class_from_string(str)
        rescue
          return false
        end
        true
      end

      # Set a constant from a string, even if the string contains modules. Modules
      # are created if necessary.
      def self.set_constant_from_string(str, val)
        parent = str.deconstantize.split('::').inject(Object) do |mod, class_name|
          mod.const_defined?(class_name) ? mod.const_get(class_name) : mod.const_set(class_name, Module.new())
        end
        parent.const_set(str.demodulize.to_sym, val)
      end

      def self.clean_up_key(key)
        key.to_s.underscore.gsub(' ', '_').gsub('/', '_').gsub('.', '_').to_sym
      end
    end
  end
end
