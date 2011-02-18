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
  @user = User.get(session[:user])
  @websites = Website.all
  @bets = get_bets_for_current_month_by_user(@user.id)
  erb :bets
end

post '/bets' do
  @bet = Bet.new(params[:bet]) if params[:bet]
  t = Time.parse(params[:happens_at])
  puts "Parsed time: " + t.to_s
  puts "utcoffset: " + t.utc_offset
  puts "To utc: " + t.utc.to_s
  puts "Getutc: " + t.getutc.to_s
  @bet.happens_at = Time.parse(params[:happens_at]).getutc if params[:happens_at] and !params[:happens_at].empty?
  @bet.created_at = Time.now.utc
  
  @user = User.get(session[:user])
  @bet.user = @user
  @websites = Website.all
  
  #only validating if the date is in the current month, later the validation will only allow bets that are in the future and at least 24 hours later
  if @bet.happens_at.nil? or @bet.happens_at.month != Time.now.utc.month
    @message = 'You can only place bets for the current month!'
  else
    if @bet.save
      user_placed_a_bet(@user, @bet.priority)
      @message = 'Your bet is successfully saved!'
    else
      @message = 'Failed to place your bet!'
    end
  end
  
  @bets = get_bets_for_current_month_by_user(@user.id)
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