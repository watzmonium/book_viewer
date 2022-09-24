require "sinatra"
require "sinatra/reloader" if development? # causes the application to reload files every time a page is loaded
require "tilt/erubis"
require 'digest/bubblebabble'

before do
  @table_of_contents = IO.readlines('data/toc.txt')
  @chapter_list = populate_list(@table_of_contents)
end

helpers do
  def populate_list(table)
    (1..table.size).each_with_object({}) do |num, hsh|
      hsh[num] = {title: table[num - 1]}
    end
  end

  def in_paragraphs(text)
    text.split(/\n\n/).map do |paragraph|
      "<p id='#{hsh_value(paragraph)}'>#{paragraph}</p>"
    end.join
  end

  def display_table(table)
    tab = ''
    table.each do |ch_num, sub_info|
      tab += '<li class="pure-menu-item">'
      tab += "<a href='/chapters/#{ch_num}'"
      tab += "class='pure-menu-link'>#{table[ch_num][:title].rstrip}</a></li>"
    end
    tab
  end

  def display_results(data)
    search_results = '<ul>'
    data.each do |ch_num, sub_info|
      search_results += "<li><h4>#{sub_info[:title]}</h4></li><ul>"
      search_results += generate_links(ch_num, sub_info[:ids])
      search_results += "</ul>"
    end
    search_results += "</ul>"
  end
  
  def generate_links(ch_num, sets)
    search_results = ''
    sets.each_with_object('') do |set|
      set.each do |id, text|
        search_results += "<li>"
        search_results += "<a href='/chapters/#{ch_num}##{id}'>#{text}"
        search_results += "</a></li>"
      end
    end
    search_results
  end

  def search_term(value, size)
    chapters = {}
    1.upto(size) do |num|
      text = File.read("data/chp#{num}.txt")
      if text.match?(/#{value}/i)
        chapters[num] = {title: @table_of_contents[num - 1], ids: nil}
        chapters[num][:ids] = find_paragraphs(text, value)
      end
    end
    chapters
  end

  def find_paragraphs(text, word)
    text.split(/\n\n/).each_with_object([]) do |paragraph, ids|
      if paragraph.match?(/#{word}/i)
        p = paragraph.gsub(/#{word}/i, "<strong>#{word}</strong>")
        ids << {hsh_value(paragraph) => p}
      end
    end
  end

  def show_search(data, query)
    matches = ''
    if data.nil?
      return
    elsif data.empty?
      matches = "<h2 class='content-subhead'>Sorry, no results were found.</h2>"
    else
      matches += "<h2 class='content-subhead'>Results for '#{query}'</h2>"
      matches += display_results(data)
    end
    matches
  end

  def hsh_value(value)
    Digest::SHA256.bubblebabble(value)
  end
end


get "/" do # `get` is a sinatra command that tells the server what to do with a get req at that path?
  #@name = 'burt' # get creates a binding passed through erb to the page in question.
                 # why does it need to be an instance variable? it's not really a binding then!
                 # this is some kind of hidden class mechanic
  @title = "Table of Contents"
  erb :home # with sinatra, opening the file is enough to have it work with your server
end

get "/chapters/:number" do
  @number = params['number']
  pass unless @number.match(/[\d]+/)
  pass unless @number.to_i <= @table_of_contents.size
  #redirect "/" unless (1..@contents.size).cover? number
  @title = "Chapter #{@number}: #{@table_of_contents[@number.to_i - 1]}"
  @text = File.read("data/chp#{@number}.txt")
  erb :text
end

get "/search" do
  @term = params['query']
  @locations = search_term(@term, @table_of_contents.size) unless @term.nil?
  @title = "Search"
  erb :search
end

not_found do
  redirect "/"
end