require 'erb'

get "/" do
  redirect request.url + "servicebets"
end

get "/servicebets" do
  "Welcome to Service Bet!"
end
