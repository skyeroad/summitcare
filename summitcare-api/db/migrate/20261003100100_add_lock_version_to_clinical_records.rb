class AddLockVersionToClinicalRecords < ActiveRecord::Migration[8.0]
  def change
    %i[lab_results appointments documents patients].each do |table|
      add_column table, :lock_version, :integer, null: false, default: 0
    end
  end
end
