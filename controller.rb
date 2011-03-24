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
  @issues = get_latest_issues
  erb :home
end

get "/bets" do
  @user = User.get(session[:user])
  @websites = Website.all
  @viewingfilter = params[:viewingfilter] || '1'
  if @viewingfilter.eql? '1'
    @bets = get_bets_for_month_by_condition({:user_id => @user.id, :order => [ :website_id,:happens_at.desc ]})
  else
    date_info = @viewingfilter.split('-')
    @bets = get_bets_for_month_by_condition({:user_id => @user.id, :order => [ :website_id,:happens_at.desc ]}, date_info[0].to_i, date_info[1].to_i)
  end
  
  (request.xhr?) ? (partial :betspartial) : (erb :bets)
end

post '/bets' do
  @bet = Bet.new(params[:bet]) if params[:bet]
  t = Time.parse(params[:happens_at] + " UTC") if params[:happens_at] and !params[:happens_at].empty?
  if t
    @bet.happens_at = t
  end
  @bet.created_at = Time.now.utc
  
  @user = User.get(session[:user])
  @bet.user = @user
  @websites = Website.all
  
  #only validating if the date is in the current month, later the validation will only allow bets that are in the future and at least 24 hours later
  if @bet.happens_at.nil? 
    @message = 'Please set the start time of the issue!'
  elsif (@bet.happens_at - Time.now.utc) < (12 * 60 * 60)
    @message = 'You can place bets only later than 12 hours!'
  elsif @bet.happens_at.month != Time.now.utc.month
    @message = 'You can only place bets for the current month!'
  else
    @bet.issue_id = 0
    if @bet.save
      user_placed_a_bet(@user, @bet.priority)
      @message = 'Your bet is successfully saved!'
    else
      @message = 'Failed to place your bet!'
    end
  end
  
  @bets = get_bets_for_month_by_condition({:user_id => @user.id, :order => [ :website_id,:happens_at.desc ]})
  erb :bets  
end

get "/issues" do
  @user = User.get(session[:user])

  @viewingfilter = params[:viewingfilter] || '1'
  if @viewingfilter.eql? '1'
    @issues = get_issues_for_month_by_condition({:order => [ :occured_at.desc ]})
  else
    date_info = @viewingfilter.split('-')
    @issues = get_issues_for_month_by_condition({:order => [ :occured_at.desc ]}, date_info[0].to_i, date_info[1].to_i)
  end

  (request.xhr?) ? (partial :issuespartial) : (erb :issues)
end

get "/issues/:id" do
  @user = User.get(session[:user])
  @issue = Issue.get(params[:id])
  if @issue
    erb :issue
  else
    redirect "/issues"
  end
end

get "/members" do
  @users = User.all(:order => [ :username.desc ])
  erb :users
end

get "/members/toplist" do
  @users = User.all(:order => [ :username.desc ])
  names_list = []
  counts_list = []
    @users.each do |user|
      names_list << user.username
      counts_list << user.bet_balance
  end
  @names_counts = { :names => names_list, :counts => counts_list }
  erb :stats_users, :layout => false
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
      update_bet_counts_if_necessary(user)
      update_last_login(user)
      update_outdated_bets()
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

get "/stats" do
  stats = params[:stats] || nil
  if stats
    if stats.eql? 'issues'
      @names_p1_counts = get_stats_issues_by_priority(1)
      @names_p2_counts = get_stats_issues_by_priority(2)
      erb :stats_issues, :layout => false
    elsif stats.eql? 'bets'
      @names_p1_counts = get_stats_bets_by_priority(1)
      @names_p2_counts = get_stats_bets_by_priority(2)
      erb :stats_bets, :layout => false
    end
  else
    erb :stats
  end
end

get "/hoptoad" do
  raise "Test hoptoad error"
end
