require 'servicebet'
require 'utils/asset_cache'
require 'hoptoad_notifier'

use AssetCache, {
  /(\/css\/|\/images\/|\/js\/)/ =>
  { :cache_control => "max-age=86400, public"}
}

HoptoadNotifier.configure do |config|
  config.api_key = 'b471baf164d04c4a3f4d0bf276444163908b008c'
end

use HoptoadNotifier::Rack

run Sinatra::Application
