module ServiceBet
  module Persistence
    def authenticate_user(username, password)
      user = User.first(:username => username)
      if user
        if Digest::MD5.hexdigest(password).eql? user.password
          user.update(:last_login_at => Time.now.utc)
          return user
        end
      end
      return nil
    end

    def update_password(user_id, password1)
      user = User.get(user_id)
      if user
        user.update(:password => Digest::MD5.hexdigest(password1), :pwd_change => false, :updated_at => Time.now.utc)
      end
      return user
    end
    
    def reset_password(user_id, new_password)
      user = User.get(user_id)
      if user
        user.update(:password => Digest::MD5.hexdigest(new_password), :pwd_change => true, :updated_at => Time.now.utc)
      end
      return user
    end
    
    def reset_bet_counts(reset_count)
      User.all.update(:p1_counts => reset_count)
      User.all.update(:p2_counts => reset_count)
    end
    
    def user_placed_a_bet(user, priority)
      if priority == 1
        user.update(:p1_counts => user.p1_counts - 1)
      elsif priority == 2
        user.update(:p2_counts => user.p2_counts - 1)
      end
    end
    
    #This method could be improved to let the db filter the bets, and not the code...
    def get_bets_for_current_month_by_user(user_id)
      year = Time.now.utc.year
      month = Time.now.utc.month
      bets = []
      bet_list = Bet.all(:user_id => user_id, :order => [ :website_id,:happens_at.desc ])
      bet_list.each do |bet|
        if bet.happens_at.year == year and bet.happens_at.month == month
          bets << bet
        end
      end
      bets
    end
  end
end
