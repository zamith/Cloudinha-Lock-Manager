class CreateMachineType < ActiveRecord::Migration
  def self.up
    create_table :machine_types do |t|
      t.string :name
      t.timestamps
    end
    add_column :machines, :machine_types_id, :integer, :null => false, :default => 1
  end

  def self.down
    drop_table :machine_types
    remove_column :machines, :machine_types_id
  end
end
