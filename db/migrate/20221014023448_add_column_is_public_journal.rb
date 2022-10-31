class AddColumnIsPublicJournal < ActiveRecord::Migration[7.0]
  def change
    add_column :journals, :is_public, :boolean, default: true, null: false
  end
end
