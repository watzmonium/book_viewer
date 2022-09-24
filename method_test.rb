require 'digest/bubblebabble'
require 'pry'

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
      search_results += "<a href='/chapters/#{ch_num}##{id}>#{text}</a>"
      search_results += "</li>"
    end
  end
  search_results
end

def search_term(value, size, table_of_contents)
  chapters = {}
  1.upto(size) do |num|
    text = File.read("data/chp#{num}.txt")
    if text.match?(/#{value}/i)
      chapters[num] = {title: table_of_contents[num - 1], ids: nil}      
      chapters[num][:ids] = find_paragraphs(text, value)
    end
  end
  chapters
end

def find_paragraphs(text, word)
  text.split(/\n\n/).each_with_object([]) do |paragraph, ids|
    if paragraph.match?(/#{word}/i)
      ids << {hsh_value(paragraph) => paragraph}
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

table_of_contents = IO.readlines('data/toc.txt')
term = 'mystery'
locations = search_term(term, table_of_contents.size, table_of_contents) unless term.nil?
a = show_search(locations, term)
p a