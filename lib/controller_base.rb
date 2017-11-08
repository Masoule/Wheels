require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
  end

  def already_built_response?
    @already_built_response ||= false
  end

  def redirect_to(url)
    raise "double render!" if already_built_response?
    @res["Location"] = url
    @res.status = 302
    @already_built_response = true
    session.store_session(@res)
  end

  def render_content(content, content_type)
    raise "double render!" if already_built_response?
    @res.write(content)
    @res["Content-Type"] = content_type
    @already_built_response = true
    session.store_session(@res)
  end

  def render(template_name)
    folder_name = self.class.to_s.underscore
    file_path = "views/#{folder_name}/#{template_name}.html.erb"
    file = File.read(file_path)
    content = ERB.new(file).result(binding)
    render_content(content, "text/html")
  end

  def session
    @session ||= Session.new(req)
  end

  def invoke_action(action)
    send(action)
    render(action) unless @already_built_response
  end
end
