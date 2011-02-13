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

get "/logout" do
  redirect "/login"
end

get "/email" do
  Pony.mail(:to => 'gzolee@gmx.net', :via => :smtp, :via_options => {
    :address => 'smtp.gmail.com',
    :port => '587',
    :enable_starttls_auto => true,
    :user_name => 'epamrazor',
    :password => 'Ep4mR4z0r',
    :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain => "HELO", # don't know exactly what should be here
    },
    :subject => 'Invite to ServiceBet', :body => erb(:invite, :layout => false)
  ) 
end