# require './route.rb'

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action)
    @routes << Route.new(pattern, method, controller_class, action)
  end

  methods = [:get, :post, :put, :delete]
  methods.each do |method|
    define_method(method) do |pattern, controller_class, action|
      add_route(pattern, method, controller_class, action)
    end
  end

  def match(req)
    @routes.find { |route| route.matches?(req) }
  end

  def run(req, res)
    matched_route = match(req)
    matched_route ? matched_route.run(req, res) : res.status = 404
  end

  def draw(&block)
    instance_eval(&block)
  end

end

class Route
  attr_reader :pattern, :http_method, :controller_class, :action

  def initialize(pattern, http_method, controller_class, action)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action = action
  end


  def matches?(req)
    req_method = req.request_method.downcase.to_sym
    http_method == req_method && pattern =~ req.path
  end

  def run(req, res)
    match_data = @pattern.match(req.path)
    route_params = Hash[match_data.names.zip(match_data.captures)]

    @controller_class.new(req, res, route_params)
    .invoke_action(action)
  end
end
