require "sinatra"
require "sinatra/reloader" # causes the application to reload files every time a page is loaded
require "tilt/erubis"

get '/' do
  @files = Dir.glob("public/*")
  @reverse = params['reverse']
  erb :files
end

get "/public/*.*"
  
end