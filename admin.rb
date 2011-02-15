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
    Pony.mail(:to => @user.email, :via => :smtp, :via_options => {
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
  redirect "/admin/users"
end

get "/admin/users" do
  erb :adminusers
end