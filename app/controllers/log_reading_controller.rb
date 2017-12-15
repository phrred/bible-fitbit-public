class LogReadingController < ApplicationController
  def show
  	@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse!
  	@selected_book = nil
  end

  def search
  	p params[:book]
  end
end
