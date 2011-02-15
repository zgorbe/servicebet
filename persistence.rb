module ServiceBet
  module Persistence
    def authenticate_user(username, password)
      user = User.first(:username => username)
      if user
        if Digest::MD5.hexdigest(password).eql? user.password
          return user
        end
      end
      return nil
    end
    def update_password(user_id, password1)
      user = User.get(user_id)
      if user
        user.update(:password => Digest::MD5.hexdigest(password1), :pwd_change => false, :updated_at => Time.now)
      end
      return user
    end
  end
end
