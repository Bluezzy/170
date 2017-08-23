require "sinatra"
require "sinatra/reloader"
require "erubis"
require "redcarpet"

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, 'secret'
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_cotent(filepath)
	content = File.read(filepath)
	case File.extname(filepath)
	when ".txt"
		headers["Content-Type"] = "text/plain"
		File.read(filepath)
	when ".md"
		render_markdown(filepath)
	end
end

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  file_path = root + "/data/" + params[:filename]

  if File.file?(file_path)
    load_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
end