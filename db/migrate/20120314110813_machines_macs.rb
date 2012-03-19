class MachinesMacs < ActiveRecord::Migration
  def self.up
  	add_column :machines, :mac, :string
  end

  def self.down
	
  end
end
