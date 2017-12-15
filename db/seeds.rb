# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'date'


# purge all
Group.destroy_all
User.destroy_all
Count.destroy_all
Chapter.destroy_all


umd = Group.create!(name: "umd", group_type: "ministry")
umd_klesis = Group.create!(name: "umd_klesis", group_type: "ministry")
umd_kairos = Group.create!(name: "umd_kairos", group_type: "ministry")

umd_klesis.parent = umd
umd_klesis.save
umd_kairos.parent = umd
umd_kairos.save

co2016 = Group.create!(name: "2016", group_type: "peer_class")

json = ActiveSupport::JSON.decode(File.read('db/seeds/bible.json'))

json.each do |book|
  book['chapters'].each do |chapter|
  	Chapter.create!(book: book['book'], ch_num: chapter['chapter'], verse_count: chapter['verses'])
  end
end
p "Seeded db."
