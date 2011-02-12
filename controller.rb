require 'erb'

before '/admin/?*' do
  authorized = require_administrative_privileges
  session[:user] = 666 if authorized  #admin user_id is 666 ;)
  authorized
end

before do
  unless request.path_info.eql? '/login'
    if session[:user].nil? 
      redirect "/login"
    end
  end
  true
end

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

get "/login" do
  session[:user] = nil
  erb :login, :layout => :layout_login
end