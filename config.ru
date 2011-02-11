require 'rubygems'
require 'bundler'

Bundler.setup(:default, ENV['RACK_ENV'].to_sym)

require 'servicebet'
run Sinatra::Application
