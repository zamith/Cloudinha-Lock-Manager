# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

machine_types = [ 
  {:name => "Cloudinha"},
  {:name => "PDs"}
]

machine_types.each do |attributes| 
  MachineType.find_or_initialize_by_name(attributes[:name]).save!
end