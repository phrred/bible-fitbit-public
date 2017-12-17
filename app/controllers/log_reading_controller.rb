class LogReadingController < ApplicationController

  @@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse!

  def show
  	@book_names = @@books.map { |b| b.book  }
  	@previous_book = nil
  	@selected_book = Chapter.new
  	@chapter_num = 5
  end

  def search
  	@selected_book =  params[:chapter][:book]
  	@chapter_num = @@books.select { |b| b.book == @selected_book }[0].ch_num
  	respond_to do |format|
  		format.js
  	end	
  	
  end
end
