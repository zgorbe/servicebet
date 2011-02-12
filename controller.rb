require 'erb'

get "/" do
  redirect request.url + "home"
end

get "/home" do
  erb :home
end

get "/bets" do
  erb :bets
end

get "/issues" do
  erb :issues
end

get "/members" do
  erb :users
end

get "/top" do
  erb :top
end