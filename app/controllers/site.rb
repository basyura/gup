
class Site
  attr_accessor :no,:name,:url,:xpath,:charset
  def initialize(no, name , url , xpath , charset)
    @no      = no
    @name    = name
    @url     = url
    @xpath   = xpath
    @charset = charset || ""
  end
  def to_s
    "Site[" + @no + "," + @name + "," + @url + "," + @xpath.to_s + "," + @charset.to_s + "]"
  end
end
