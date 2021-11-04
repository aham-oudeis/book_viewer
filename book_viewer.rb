require "sinatra"
require "sinatra/reloader" if development?
require 'tilt/erubis'

before do 
  @list_of_contents = File.readlines "data/toc.txt"
end

helpers do 
  def slugify(text)
    text.downcase.gsub(/\s+/, "-").gsub(/[^\w-]/, "")
  end

  def in_paragraphs(text)
    text.split("\n\n")
  end

  def each_chapter
    @list_of_contents.each_with_index do |chapter, idx|
      number = idx + 1
      contents = File.read "data/chp#{number}.txt"

      yield chapter, number, contents
    end
  end

  def matching_chapters(query)
    results = []

    return results if !query || query.empty?

    each_chapter do |chapter, number, contents|
      if contents.include? query
        contents_list = contents.split("\n\n")
        results << {number: number, chapter: chapter, contents_list: contents_list}
      end
    end

    results
  end

  def bold_matching(para, match)
    para.gsub(match, "<strong>#{match}</strong>")
  end
end

not_found do 
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Homes"

  erb :home
end

get "/chapters/:name" do  
  chapter_index = params['name'].to_i - 1
  chapter_index = 0 unless (0..@list_of_contents.size).include?(chapter_index)

  chapter_name = @list_of_contents[chapter_index]
  @title = "Chapter #{chapter_index + 1}: #{chapter_name}"
  @heading = chapter_name

  @chapter = File.read "data/chp#{chapter_index + 1}.txt"
  
  erb :chapter 
end

get "/search" do
  @title = "search"
  @heading = "Search"

  @search_result = matching_chapters(params[:query])

  erb :search
end
