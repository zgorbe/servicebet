require 'erb'
require 'pony'

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
  @user = User.get(session[:user])
  @websites = Website.all
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

post "/login" do
  if params[:username] and params[:password]
    user = authenticate_user(params[:username], params[:password])
    if user.nil?
      erb :login, :layout => :layout_login
    else
      session[:user] = user.id
      session[:pwd_change] = user.pwd_change
      redirect "/home"
    end
  else
    erb :login, :layout => :layout_login
  end
  
end

get "/logout" do
  redirect "/login"
end

post "/pwdchange" do
  if params[:password1] and params[:password2]
    if params[:password1].eql? params[:password2] and params[:password1].length > 6
      user = update_password(session[:user], params[:password1])
      if user
        session[:pwd_change] = user.pwd_change
      end
    end
  end
  redirect "/home"
end