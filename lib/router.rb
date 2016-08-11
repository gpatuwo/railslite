class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name = pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    (@pattern =~ req.path) && (@http_method.to_s.upcase == req.request_method)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = @pattern.match(req.path)
    routes_params = {}

    match_data.names.each do |name|
      routes_params[name] = match_data[name]
    end

    controller = @controller_class.new(req, res, routes_params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, http_method, controller_class, action_name)
    @routes << Route.new(pattern, http_method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    # add a Route object to Router's @routes
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    answer = @routes.select{|route| route.matches?(req)}
    answer.empty? ? nil : answer
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    # figures out what URL was requested
    # match it to the path regex of one Route object
    # asks Route to instantiate the apporpriate controller
    # calls the appropriate method
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
