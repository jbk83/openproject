#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2022 the OpenProject GmbH
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

module RolesHelper
  def setable_permissions(role)
    # Use the base contract for now as we are only interested in the setable permissions
    # which do not differentiate.
    contract = Roles::BaseContract.new(role, current_user)

    contract.assignable_permissions
  end

  def grouped_setable_permissions(role)
    group_permissions_by_module(setable_permissions(role))
  end

  def group_permissions_by_module(perms)
    enabled_module_names = ::OpenProject::AccessControl.sorted_module_names(include_disabled: false)
    permissions = perms.group_by { |p| p.project_module.to_s }
         .slice(*enabled_module_names)

    add_custom_fields_permissions(permissions)
  end

  def add_custom_fields_permissions(permissions)
    return permissions if permissions["work_package_tracking"].nil?
    custom_fields = CustomField.all

    custom_fields.each do |cf|
      perm_name = cf.name.underscore.parameterize(separator: '_')
      custom_perm = ::OpenProject::AccessControl::PermissionCustomField.new(
        "view_#{perm_name}".to_sym, 
        [],
        project_module: :work_package_tracking
      )
      permissions["work_package_tracking"].push(custom_perm)
    end
    puts permissions
    permissions
  end
end
