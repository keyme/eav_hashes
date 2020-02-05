require 'rails/generators'
require 'rails/generators/active_record'

class EavMigrationGenerator < ActiveRecord::Generators::Base

  source_root File.expand_path "../templates", __FILE__
  # small hack to override NamedBase displaying NAME
  argument :name, :required => true, :type => :string, :banner => "<ModelName>"
  argument :hash_name, :required => true, :type => :string, :banner => "<hash_name>"
  argument :custom_table_name, :required => false, :type => :string, :banner => "table_name"

  def create_eav_migration
    
    p "#{name} Key"
    migration_template "eav_key_migration.erb", "db/migrate/#{key_migration_file_name}.rb"
    p "#{name} Key Tag"
    migration_template "eav_key_tag_migration.erb", "db/migrate/#{key_tag_migration_file_name}.rb"
    p "#{name} Versions, version_migration_file_name: #{version_migration_file_name}"
    migration_template "version_migration.erb", "db/migrate/#{version_migration_file_name}.rb"
    p name
    migration_template "eav_migration.erb", "db/migrate/#{migration_file_name}.rb"
  end

  def key_migration_file_name
    "create_" + key_table_name
  end

  def key_tag_migration_file_name
    "create_" + key_tag_table_name
  end

  def migration_file_name
    "create_" + table_name
  end

  def version_migration_file_name
    "create_" + version_table_name
  end

  def migration_name
    migration_file_name.camelize
  end

  def key_migration_name
    key_migration_file_name.camelize
  end

  def key_tag_migration_name
    key_tag_migration_file_name.camelize
  end

  def version_migration_name
    version_migration_file_name.camelize
  end

  def table_name
    custom_table_name || "#{name}_#{hash_name}".underscore.gsub(/\//, '_')
  end

  def key_table_name
    "#{custom_table_name || "#{name}_#{hash_name}".underscore.gsub(/\//, '_')}_keys"
  end

  def key_tag_table_name
    "#{custom_table_name || "#{name}_#{hash_name}".underscore.gsub(/\//, '_')}_key_tags"
  end

  def version_table_name
    "#{custom_table_name || "#{name}_#{hash_name}".underscore.gsub(/\//, '_')}_versions"
  end

  def model_name
    name
  end

  def model_association_name
    model_name.underscore.gsub(/\//,'_')
  end

  def key_model_association_name
    key_table_name.singularize
  end
end
