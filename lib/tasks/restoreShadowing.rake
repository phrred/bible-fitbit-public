namespace :restore_shadowing do

	desc "This task restores user shadowing"

	task :user, [:id] => :environment do |t, args|
	  puts "Restoring Shadowing"
	  restore_shadowing(args[:id])
	  puts "done."
	end
	def restore_shadowing(id)
		 read_event = ReadEvent.where(user_id: id)
		 read_event.each do |event|
		 	chapter = event.chapter
		 	user_shadowing = UserShadowing.find_by(user:id, book: chapter.book)
		 	if !user_shadowing.nil?
		 		if !user_shadowing.shadowing.include? chapter.ch_num
				 	user_shadowing.shadowing << chapter.ch_num
				 	user_shadowing.save
				 end
			 end
		 end
	end
end
