require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash

  attr_reader :cookie
  def initialize(req)
    #req is instance of Rack::Request
    @req = req
    # need to grab _rails_lite_app cookie
    cookie = @req.cookies["_rails_lite_app"]
    # has cookie been set?
    if cookie
      # use JSON to deserialize value of cookie
      # store it in an ivar
      @cookie = JSON.parse(cookie)
    else
      # if not, then ivar set to {}
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    attributes = {}
    attributes[:path] = "/"
    attributes[:value] = @cookie.to_json
    res.set_cookie("_rails_lite_app", attributes)
  end
end
