require 'compass'
require 'sinatra'
require 'haml'

ENV['LIBROOT'] = "#{Dir.pwd}/../"

$:.push("#{Dir.pwd}/../")
require 'init'

configure do
  set :haml, {:format => :html5, :escape_html => false}
  set :scss, {:style => :compact, :debug_info => false}
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}" ) 
end

get '/' do
  @instructions = Instruction.all
  haml :index
end
