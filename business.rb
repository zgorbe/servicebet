module ServiceBet
  module Business
    def generate_password(length=8)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
      password = ''
      length.downto(1) { |i| password << chars[rand(chars.length - 1)] }
      password
    end

    def send_email(to_address, mail_body)
      Pony.mail(:to => to_address, :via => :smtp, :via_options => {
        :address => 'smtp.gmail.com',
        :port => '587',
        :enable_starttls_auto => true,
        :user_name => 'epamrazor',
        :password => 'Ep4mR4z0r',
        :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
        :domain => "HELO", # don't know exactly what should be here
        },
        :subject => 'Invite to ServiceBet', :body => mail_body
      )
    end
    
    def get_winner_user_id(issue)
      bets = get_bets_for_current_month_by_condition({:priority => issue.priority, :website_id => issue.website_id, :order => [ :created_at ] })
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
        #only if the best bet is closer than 12 hours
        if best_delta < (12 * 60 * 60)
          return best_bet.user_id
        end
      end
      0
    end
  end
end
