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

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
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

def matching_paragraphs(chapter_number, query)
  result = []
  content = File.read("data/chp#{chapter_number}.txt")
  paragraphs = in_paragraphs(content)
  paragraphs.each do |paragraph|
    result << paragraph if paragraph.include?(query)
  end
  result
end

def find_index(any_paragraph, any_chap_number)
  content = File.read("data/chp#{any_chap_number}.txt")
  in_paragraphs(content).each_with_index do |paragraph, index|
    return index if paragraph == any_paragraph
  end
  0
end


get "/search" do
	word = params[:query]
	if !word.nil?
		@successful_request_chapters = matching_chapters(word)
	end
	erb :search
end
