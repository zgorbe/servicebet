module ServiceBet
  module Business
    def generate_password(length=8)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
      password = ''
      length.downto(1) { |i| password << chars[rand(chars.length - 1)] }
      password
    end
  end
end
