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
  @bets = get_bets_for_month_by_condition({:user_id => @user.id, :order => [ :website_id,:happens_at.desc ]})
  erb :bets
end

post '/bets' do
  @bet = Bet.new(params[:bet]) if params[:bet]
  t = Time.parse(params[:happens_at] + " UTC") if params[:happens_at] and !params[:happens_at].empty?
  if t
    @bet.happens_at = t
    #offset = t.utc_offset
    #t2 = t.utc
    #@bet.happens_at = t2 + offset
    #puts "Time.now.utc: " + Time.now.utc.to_s
    puts "Parsed time: " + t.to_s
    #puts "utcoffset: " + offset.to_s
    #puts "To utc: " + t.utc.to_s
    #puts "Getutc: " + t.getutc.to_s
    #puts "Bet.happens_at: " + @bet.happens_at.to_s
  end
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
  
  @bets = get_bets_for_current_month_by_condition({:user_id => @user.id, :order => [ :website_id,:happens_at.desc ]})
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
      #update_bets_if_necessary()
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

get "/hoptoad" do
  raise "Test hoptoad error"
end