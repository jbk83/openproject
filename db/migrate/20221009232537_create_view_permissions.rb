class CreateViewPermissions < ActiveRecord::Migration[7.0]
  def up
    roles = Role.all

    roles.each do |role|
      RolePermission.create(permission: :view_estimated_time, role: role)
      RolePermission.create(permission: :view_remaining_time, role: role)
      RolePermission.create(permission: :view_version, role: role)
      RolePermission.create(permission: :view_done_ratio, role: role)

      CustomField.all.each do |cf|
        p = cf.name.underscore.parameterize(separator: '_')
        RolePermission.create(permission: "view_#{p}", role: role)
      end
    end
  end

  def down
    RolePermission.where(permission: :view_estimated_time).delete_all
    RolePermission.where(permission: :view_remaining_time).delete_all
    RolePermission.where(permission: :view_version).delete_all
    RolePermission.where(permission: :view_done_ratio).where

    CustomField.all.each do |cf|
      p = cf.name.underscore.parameterize(separator: '_')
      RolePermission.where(permission: "view_#{p}").delete_all
    end
  end
end
