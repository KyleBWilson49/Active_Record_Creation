require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key]
    @foreign_key ||= "#{name}_id".to_sym
    @primary_key = options[:primary_key]
    @primary_key ||= :id
    @class_name = options[:class_name]
    @class_name ||= "#{name}".camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key]
    @foreign_key ||= "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key]
    @primary_key ||= :id
    @class_name = options[:class_name]
    @class_name ||= "#{name.to_s.singularize}".camelcase
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method name do
      f_key = send options.foreign_key
      current_class = options.model_class
      current_class.where(:id => f_key).first
    end

    assoc_options[name] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, "#{self}", options)

    define_method name do
      value = send options.primary_key
      target_class = options.model_class
      target_class.where(options.foreign_key => value)
    end
  end

  def assoc_options
    @results ||= {}
  end
end

class SQLObject
  extend Associatable

end
