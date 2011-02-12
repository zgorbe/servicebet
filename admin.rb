before '/admin/?*' do
  require_administrative_privileges
end

get "/admin" do
  erb :admin
end
