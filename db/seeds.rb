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


umd = Group.create!(name: "umd")
umd_klesis = Group.create!(name: "umd_klesis")
umd_kairos = Group.create!(name: "umd_kairos")

umd_klesis.parent = umd
umd_klesis.save
umd_kairos.parent = umd
umd_kairos.save

co2016 = Group.create!(name: "2016")

sam_chiou = User.create!(
	email: "samuel.chiou@gpmail.org", 
	name: "Sam Chiou", 
	gender: "male",
	ministry: umd_klesis,
	peer_class: co2016,
	lifetime_count: Count.create(count: 1, year: 0)
)

p "Seeded db."
