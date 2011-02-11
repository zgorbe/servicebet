require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'do_mysql' if development?
require 'do_postgres' if production?
require 'authorization'
require 'partials'
require 'sinatra/reloader' if development?

load 'models.rb'
load 'controller.rb'

configure :development, :test do
  DataMapper.setup(:default, 'mysql://root@localhost:3306/servicebet?encoding=UTF-8')
  DataObjects::Mysql.logger = DataObjects::Logger.new(STDOUT,0)
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] + '?encoding=UTF-8')
end


helpers do
  include Sinatra::Authorization
  include Rack::Utils
  include Sinatra::Partials

  alias_method :h, :escape_html

  def format_date(date)
    time = date.utc + (60 * 60 * 2)
    time.strftime('%Y-%m-%d %H:%M')
  end
end
