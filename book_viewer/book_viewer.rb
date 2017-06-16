require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

require 'pry'

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
	def in_paragraphs(text)
		text.split("\n\n")
	end
end

not_found do
	redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

def each_chapter
	@contents.each_with_index do |chapter, index|
		yield(File.read("data/chp#{index + 1}.txt"), index)
	end
end

def matching_chapters(any_word)
	selected_chapters = []
	each_chapter do |chapter, index|
		if chapter.include?(any_word)
			selected_chapters << (index + 1).to_s
		end
	end
	selected_chapters
end


get "/search" do
	word = params[:query]
	if !word.nil?
		@successful_request_chapters = matching_chapters(word)
	end
	erb :search
end
