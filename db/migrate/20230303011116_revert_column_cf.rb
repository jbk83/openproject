class RevertColumnCf < ActiveRecord::Migration[7.0]
  def change
    remove_column :custom_fields, :permission_name

    roles = Role.all

    roles.each do |role|
      CustomField.where(type: "WorkPackageCustomField").each do |cf|
        RolePermission.create(permission: "view_custom_field_#{cf.id}", role: role)
      end
    end
  end
end
