require 'erb'

get "/" do
  redirect request.url + "accounts"
end

get "/servicebets" do
  "Welcome to Service Bet!"
end
