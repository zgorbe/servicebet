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
    
    def reset_bet_counts(reset_count, user=nil)
      if user
        user.update(:p1_counts => reset_count)
        user.update(:p2_counts => reset_count)
      else
        User.all.update(:p1_counts => reset_count)
        User.all.update(:p2_counts => reset_count)
      end
    end
    
    def user_placed_a_bet(user, priority)
      if priority == 1
        user.update(:p1_counts => user.p1_counts - 1)
      elsif priority == 2
        user.update(:p2_counts => user.p2_counts - 1)
      end
    end
    
    #This method returns the bets that are created in the current month
    #if year and month is not passed, then the current year and month is used
    def get_bets_for_month_by_condition(condition={}, year=Time.now.utc.year, month=Time.now.utc.month)
      t1 = Time.parse(Date.new(year, month, 1).to_s + " 00:00:00 UTC")
      t2 = Time.parse(Date.new(year, month, -1).to_s + " 23:59:59 UTC")
      condition[:created_at.gt] = t1
      condition[:created_at.lt] = t2
      Bet.all(condition)
    end
    #The same as the above method, just for issues
    def get_issues_for_month_by_condition(condition={}, year=Time.now.utc.year, month=Time.now.utc.month)
      t1 = Time.parse(Date.new(year, month, 1).to_s + " 00:00:00 UTC")
      t2 = Time.parse(Date.new(year, month, -1).to_s + " 23:59:59 UTC")
      condition[:occured_at.gt] = t1
      condition[:occured_at.lt] = t2
      Issue.all(condition)
    end
    
    def user_bet_won(user_id)
      @user = User.get(user_id)
      if @user
        @user.update(:bet_balance => @user.bet_balance + 1)
      end
      send_email(@user.email, 'You won!', erb(:congrats, :layout => false))
    end
    
    def update_winner_bet(bet)
      bet.update(:status => 'WON')
    end
    
    def update_last_login(user)
      user.update(:last_login_at => Time.now.utc)
    end
    
    def update_outdated_bets()
      #Select all bets which are 'older' than 12 hours, these can't impacted by a future issue anymore
      pending_bets = Bet.all(:status => 'NEW', :happens_at.lt => Time.now - 12*60*60)
      pending_bets.each do | bet |
        puts "Setting bet (#{bet.id}) status to LOST"
        bet.update(:status => 'LOST')
      end
    end
    
    def get_latest_issues
      Issue.all(:order => [:occured_at.desc], :limit => 5)
    end
    
    def get_stats_issues_by_priority(priority)
      #results = repository(:default).adapter.query("SELECT w.name, count(i.website_id) as occurance FROM websites w left join issues i on website_id=w.id WHERE (priority = #{priority} or priority is null) GROUP BY w.id, w.name ORDER BY w.id")
      results = repository(:default).adapter.query("SELECT w.name, count(i.website_id) as occurance FROM websites w left join issues i on website_id=w.id and i.priority = #{priority} GROUP BY w.id, w.name ORDER BY w.id")
      names_list = []
      counts_list = []
      results.each do |item|
        names_list << item[:name]
        counts_list << item[:occurance]
      end
      { :names => names_list, :counts => counts_list }
    end

    def get_stats_bets_by_priority(priority)
      #results = repository(:default).adapter.query("SELECT w.name, count(*) as occurance FROM bets b inner join websites w on website_id=w.id WHERE priority = #{priority} GROUP BY website_id, w.name ORDER BY website_id")
      results = repository(:default).adapter.query("SELECT w.name, count(b.website_id) as occurance FROM websites w left join bets b on website_id=w.id and b.priority = #{priority} GROUP BY w.id, w.name ORDER BY w.id")      
      names_list = []
      counts_list = []
      results.each do |item|
        names_list << item[:name]
        counts_list << item[:occurance]
      end
      { :names => names_list, :counts => counts_list }
    end

  end
end
