require 'mongo_mapper'

module MongoMapper::Denormalization
  def self.included(mod)
    mod.extend(MongoMapper::Denormalization::ClassMethods)
  end

  module ClassMethods
    def denormalize_field(association, field, options={})
      denormalize(association, field, options)
    end

    def denormalize_association(dest, options={})
      options = options.dup
      source = options.delete(:from)

      if !source
        raise "denormalize_association must take a from (source) option"
      end

      denormalize(source, dest, {
        :target_field => dest,
      }.merge(options))
    end

    def denormalize(association, field, options={})
      method_name = "denormalize_#{association}_#{field}"

      validation_method = options[:on] || "before_validation"
      source_field_code = options[:source_field] || "#{association}.#{field}"
      target_field_code = options[:target_field] || "#{association}_#{field}"

      self.class_eval <<-CODE, __FILE__, __LINE__
        #{validation_method} :#{method_name}

        def #{method_name}
          if self.#{association}
            self.#{target_field_code} = #{source_field_code}
          end

          true
        end

        private :#{method_name}
      CODE
    end
  end
end
