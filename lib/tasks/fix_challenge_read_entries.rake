desc "This task corrects challenge read entry dates"

task :fix_challenge_read_entry_dates => :environment do
  puts "fix_challenge_read_entry_dates"
  fix_annual_count
  puts "done."
end

def fix_annual_count
	 challenge_read_entries = ChallengeReadEntry.where(accepted: true)
	 challenge_read_entries.each do |entry|
	 	challenge = entry.challenge
	 	to_delete = []
	 	entry.read_at.each_with_index do |date, index|
	 		if date <= challenge.start_time
	 			to_delete.unshift(index)
	 		end
	 	end
	 	to_delete.each do |index|
 			entry.read_at.delete_at(index)
 			entry.chapters.delete_at(index)
	 	end
	 	entry.save
	 end
end
	