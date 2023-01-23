#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module JournalFormatter
  class NamedAssociation < Attribute
    def render(key, values, options = { no_html: false })
      return "" if !user_allowed_to_see_association(key.to_s.gsub(/_id$/, ''))
      label, old_value, value = format_details(key, values, options)

      unless options[:no_html]
        label, old_value, value = *format_html_details(label, old_value, value)
      end

      render_ternary_detail_text(label, value, old_value, options)
    end

    private

    def format_details(key, values, options = {})
      label = label(key)

      old_value, value = *format_values(values, key, options)

      [label, old_value, value]
    end

    def format_values(values, key, options)
      field = key.to_s.gsub(/_id\z/, '').to_sym
      klass = class_from_field(field)

      values.map do |value|
        if klass
          record = associated_object(klass, value.to_i, options)
          if record
            if record.respond_to? 'name'
              record.name
            else
              record.subject
            end
          end
        end
      end
    end

    def associated_object(klass, id, options = {})
      cache = options[:cache]

      if cache.is_a?(Acts::Journalized::JournalObjectCache)
        cache.fetch(klass, id) do |k, i|
          k.find_by(id: i)
        end
      else
        klass.find_by(id:)
      end
    end

    def label(key)
      @journal.journable.class.human_attribute_name(key.to_s.gsub(/_id$/, ''))
    end

    def class_from_field(field)
      association = @journal.journable.class.reflect_on_association(field)

      association&.class_name&.constantize
    end

    def user_allowed_to_see_association(key)
      perm = "view_#{key}".to_sym
      permissions_to_check = OpenProject::AccessControl
                              .permissions
                              .select { |m| m.project_module == :work_package_tracking }
                              .map(&:name)

      return true if !permissions_to_check.include?(perm)

      User.current.admin? ||
        User.current.allowed_to?(perm, @journal.journable.project)
    end
  end
end
