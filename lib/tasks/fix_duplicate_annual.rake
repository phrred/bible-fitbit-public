desc "This task corrects annual counts"

task :fix_duplicate_annual => :environment do
  puts "fix_annual_count annual count"
  fix_duplicate_annual
  puts "done."
end

def fix_duplicate_annual
	 User.all.each do |u|
		 annual_counts = u.annual_counts
		 count_2018 = annual_counts.map { |c| Count.find(c) }.select { |count| count.year == 2018 }
		 if count_2018.size > 1
		 	first = count_2018[0]
		 	rest = count_2018.slice(1, count_2018.size)
		 	rest.each do |c|
		 		first.count += c.count
		 		c.delete
		 	end
		 	first.save
		 	u.annual_counts = [first.id]
		 	u.save
		end
	end
end