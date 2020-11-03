require "hash_map_attributes/version"

module HashMapAttributes
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def hash_map_attributes(*attributes, to:)
      _hash_map_attributes
      attributes.each do |attribute|
        @_hash_map_attributes[to] ||= Set.new
        @_hash_map_attributes[to] << attribute.to_s
      end
      class_eval do
        _hash_map_attributes.each_pair do |_to, _attributes|
          _attributes.each do |_attribute|
            define_method _attribute do
              send(_to).to_hash.stringify_keys![_attribute]
            end

            define_method "#{_attribute}=" do |v|
              send(_to).to_hash.stringify_keys![_attribute] = v
            end
          end
        end
      end
    end

    def where_hash(**options)
      arr = []
      class_name = model_name.plural
      options.each_pair do |k, v|
        to = _hash_map_attributes.select { |a, b| b.include?(k.to_s) }.keys.first
        next if to.nil?

        arr << "#{class_name}.#{to.to_s}->>'#{k}' = '#{v}'"
      end
      sql = arr.join(' and ')
      where(sql)
    end

    def _hash_map_attributes
      @_hash_map_attributes ||= {}
    end
  end
end
