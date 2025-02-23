module Exports
  module Formatters
    class CustomField < Default
      def self.apply?(attribute)
        attribute.start_with?('cf_')
      end

      ##
      # Takes a WorkPackage and an attribute and returns the value to be exported.
      def retrieve_value(object)
        custom_field = find_custom_field(object)

        return '' if custom_field.nil?

        view_right = "view_custom_field_#{custom_field.id}".to_sym
        return '' if !User.current.allowed_to?(view_right, object.project)

        format_for_export(object, custom_field)
      end

      ##
      # Print the value meant for export.
      #
      # - For boolean values, don't use the Yes/No formatting for the UI
      # - For long text values, output the plain value
      def format_for_export(object, custom_field)
        case custom_field.field_format
        when 'bool', 'text'
          object.typed_custom_value_for(custom_field)
        else
          object.formatted_custom_value_for(custom_field)
        end
      end

      ##
      # Finds a custom field from the attribute identifier
      def find_custom_field(object)
        id = attribute.to_s.sub('cf_', '').to_i
        object.available_custom_fields.detect { |cf| cf.id == id }
      end
    end
  end
end
