class AssetCache
  def initialize app, hash
    @app = app
    @hash = hash
  end

  def call env
    res = @app.call(env)
    path = env["REQUEST_PATH"]
    @hash.each do |pattern, data|
      if path =~ pattern
        if data.has_key?(:cache_control)
          res[1]["Cache-Control"] = data[:cache_control]
        end
        if data.has_key?(:expires)
          res[1]["Expires"] = (Time.now + data[:expires]).rfc2822
        end
        return res
      end
    end
    res
  end
end
