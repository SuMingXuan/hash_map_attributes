require "hash_map_attributes/version"

module HashMapAttributes
  def self.included(base)
    base.extend ClassMethods    
  end

  module ClassMethods
    def hash_map_attributes(*attributes, to:)
      _hash_map_attributes
      attributes.each do |attribute|
        self.instance_variable_get('@_hash_map_attributes') << attribute.to_s
      end
      class_eval do
        _hash_map_attributes.each do |hma|
          define_method hma do
            send(to).to_hash.stringify_keys![hma]
          end

          define_method "#{hma}=" do |v|
            send(to).to_hash.stringify_keys![hma] = v
          end
        end
      end
    end

    def _hash_map_attributes
      @_hash_map_attributes ||= Set.new
    end
  end
end
