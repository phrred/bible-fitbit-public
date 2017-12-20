# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'date'

# purge all
Group.all.map { |g| g.really_destroy! }
User.all.map { |u| u.really_destroy! }
Count.all.map { |c| c.really_destroy! }
Chapter.all.map { |c| c.really_destroy! }

umd = Group.create!(name: "umd", group_type: "ministry")
umd_klesis = Group.create!(name: "umd_klesis", group_type: "ministry")
umd_kairos = Group.create!(name: "umd_kairos", group_type: "ministry")

umd_klesis.parent = umd
umd_klesis.save
umd_kairos.parent = umd
umd_kairos.save

co2016 = Group.create!(name: "2016", group_type: "peer_class")

test_count = Count.create!(year: 0, count: 5)
annual_count = Count.create!(year: 2017, count: 10)
test = User.create(
	name: "test",
	email: "test@gpmail.org",
	gender: true,
	ministry: umd_klesis,
	peer_class: co2016,
	lifetime_count: test_count,
)
test.annual_counts << annual_count.id
test.save

json = ActiveSupport::JSON.decode(File.read('db/seeds/bible.json'))

json.each do |book|
  book['chapters'].each do |chapter|
  	Chapter.create!(book: book['book'], ch_num: chapter['chapter'], verse_count: chapter['verses'])
  end
end

File.readlines('db/seeds/groups.txt').each do |line|
	Group.create!(name: line.strip, group_type: "ministry")
end
p "Seeded db."
