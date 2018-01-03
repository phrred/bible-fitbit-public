desc "This task adds users to challenges"

task :add_to_challenge => :environment do
  puts "Adding users to challenges"
  add_to_challenge
  puts "done."
end
def add_to_challenge
	 challenges = Challenge.all
	 challenges.each do |challenge|
	 	receiver_recipients = []
	 	receiver_gender = challenge.receiver_gender
	 	receiver_class = challenge.receiver_peer_id
	 	User.where(ministry: challenge.receiver_ministry).each do |user|
	 		user_read_entry = ChallengeReadEntry.where(user: user, challenge: challenge)
	 		if user_read_entry.nil? || user_read_entry.empty?
				receiver_recipients << user
			end
		end
		unless receiver_gender.nil?
			receiver_recipients = receiver_recipients.select { |user| user.gender == receiver_gender }
		end
		unless receiver_class.nil?
			receiver_recipients = receiver_recipients.select { |user| user.peer_class == receiver_class }
		end
		receiver_recipients.each do |user|
			create_challenge_read_entry(user, challenge)
		end
	end
end

def create_challenge_read_entry(user, challenge)
	ChallengeReadEntry.create!(challenge: challenge, user: user)
end

