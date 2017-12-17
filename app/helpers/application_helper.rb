module ApplicationHelper

  @@bible_books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse!

  def bible_books
    @@bible_books
  end
end
