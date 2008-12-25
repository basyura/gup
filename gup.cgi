#!/usr/local/bin/ruby -Ku

require 'cgi'
require 'cgi/session'
require 'cgi/session/pstore'
require 'erb'

CONTROLLER_PATH = "app/controllers/"
VIEW_PATH       = "app/views/"

class GupDispatchError < StandardError ; end

class Params
  def initialize(params)
    @params = params
  end
  def [] key
    ret = @params[key]
    ret.size == 1 ? ret[0] : ret
  end
end

class GupBase
  def puts(msg)
    $stderr.puts msg
  end
  def escape(html)
    CGI.escapeHTML(html)
  end
  def render(option={})
    @__gup_render_option__ = option
  end
  def redirect_to(option={})
    @__gup_recirect_option__ ||= option
  end
  def __response__(cgi , category , action)
    if @__gup_recirect_option__  
      action = @__gup_recirect_option__[:action] || action
      url = cgi.script_name.split[0] + "/" + category
      url << "/" + action if action != "index"
      print cgi.header({'status' => '302 Found', 'Location' => url })
    else
      @__gup_render_option__ ||= {}
      if @__gup_render_option__[:text]
        begin
          cgi.out({
            "type"       => "text/plain",
            "charset"    => "utf-8",
            "connection" => "close",
            "pragma"     => "no-cache",
            "cache_control" => "no-cache"
          }){ @__gup_render_option__[:text] }
        end
        return
      end
      action = @__gup_render_option__[:action] || action
      path = VIEW_PATH + category + "/" + action + ".rhtml"
      begin
        cgi.out({
          "type"       => "text/html",
          "charset"    => "utf-8",
          "connection" => "close",
        }){ ERB.new(open(path){|f| f.read}).result(binding) }
      rescue Errno::ENOENT => e
        e.to_s
      end
    end
  end
end

def create_session(cgi)
  return Hash.new
  CGI::Session::new(cgi , 
    { 
      "database_manager" => CGI::Session::PStore ,
      "prefix" => "gup_" ,
      "tmpdir" => "/tmp"
    })
end

def dispatch(cgi , session)
  info = cgi.path_info.split("/")
  raise GupDispatchError.new "welcome to gup" if info.length == 0

  info[2] = "index" if info.length < 3 || !info[2]
  begin
    load CONTROLLER_PATH + info[1] + ".rb"
    #require CONTROLLER_PATH + info[1]
  rescue LoadError => e
    $stderr.puts e
    raise GupDispatchError.new "loaderror => " + CONTROLLER_PATH + info[1] + ".rb"
  end
  app = eval(info[1].capitalize + ".new")
  raise GupDispatchError.new "#{info[1].capitalize} must extends GupBase" unless app.kind_of? GupBase

  app.instance_variable_set("@params"  , Params.new(cgi.params) )
  app.instance_variable_set("@session" , session)
  begin
    app.__send__(info[2])
  rescue NoMethodError => e
    $stderr.puts e
    raise GupDispatchError.new "unknown #{info[1].capitalize}##{info[2]}"
  end
  app.__response__(cgi , info[1] , info[2])
end

f = open("/tmp/log.txt","w")
f.puts "gup start"


cgi = CGI.new
session = create_session(cgi)
begin
  dispatch(cgi , session)
rescue GupDispatchError => e
  cgi.out({"type"=>"text/html","charset"=>"utf-8","connection"=>"close"}){e.to_s}
end

exit
