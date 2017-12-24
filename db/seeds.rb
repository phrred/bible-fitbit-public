# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'date'

if Group.find_by(name: "45+").nil?
	Group.create!(name: "45+", group_type: "peer_class")
end
(1996..2017).each do |year|
	if Group.find_by(name: year.to_s).nil?
		Group.create(name: year.to_s, group_type: "peer_class")
	end
end

json = ActiveSupport::JSON.decode(File.read('db/seeds/bible.json'))

json.each do |book|
  book['chapters'].each do |chapter|
  	if Chapter.find_by(book: book['book'], ch_num: chapter['chapter'], verse_count: chapter['verses']).nil?
  		Chapter.create!(book: book['book'], ch_num: chapter['chapter'], verse_count: chapter['verses'])
  	end
  end
end

File.readlines('db/seeds/groups.txt').each do |line|
	line = line.strip;
	groups = line.split(',')
	region_name = groups[0].strip
	state_name = groups[1].strip
	group_name = groups[2].strip
	region =  Group.find_by(name: region_name)
	state =  Group.find_by(name: state_name)
	group = Group.find_by(name: group_name)
	if region.nil? && !region_name.blank?
		region = Group.create!(name: region_name, group_type: "region")
	end
	if state.nil? && !state_name.blank?
		state = Group.create!(name: state_name, group_type: "state")
		state.parent = region
		state.save
	end
	if group.nil? && !group_name.blank?
		group = Group.create!(name: group_name, group_type: "ministry")
		group.parent = state
		group.save
	end
end
p "Seeded db."
