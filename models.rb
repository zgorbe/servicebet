class User
  include DataMapper::Resource

  property :id,            Serial
  property :username,      String, :unique_index => true
  property :first_name,    String
  property :last_name,     String
  property :password,      String
  property :email,         String
  property :pwd_change,    Boolean, :default => true
  property :p1_counts,     Integer, :default => 0
  property :p2_counts,     Integer, :default => 0
  property :bet_balance,   Integer, :default => 0
  property :last_login_at, Time
  property :created_at,    Time
  property :updated_at,    Time
end

DataMapper.auto_upgrade!