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
  
  has n, :bets
  has n, :issues
end

class Website
  include DataMapper::Resource
  
  property :id,            Serial
  property :name,          String, :unique_index => true
  property :created_at,    Time
  
  has n, :issues
  has n, :bets
end

class Issue
  include DataMapper::Resource
  
  property :id,            Serial
  property :priority,      Integer
  property :occured_at,    Time
  property :created_at,    Time
  property :description,   Text
  
  belongs_to :website
  belongs_to :user #, :required => false
  has 1, :bet
end

class Bet
  include DataMapper::Resource
  
  property :id,            Serial
  property :priority,      Integer
  property :happens_at,    Time
  property :created_at,    Time
  property :status,        String, :default => 'NEW' #NEW, WON, LOST
  
  belongs_to :website
  belongs_to :user
  belongs_to :issue
end

DataMapper.auto_upgrade!
