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
    puts "Delete user #{user.username}"
    user.destroy
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