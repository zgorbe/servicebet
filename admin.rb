require 'digest/md5'
require 'pony'

get "/admin" do
  erb :admin
end

get "/admin/newuser" do
  @user = User.new
  erb :edituser
end

post "/admin/users" do
  @user = User.new(params[:user]) if params[:user]
  @password = generate_password
  puts "User created: #{@user.username} - #{@password}"
  @user.password = Digest::MD5.hexdigest(@password)
  @user.last_login_at = Time.now
  @user.created_at = Time.now
  @user.updated_at = Time.now
  
  if @user.save and params[:send_invite]
     send_email(@user.email, 'Invite to ServiceBet', erb(:invite, :layout => false))
  end
  redirect "/admin/users"
end

get "/admin/users" do
  @users = User.all
  erb :adminusers
end

delete "/admin/user/:id" do
  user = User.get(params[:id])
  if user
    begin
      puts "Delete user #{user.username}"
      user.destroy
    rescue
      puts "Shit delete!"
    end
  end  
  redirect "/admin/users"
end

post "/admin/user/reset/:id" do
  @user = User.get(params[:id])
  if @user
    @password = generate_password
    if reset_password(@user.id, @password)
      send_email(@user.email, 'Password reset', erb(:reset_password, :layout => false))
    end

  end
  redirect "/admin/users"
end

get "/admin/newwebsite" do
  @website = Website.new
  erb :editwebsite
end

post "/admin/websites" do
  @website = Website.new(params[:website]) if params[:website]
  @website.created_at = Time.now
  if @website.save
    redirect "/admin/websites"
  else
    @message = "Failed to save website!"
    erb :editwebsite
  end
end

get "/admin/websites" do
  @websites = Website.all
  erb :adminwebsites
end

delete "/admin/websites/:id" do
  website = Website.get(params[:id])
  if website
    begin
      puts "Delete website #{website.name}"
      website.destroy
    rescue
      puts "Shit delete!"
    end
  end  
  redirect "/admin/websites"
end

get "/admin/newissue" do
  @issue = Issue.new
  @websites = Website.all
  @edit = false
  erb :editissue
end

post "/admin/issues" do
  @issue = Issue.new(params[:issue]) if params[:issue]
  t = Time.parse(params[:occured_at]) if params[:occured_at] and !params[:occured_at].empty?
  if t
    @issue.occured_at = t
    puts "Issue occured at: " + t.to_s
  end
  
  @issue.created_at = Time.now
  
  if @issue.occured_at 
    if (@issue.occured_at <=> @issue.created_at) == 1
      @message = "Issue start date can't be in the future!"
      @websites = Website.all
      erb :editissue
    else
      @issue.user_id = find_winner_user_bet(@issue)
      user_bet_won(@issue.user_id)  if @issue.user_id > 0

      if @issue.save
        redirect "/admin/issues"
      else
        @message = "Failed to save issue!"
        @websites = Website.all
        erb :editissue
      end
    end
  else
    @message = "Please select a start date!"
    @websites = Website.all
    erb :editissue
  end
end

get "/admin/issues" do
  @viewingfilter = params[:viewingfilter] || '1'

  if @viewingfilter.eql? '1'
    @issues = get_issues_for_month_by_condition({:order => [ :occured_at.desc ]})
  else
    date_info = @viewingfilter.split('-')
    @issues = get_issues_for_month_by_condition({:order => [ :occured_at.desc ]}, date_info[0].to_i, date_info[1].to_i)
  end

  (request.xhr?) ? (partial :adminissuesp) : (erb :adminissues)
end

get "/admin/issues/:id" do
  @issue = Issue.get(params[:id])
  @websites = [@issue.website]
  @edit = true
  erb :editissue
end

put "/admin/issues/:id" do
  @issue = Issue.get(params[:id])
  #There is an unnecessary update if the field is intact
  if @issue.update(:description => params[:issue][:description])
    redirect "/admin/issues"
  else
    @message = "Failed to update issue"
    erb :editissue
  end

end

get "/admin/resetcounts" do
  erb :adminresetcounts
end

post '/admin/resetcounts' do
  reset_count = params[:reset_count] || 8
  reset_bet_counts(reset_count)
  redirect "/admin"
end

get "/admin/bets" do
  @viewingfilter = params[:viewingfilter] || '1'
  if @viewingfilter.eql? '1'
    @bets = get_bets_for_month_by_condition({:order => [ :user_id.desc,:website_id,:happens_at.desc ]})
  else
    date_info = @viewingfilter.split('-')
    @bets = get_bets_for_month_by_condition({:order => [ :user_id.desc,:website_id,:happens_at.desc ]}, date_info[0].to_i, date_info[1].to_i)
  end

  (request.xhr?) ? (partial :adminbetsp) : (erb :adminbets)
end

delete "/admin/bets/:id" do
  bet = Bet.get(params[:id])
  if bet
    begin
      bet.destroy
    rescue
      puts "Shit delete!"
    end
  end  
  redirect "/admin/bets"
end
