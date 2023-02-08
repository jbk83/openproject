class AddPermissionNameToCf < ActiveRecord::Migration[7.0]
  def up
    add_column :custom_fields, :permission_name, :text

    CustomField.where(type: "WorkPackageCustomField").each do |cf|
      cf.permission_name = cf.name.underscore.parameterize(separator: '_')
      cf.save
    end
  end

  def down
    remove_column :custom_fields, :permission_name
  end
end
