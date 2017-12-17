module ApplicationHelper

  @@bible_books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse!
	@@bible_chapter_count = Chapter.count()

  def bible_books
    @@bible_books
  end

	def bible_chapter_count
		@@bible_chapter_count
	end
end
