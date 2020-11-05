require "hash_map_attributes/version"

module HashMapAttributes
  def self.included(base)
    base.extend ClassMethods
  end

  class AttributeContainer
    attr_reader :attribute, :to, :allow_nil, :method_name, :ancestors_name, :parent
    def initialize(attribute, to, allow_nil, parent)
      @to = to.to_s
      @attribute = attribute.to_s
      @allow_nil = allow_nil
      @parent = parent
      @method_name = @attribute
      @ancestors_name = []
    end

    def set_own_ancestors!(all_ancestores)
      parent_container = all_ancestores.find { |a| a.method_name == parent.to_s }
      @ancestors_name = parent_container.ancestors_name + [parent_container.attribute]
      @to = parent_container.to
      @method_name = \
        if @ancestors_name.empty?
          @attribute
        else
          "#{@ancestors_name.join('_')}_#{@attribute}"
        end
    end
  end

  module ClassMethods
    def hash_map_attributes(*attributes, to: nil, allow_nil: nil, parent: nil)
      _hash_map_attributes
      attributes.each do |attribute|
        container = AttributeContainer.new(attribute, to, allow_nil, parent)
        container.set_own_ancestors!(@_hash_map_attributes) if parent
        @_hash_map_attributes << container
      end
      class_eval do
        _hash_map_attributes.each do |container|
          _attribute = container.attribute
          _to = container.to
          _parent = container.parent
          method_name = container.method_name
          define_method method_name do
            if _parent
              send(_parent).to_hash.stringify_keys![_attribute]
            else
              send(_to).to_hash.stringify_keys![_attribute]
            end
          end

          define_method "#{method_name}=" do |v|
            if _parent
              send("#{_parent}=", {}) if send(_parent).empty?
              send(_parent).to_hash.stringify_keys![_attribute] = v
            else
              send("#{_to}=", {}) if send(_to).empty?
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
        container = _hash_map_attributes.find { |a| a.method_name == k.to_s }
        next if container.nil?

        to = container.to.to_s
        _attribute = container.attribute.to_s
        _ancestors_name = container.ancestors_name
        sql1 = "#{class_name}.#{to}"
        sql2 = \
          unless _ancestors_name.empty?
            %Q|->#{_ancestors_name.map {|a| "'#{a}'"}.join('->')}|
          end
        sql3 = "->>'#{_attribute}' = '#{v}'"

        arr << "#{sql1}#{sql2}#{sql3}"
      end
      sql = arr.join(' and ')
      where(sql)
    end

    def _hash_map_attributes
      @_hash_map_attributes ||= []
    end
  end
end
