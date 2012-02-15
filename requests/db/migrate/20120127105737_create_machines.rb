class CreateMachines < ActiveRecord::Migration
  def self.up
    create_table :machines do |t|
      t.column :user, :string , :default => "free", :null => false
      t.column :domain, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :machines
  end
end
