desc "This task finishes challenges"

task :update_challenges => :environment do
  puts "Finishing Challenges..."
  check_ending_challenges
  puts "done."
end
def check_ending_challenges
	if Date.today.sunday?
		monday = Date.today.beginning_of_week
		challenges = Challenge.where("start_time = ?", monday)
		challenges.find_each do |challenge|
			sender_group = challenge.sender_ministry
			sender_number = 0
			receiver_number = 0
			sender_sum = 0
			receiver_sum = 0
			entries = ChallengeReadEntry.where(challenge: challenge, accepted: true)
			if entries != nil
				entries.each do |entry|
					if is_user_in_group(entry.user, sender_group)
						sender_number = sender_number + 1
						sender_sum = sender_sum + entry[:chapters].size
					else
						receiver_number = receiver_number + 1
						receiver_sum = receiver_sum + entry[:chapters].size
					end
				end
			end
			sender_final = sender_number != 0 ? sender_sum/sender_number.to_f : 0
			receiver_final = receiver_number != 0 ? receiver_sum/receiver_number.to_f : 0
			if sender_final > receiver_final
				challenge.update(winner: true)
			else
				challenge.update(winner: false)
			end
		end
	end
end
def is_user_in_group(user, group)
	if user[:peer_class] == group
		return true
	end
	user_group = user.ministry
	while user_group != nil
		if user_group == group
			return true
		end
		user_group = user_group.parent
	end
	return false
end