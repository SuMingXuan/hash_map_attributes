require "hash_map_attributes/version"

module HashMapAttributes
  def self.included(base)
    base.extend ClassMethods
  end

  class AttributeContainer
    attr_reader :attribute, :to, :prefix, :allow_nil, :method_name
    def initialize(attribute, to, prefix, allow_nil)
      @to = to.to_s
      @prefix = \
        if prefix
          "#{prefix == true ? to : prefix}_"
        else
          ''
        end
      @attribute = attribute.to_s
      @allow_nil = allow_nil
      @method_name = "#{@prefix}#{@attribute}"
    end
  end

  module ClassMethods
    def hash_map_attributes(*attributes, to:, prefix: nil, allow_nil: nil)
      _hash_map_attributes
      attributes.each do |attribute|
        @_hash_map_attributes << AttributeContainer.new(attribute, to, prefix, allow_nil)
      end
      class_eval do
        _hash_map_attributes.each do |container|
          _attribute = container.attribute
          _to = container.to
          method_name = container.method_name
          define_method method_name do
            send(_to).to_hash.stringify_keys![_attribute]
          end

          define_method "#{method_name}=" do |v|
            send(_to).to_hash.stringify_keys![_attribute] = v
          end
        end
      end
    end

    def where_hash(**options)
      arr = []
      class_name = model_name.plural
      options.each_pair do |k, v|
        container = _hash_map_attributes.find { |a| a.method_name == k.to_s }
        to = container.to.to_s
        _attribute = container.attribute.to_s
        next if to.nil?

        arr << "#{class_name}.#{to}->>'#{_attribute}' = '#{v}'"
      end
      sql = arr.join(' and ')
      where(sql)
    end

    def _hash_map_attributes
      @_hash_map_attributes ||= []
    end
  end
end
