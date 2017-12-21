class LogReadingController < ApplicationController
  skip_before_action :verify_authenticity_token

  @@chapters = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse!

  def show
  	@book_names = @@chapters.map { |b| b.book  }
  	@previous_book = nil
  	userId = session[:user_id]
    user = User.find(userId)
    @warning = session[:warning]
    session[:warning] = nil
  	prev_book = ReadEvent.where(user: userId).order("created_at").last
    if prev_book != nil
      last_read_event = ReadEvent.joins(:chapter).where(chapters: {book: prev_book.chapter.book}).order("read_at").last
      if last_read_event != nil
        @last_read_date = last_read_event.read_at.strftime('%a %b %d %Y')
      end
      @selected_book = prev_book.chapter
      @displayed_book = @selected_book.book
      @previous_book_name = @selected_book.book
      @chapter_num = @@chapters.select { |b| b.book == @previous_book_name }[0].ch_num
      user_shadowing = UserShadowing.find_by(user: user, book: @previous_book_name)
      @highlighted_chapters = []
      if user_shadowing != nil
        @highlighted_chapters = user_shadowing.shadowing
      end
    end
  	@selected_book = Chapter.new
  end

  def search
  	userId = session[:user_id]
    user = User.find(userId)
    @submitted_date = ReadEvent.new;
  	@selected_book =  params[:chapter][:book]
    last_read_event = ReadEvent.joins(:chapter).where(chapters: {book: @selected_book}).order("read_at").last
    if last_read_event != nil
      @last_read_date = last_read_event.read_at.strftime('%a %b %d %Y')
    end
  	@chapter_num = @@chapters.select { |b| b.book == @selected_book }[0].ch_num
  	user_shadowing = UserShadowing.find_by(user: user, book: @selected_book)
    @highlighted_chapters = []
    if user_shadowing != nil
      @highlighted_chapters = user_shadowing.shadowing
    end
  	respond_to do |format|
  		format.js
    end
  end

  def update
    chapters = params[:record]
    date = params[:date]
    year = date.to_time.strftime('%Y').to_i
    @displayed_book = params[:book]
    user = User.find(session[:user_id])
    lifetime_count = user.lifetime_count
    annual_counts = user.annual_counts
    annual_count = nil
    if annual_counts.empty?
      annual_count = Count.create!(count: 0, year: Time.current.year)
      user.annual_counts << annual_count.id
    else
      annual_count = annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0]
    end
    readEntry = ChallengeReadEntry.where(user: user)
    if readEntry != nil
      challenges = readEntry.map { |entry| entry.challenge.valid_books.include?(@displayed_book) }
    end
    chapters_read = []
    chapters.each { |chapter_num|
      chapter = Chapter.find_by(book: @displayed_book, ch_num: chapter_num)
      if ReadEvent.where(read_at: date, user: user, chapter: chapter).take == nil
        lifetime_count.count += 1
         annual_count.count += 1
        ReadEvent.create!(read_at: date, user: user , chapter: chapter)
        if challenges != nil
          challenges.each { |challenge_entry|
            challenge_entry.chapters << chapter.id
            challenge_entry.save
          }
        end
        user_shadowing = UserShadowing.find_by(user: user, book: chapter.book)
        if user_shadowing != nil
          user_shadowing.shadowing << chapter_num
          user_shadowing.save
        else
          user_shadowing = UserShadowing.create(user: user, book: chapter.book)
          user_shadowing.shadowing << chapter_num
          user_shadowing.save
        end
      else
        chapters_read << chapter_num
      end
    }
    lifetime_count.save
     annual_count.save
     user.save
    if chapters_read.any?
      session[:warning] = 'These chapters have already been logged for ' + date.to_time.strftime('%a %b %d %Y') +": " + chapters_read.join(", ")
    end
  end

  def resetBook
    @displayed_book = params[:book]
    user = User.find(session[:user_id])
    user_shadowing = UserShadowing.find_by(user: user, book: @displayed_book)
    if user_shadowing != nil
      user_shadowing.shadowing = []
      user_shadowing.save
    end
  end

  def resetBible
    user = User.find(session[:user_id])
    user_shadowings = UserShadowing.where(user: user)
    user_shadowings.each { |s|
      s.shadowing = []
      s.save
    }
  end

end
