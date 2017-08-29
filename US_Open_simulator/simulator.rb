require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"

require "pry"

configure do
	enable :sessions
end

semi_finalists ||= []
finalists ||= []
winner ||= ""

helpers do
	def rank(number)
		case number
		when "1" then "1st"
		when "2" then "2nd"
		when "3" then "3rd"
		when "4" then "4th"
		end
	end

	def last_name(player)
		player.split.last.downcase
	end

	def image_location_of(player)
		name = last_name(player)
		"../images/#{name}.jpg"
	end

	def grand_slam_winners
		["Roger Federer", "Rafael Nadal", "Marin Cilic", "JM Del Potro"]
	end

	def info(winner)
		lines = []
		if grand_slam_winners.include?(winner)
			YAML.load_file("info/#{last_name(winner)}.yml")
		else
			{"gs_titles" => 0, "us_open_titles" => 0, "gs_titles_in_2017" => 0}
		end
	end
end

get "/" do
	semi_finalists = []
	finalists = []
	winner = ""
	erb :index
end

get "/select/:id" do
  content = YAML.load_file('players.yml')
  @id = params[:id]
  @players = content["#{rank(@id)}_quarter"]

  session[:message] = "Who will win the #{rank(@id)} quarter ?"

	erb :select
end

post "/select/:id" do
	semi_finalists << params["SM#{params[:id]}"]
	@id = (params[:id].to_i + 1).to_s

	if @id.to_i >= 5
		@id = "1"
		redirect "/semi_final/#{@id}"
	else
		redirect "/select/#{@id}"
	end
end

get "/semi_final/:id" do
	@id = params[:id]
	index = nil
	if @id.to_i == 1
		index = 0
	else
		index = 2
	end
	@semi_finalist_1 = semi_finalists[index]
	@semi_finalist_2 = semi_finalists[index + 1]
	@adress1 = image_location_of(@semi_finalist_1)
	@adress2 = image_location_of(@semi_finalist_2)
	erb :semi_finals
end

post "/select/finalist/:id" do
	finalists << params["finalist"]
	@id = params[:id]
	if @id.to_i == 1
		@id = "2"
		redirect "/semi_final/#{@id}"
	else
		redirect "/final"
	end
end

get "/final" do
	@finalist_1 = finalists[0]
	@finalist_2 = finalists[1]
	@adress1 = image_location_of(@finalist_1)
	@adress2 = image_location_of(@finalist_2)
	erb :final
end

post "/winner" do
	winner = params["winner"]
	redirect "/end"
end

get "/end" do
	@info = info(winner)
	@winner = winner
	@picture_adress = image_location_of(winner)
	erb :winner
end
