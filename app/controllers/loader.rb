require 'pstore'
require 'site'

f = open("log.txt") {|f| f.read}
f.gsub!(/url:/ , ":url => ")
f.gsub!(/xpath:/ , ":xpath => ")
f.gsub!(/charset:/ , ":charset => ")
list = f.split("\n")

buf = ""
for line in list
  if line =~ /\}/
    buf << "},"
  elsif line.strip == ","
    # noop
  else
    buf << line.strip
  end
end
i = buf.rindex(",")
buf[i,1] = ""
puts buf
eval(buf)
puts SITE_INFO

list = []
for i in 0...SITE_INFO.length
  info = SITE_INFO[i]
  list << Site.new(i.to_s , info[:url] , info[:url] , info[:xpath] , info[:charset])
end

PStore.new("siteinfo.log").transaction{|pstore|
  pstore[:list] = list
  pstore[:no]   = SITE_INFO.length
}

