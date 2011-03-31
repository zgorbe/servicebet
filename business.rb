module ServiceBet
  module Business
    def generate_password(length=8)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
      password = ''
      length.downto(1) { |i| password << chars[rand(chars.length - 1)] }
      password
    end

    def send_email(to_address, mail_subject, mail_body)
      Pony.mail(:to => to_address, :via => :smtp, :via_options => {
        :address => 'smtp.gmail.com',
        :port => '587',
        :enable_starttls_auto => true,
        :user_name => 'epamrazor',
        :password => 'b3c4r3ful',
        :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
        :domain => "HELO", # don't know exactly what should be here
        },
        :subject => mail_subject, :body => mail_body
      )
    end
    
    # This method searches for the winner bet for an issue, updates the winner bet's status, and returns the winner's user_id
    def find_winner_user_bet(issue)
      bets = get_bets_for_month_by_condition({:priority => issue.priority, :website_id => issue.website_id, :status.not => 'WON',
                :happens_at.gt => issue.occured_at - 12*60*60, :happens_at.lt => issue.occured_at + 12*60*60, :order => [ :created_at ] })
      if bets.size > 0
        best_bet = bets[0]
        best_delta = (issue.occured_at - best_bet.happens_at).abs
        bets.each do |bet|
          delta = (issue.occured_at - bet.happens_at).abs
          if delta < best_delta
            best_bet = bet
            best_delta = delta
          end
        end
        update_winner_bet(best_bet)
        #when the issue will be saved, the bet will be updated too
        issue.bet = best_bet
        return best_bet.user_id
      end
      0
    end
    
    def update_bet_counts_if_necessary(user)
      reset_bet_counts(8, user) if user.last_login_at.month != Time.now.utc.month #first login in the current month
    end
  end
end
