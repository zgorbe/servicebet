require 'rubygems'
require 'sinatra'
require 'newrelic_rpm'
require 'dm-core'
require 'do_mysql' if development?
require 'do_postgres' if production?
require 'authorization'
require 'persistence'
require 'business'
require 'partials'
require 'sinatra/reloader' if development?
require 'hoptoad_notifier'

enable :sessions

configure :development, :test do |config|
  DataMapper.setup(:default, 'mysql://root@localhost:3306/servicebet?encoding=UTF-8')
  DataObjects::Mysql.logger = DataObjects::Logger.new(STDOUT,0)
  config.also_reload "models.rb"
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] + '?encoding=UTF-8')
end

HoptoadNotifier.configure do |config|
  config.api_key = 'b471baf164d04c4a3f4d0bf276444163908b008c'
end

load 'models.rb'
load 'controller.rb'
load 'admin.rb'

error do
  exception = request.env['sinatra.error']
  HoptoadNotifier.notify exception
end

helpers do
  include ServiceBet::Persistence
  include ServiceBet::Business
  include Sinatra::Authorization
  include Rack::Utils
  include Sinatra::Partials

  alias_method :h, :escape_html

  def format_date(date)
    date.strftime('%Y-%m-%d %H:%M')
  end
end
