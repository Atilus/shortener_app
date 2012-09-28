class Url < ActiveRecord::Base
  attr_accessible :id, :url
  validates_format_of :url, :with => URI::regexp(%w(http https ftp))
  #validates_presence_of :url
end
