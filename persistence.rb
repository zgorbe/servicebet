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
    
    #This method returns the bets that are created in the current month
    def get_bets_for_current_month_by_condition(condition)
      year = Time.now.utc.year
      month = Time.now.utc.month
      t1 = Time.parse(Date.new(year, month, 1).to_s + " 00:00:00 UTC")
      t2 = Time.parse(Date.new(year, month, -1).to_s + " 23:59:59 UTC")
      condition[:created_at.gt] = t1
      condition[:created_at.lt] = t2
      Bet.all(condition)
    end
    
    def user_bet_won(user_id)
      user = User.get(user_id)
      if user
        user.update(:bet_balance => user.bet_balance + 1)
      end
    end
    
    def update_winner_bet(bet)
      bet.update(:status => 'WINNED')
    end

    def update_bets_if_necessary()
      #Select all bets which are 'older' than 12 hours, these can't impacted by a future issue anymore
      pending_bets = Bet.all(:status => 'NEW', :happens_at.lt => Time.now - 12*60*60)
      pending_bets.each do | bet |
        puts " *** Pending #{bet.id}"
      end

      #select b.* from issues i, bets b
      #where b.happens_at > i.occured_at - 12*60*60
      #and b.happens_at < i.occured_at + 12*60*60
      #order by abs(b.happens_at - i.occured_at)

      #What if nobody logs in for 24 hours?
      last_24h_issues = Issue.all(:occured_at.gt => Time.now - 60*60*24)

      winner_bet_ids = []

      #Go through on every issue in the last 24 hour and search for bets in their 24-hour range
      #with the same priority and website
      last_24h_issues.each do |issue|
        bets_in_range = Bet.all(:status => 'NEW',
                            :priority => issue.priority,
                            :website => issue.website,
                            :happens_at.gt => issue.occured_at - 12*60*60,
                            :happens_at.lt => issue.occured_at + 12*60*60
                           )
        bets_in_range.each {|b| puts " in range #{b.id}"} if bets_in_range
        
        #Check which is the closest bet to the current issue
        winner = bets_in_range.min {|a,b| (a.happens_at - issue.occured_at).abs <=> (b.happens_at - issue.occured_at).abs}
        puts " *** WINNER!!!! #{issue.id} --> #{winner.id}" if winner

        #We found a winner, let's store it's ID
        winner_bet_ids << winner.id

        #TODO how we will attached the winner bet to the issue? Should this done here?
      end

      puts "WINNER bet ids: #{winner_bet_ids.inspect}"

      #Go through on bets and set all of them to WINNED or LOST in the database
      pending_bets.each do |bet|
        puts " *** status #{bet.id} -> #{bet.status}"
        if winner_bet_ids.include? bet.id
          bet.update(:status => 'WINNED')
        else
          bet.update(:status => 'LOST')
        end
      end

    end
  end
end
