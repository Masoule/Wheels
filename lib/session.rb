require 'json'
require 'byebug'

class Session
  def initialize(req)
    if req.cookies["_my_rails_app"]
      @cookie = JSON.parse(req.cookies["_my_rails_app"])
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  def store_session(res)
    res.set_cookie("_my_rails_app", {path:"/" , value: @cookie.to_json})
    res.finish
  end
end
