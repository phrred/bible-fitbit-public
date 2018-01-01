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
	region_names = groups[0].strip.split('/')
	region_name = region_names[0]
	other_region_name = region_names[1]
	state_name = groups[1].strip
	group_name = groups[2].strip
	region =  Group.find_by(name: region_name)
	state =  Group.find_by(name: state_name)
	group = Group.find_by(name: group_name)
	other_region = Group.find_by(name: other_region_name)

	if region.nil? && !region_name.blank?
		region = Group.create!(name: region_name, group_type: "region")
		if !state.nil?
			state.parent = region
			state.save
			if !other_region.nil?
				other_region.parent = state
				other_region.save
				if !group.nil?
					group.parent = other_region
					group.save
				end
			else
				if !group.nil?
					group.parent = state
					group.save
				end
			end
		end
	end

	if state.nil? && !state_name.blank?
		state = Group.create!(name: state_name, group_type: "state")
		state.parent = region
		state.save
		if !other_region.nil?
				other_region.parent = state
				other_region.save
			if !group.nil?
				group.parent = other_region
				group.save
			end
		else
			if !group.nil?
				group.parent = state
				group.save
			end
		end
	end

	if other_region.nil? && !other_region_name.blank?
		other_region = Group.create!(name: other_region_name, group_type: "region")
		other_region.parent = state
		if !group.nil?
			group.parent = other_region
			group.save
		end
		other_region.save
	end

	if group.nil? && !group_name.blank?
		group = Group.create!(name: group_name, group_type: "ministry")
		if !other_region.nil?
			group.parent = other_region
		else
			group.parent = state
		end	
		group.save
	end
end
p "Seeded db."
