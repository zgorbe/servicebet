require 'servicebet'
require 'utils/asset_cache'

use AssetCache, {
  /(\/css\/|\/images\/|\/js\/)/ =>
  { :cache_control => "max-age=86400, public"}
}

use HoptoadNotifier::Rack

run Sinatra::Application
