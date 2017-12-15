class LogReadingController < ApplicationController

  @@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse!

  def show
  	@book_names = @@books.map { |b| b.book  }
  	@previous_book = nil
  	@selected_book = Chapter.new
  end

  def search
  	@selected_book =  params[:chapter][:book]
  	@chapter_num = @@books.select { |b| b.book == @selected_book }.ch_num
  	p @chapter_num
  end
end
