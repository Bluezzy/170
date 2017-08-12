require "sinatra"
require "sinatra/reloader"
require 'pry'
require 'yaml'

before do
  @users = YAML.load_file("data/users.yaml")
  @nb_of_users = @users.count
  @nb_of_interests = count_interests(@users)
end

helpers do
  def count_interests(data_users)
    result = 0
    data_users.each do |_, properties|
      result += properties[:interests].count
    end
    result
  end
end

get "/" do
  redirect to('/users/')
end

get "/users/" do
  erb :users
end

get "/users/:name" do
  @name = params[:name]
  @interests = @users[@name.to_sym][:interests]
  @email = @users[@name.to_sym][:email]
  erb :user
end

get "/display/" do
  @users.to_s
end
