require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require "byebug"

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "double render error" if already_built_response?
    @res.status = 302
    @res["Location"] = url
    @already_built_response = @res
    session.store_session(@res)
    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "double render error" if already_built_response?
    @res.write(content)
    @res['Content-Type'] =content_type
    @already_built_response = @res
    session.store_session(@res)
    nil
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = File.join(File.dirname(__FILE__), "..", "views", "#{self.class.to_s.underscore}", "#{template_name}.html.erb")
    template = File.read(path)
    result = ERB.new(template).result(binding)
    render_content(result, "text/html")

  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    
  end
end

