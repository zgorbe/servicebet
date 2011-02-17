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
    
    def get_winner_user_id
      0
    end
  end
end
