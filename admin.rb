require 'digest/md5'

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
  @user.last_login_at = Time.now.utc
  @user.created_at = Time.now.utc
  @user.updated_at = Time.now.utc
  
  if @user.save and params[:send_invite]
     send_email(@user.email, erb(:invite, :layout => false))
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
  redirect "/admin"
end

post "/admin/user/reset/:id" do
  @user = User.get(params[:id])
  if @user
    @password = generate_password
    if reset_password(@user.id, @password)
      send_email(@user.email, erb(:reset_password, :layout => false))
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
  @website.created_at = Time.now.utc
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
  redirect "/admin"
end

get "/admin/newissue" do
  @issue = Issue.new
  @websites = Website.all
  erb :editissue
end

post "/admin/issues" do
  @issue = Issue.new(params[:issue]) if params[:issue]
  @issue.occured_at = Time.parse(params[:occured_at]) if params[:occured_at]
  @issue.created_at = Time.now.utc
  
  if @issue.occured_at < @issue.created_at
    @message = "Issue start date can't be in the future!"
    @websites = Website.all
    erb :editissue
  else
    @issue.user_id = get_winner_user_id  #we need to find out how to do this, or we can just ignore this field, if we think it's unnecessary
  
    if @issue.save
      redirect "/admin/issues"
    else
      @message = "Failed to save issue!"
      @websites = Website.all
      erb :editissue
    end
  end
end

get "/admin/issues" do
  @issues = Issue.all
  erb :adminissues
end

get "/admin/resetcounts" do
  erb :adminresetcounts
end

post '/admin/resetcounts' do
  reset_count = params[:reset_count] || 8
  reset_bet_counts(reset_count)
  redirect "/admin"
end