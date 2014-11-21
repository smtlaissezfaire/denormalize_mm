require 'mongo_mapper'

module MongoMapper::Denormalization
  def self.included(mod)
    mod.extend(MongoMapper::Denormalization::ClassMethods)
  end

  module ClassMethods
    def denormalize_field(association, field, options={})
      denormalize(association, field, options)
    end

    def denormalize_associations(*destinations)
      options = destinations.last.is_a?(Hash) ? destinations.pop.dup : {}
      source = options.delete(:from)

      if !source
        raise "denormalize_association must take a from (source) option"
      end

      destinations.each do |dest|
        denormalize(source, dest, {
          :target_field => dest,
          :is_association => true
        }.merge(options))
      end
    end

    alias_method :denormalize_association, :denormalize_associations

    def denormalize(association, field, options={})
      association = association.to_sym
      field = field.to_sym

      validation_method = options[:on] || :before_validation
      source_field_code = options[:source_field] || :"#{association}.#{field}"
      target_field_code = options[:target_field] || :"#{association}_#{field}"
      is_association = options[:is_association]

      denormalize_on_validation(association, field, validation_method, source_field_code, target_field_code)
      denormalize_on_update(association, field, is_association, target_field_code)
    end

  private

    def denormalize_on_update(association, field, is_association, target_field_code)
      if is_association
        field = :"#{field}_id"
        target_field_code = :"#{target_field_code}_id"
      end

      klass = self.associations[association].klass

      collection_name = self.collection_name
      reverse_denormalization_method_name = "_denormalize__#{collection_name}__#{association}__#{field}".gsub(/[^A-Za-z0-9_]/, '_')

      klass.class_eval(<<-CODE, __FILE__, __LINE__)
        after_update :#{reverse_denormalization_method_name}

        def #{reverse_denormalization_method_name}
          return true unless self.respond_to?(:#{field}) && self.respond_to?(:#{field}_changed?)

          if self.#{field}_changed?
            db = MongoMapper.database

            find_query = {
              :#{association}_id => self.id
            }
            update_query = {
              '$set' => {
                :#{target_field_code} => self.#{field}
              }
            }

            db["#{collection_name}"].update(find_query, update_query, :multi => true)
          end

          true
        end

        private :#{reverse_denormalization_method_name}
      CODE
    end

    def denormalize_on_validation(association, field, validation_method, source_field_code, target_field_code)
      validation_method_name = :"denormalize_#{association}_#{field}"

      # denormalize the field
      self.class_eval <<-CODE, __FILE__, __LINE__
        #{validation_method} :#{validation_method_name}

        def #{validation_method_name}
          if self.#{association}
            self.#{target_field_code} = #{source_field_code}
          end

          true
        end

        private :#{validation_method_name}
      CODE
    end
  end
end
