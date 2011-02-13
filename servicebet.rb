require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'do_mysql' if development?
require 'do_postgres' if production?
require 'authorization'
require 'persistence'
require 'business'
require 'partials'
require 'sinatra/reloader' if development?

enable :sessions

configure :development, :test do |config|
  DataMapper.setup(:default, 'mysql://root@localhost:3306/servicebet?encoding=UTF-8')
  DataObjects::Mysql.logger = DataObjects::Logger.new(STDOUT,0)
  config.also_reload "models.rb"
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] + '?encoding=UTF-8')
end

load 'models.rb'
load 'controller.rb'
load 'admin.rb'

helpers do
  include ServiceBet::Persistence
  include ServiceBet::Business
  include Sinatra::Authorization
  include Rack::Utils
  include Sinatra::Partials

  alias_method :h, :escape_html

  def format_date(date)
    time = date.utc + (60 * 60 * 2)
    time.strftime('%Y-%m-%d %H:%M')
  end
end
