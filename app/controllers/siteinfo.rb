require 'pstore'
require 'app/controllers/site'

class Siteinfo < GupBase
  FILE_PATH = "data/siteinfo.log"
  def index
    PStore.new(FILE_PATH).transaction(true) {|pstore|
      @list = pstore[:list] || []
    }
  end
  def post
    password = @params["password"].strip
    name    = @params["name"].strip
    url     = @params["url"].strip
    xpath   = @params["xpath"].strip
    charset = @params["charset"].strip

    if name && url && xpath && charset
      PStore.new(FILE_PATH).transaction {|pstore|
        no = pstore[:no] ||= -1
        no += 1
        @list = pstore[:list] ||= []
        @list << Site.new(no.to_s,name,url,xpath,charset)
        pstore[:no] = no
      }
    end
    redirect_to :action => "index"
  end
  def edit
      PStore.new(FILE_PATH).transaction(true) {|pstore|
        list = pstore[:list]
        for site in list
          if @params["no"] == site.no
            @site = site
            break
          end
        end
      }
  end
  def edit_save
    PStore.new(FILE_PATH).transaction {|pstore|
      list = pstore[:list]
      for site in list
        if @params["no"] == site.no
          site.name    = @params["name"].strip
          site.url     = @params["url"].strip
          site.xpath   = @params["xpath"].strip
          site.charset = @params["charset"].strip
          break
        end
      end
    }
    redirect_to :action => "index"
  end
  def delete
    PStore.new(FILE_PATH).transaction {|pstore|
      list = pstore[:list]
      for i in 0...list.size
        if @params["no"] == list[i].no
          list.delete_at(i)
          break
        end
      end
      pstore[:list] = list
    }
    redirect_to :action => "index"
  end
  def json
    list = PStore.new(FILE_PATH).transaction(true){|pstore| pstore[:list]}
    buf = "SITE_INFO = ["
    for site in list
      buf << "{ url: '#{site.url}' , xpath: '#{site.xpath}'"
      buf << " , charset: '#{site.charset}'" if site.charset != ""
      buf << "},"
    end
    buf.chomp!(",")
    buf << "];"
    render :text => buf
  end
end

