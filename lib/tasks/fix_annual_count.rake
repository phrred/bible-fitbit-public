desc "This task corrects annual counts"

task :fix_annual_count => :environment do
  puts "fix_annual_count annual count"
  fix_annual_count
  puts "done."
end

def fix_annual_count
	 read_events = ReadEvent.where('extract(year from read_at) =? AND extract(year from created_at) =?', 2017, 2018)
	 read_events.each do |event|
	 	user = event.user
	 	annual_counts = user.annual_counts
	 	count_2017 = annual_counts.map { |c| Count.find(c) }.select { |count| count.year == 2017 }
	 	if count_2017.nil? || count_2017.empty?
		 	count_2017 = Count.create!(count: 1, year: 2017)
		 	user.annual_counts.insert(0, count_2017.id)
		 	count_2018 = annual_counts.map { |c| Count.find(c) }.select { |count| count.year == 2018 }
		 	if count_2018.nil? || count_2018.empty?
		 	else
		 		count_2018 = count_2018[0]
		 		count_2018.count -= 1
		 	end

		 	count_2018.save
		 	count_2017.save
		 	user.save
		 else
		 	count_2017 = count_2017[0]

		 	count_2017.count += 1
		 	count_2018 =annual_counts.map { |c| Count.find(c) }.select { |count| count.year == 2018 }
		 	if count_2018.nil? || count_2018.empty?
		 	else
		 		count_2018 = count_2018[0]
		 		count_2018.count -= 1
		 	end

		 	count_2017.save
		 	count_2018.save
		 end
	 end
end
	