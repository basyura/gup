require 'webrick'

document_root = './'
#rubybin = '/usr/local/bin/ruby'
rubybin = '/usr/bin/ruby'

server = WEBrick::HTTPServer.new({
  :DocumentRoot => document_root,
  :BindAddress => '0.0.0.0',
  :CGIInterpreter => rubybin,
  :Port => 10080
})


server.mount('/gup', WEBrick::HTTPServlet::CGIHandler, 'gup.cgi')

['INT', 'TERM'].each {|signal|
  Signal.trap(signal){ server.shutdown }
}

server.start
