desc "This task finishes challenges"

task :update_feed => :environment do
  puts "Finishing Challenges"
  Challenges.check_ending_challenges
  puts "done."
end

