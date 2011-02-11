require 'rubygems'
require 'bundler'

Bundler.require(:default, :development) if development?
Bundler.require(:default, :production) if production?

require 'servicebet'
run Sinatra::Application
