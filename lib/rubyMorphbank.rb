# Written by Matt Yoder, 2010
# see source on github

require 'ruby-debug'
require 'rexml/document'
require 'net/http'

module RubyMorphbank

  # schema is at  http://morphbank.net/schema/mbsvc3.xsd  
  # web interface to API is at http://services.morphbank.net/mb3

  require File.expand_path(File.join(File.dirname(__FILE__), '../lib/request.rb'))
  require File.expand_path(File.join(File.dirname(__FILE__), '../lib/response.rb'))

  SERVICES_URI = 'http://services.morphbank.net/mb3/request?' 

  class RubyMorphbankError < StandardError
  end


  class Rmb
    attr_accessor :opt

    def initialize(options = {}) 
      opt = {
      }.merge!(options)  
    end

    def request(options = {})
      opt = {
      }.merge!(options)
      Request.new(opt)
    end
  end

  # returns a Hash with properties set to values !! no attributes, nothing other than child elements of root (see extensions below) !!
  def metadata_hash_for_one_image(image_id)
    Rmb.new.request(:id => image_id, :format => 'svc', :objecttype => 'Image', :method => 'id', :limit => 1).get_response.doc.record('//object')
  end

end


## Base/REXML extension ##

# modified from http://snippets.dzone.com/posts/show/6181

# convert an array into a hash
class Array
  def to_h
    Hash[*self]
  end
end

# neither of these extensions is particularly good, they don't recurse etc.
class REXML::Document
  def record(xpath)
    self.root.elements.each(xpath + '/*'){}.inject([]) do |r,node|
      r << node.name.to_s << node.text.to_s.strip
    end.to_h
  end

  def records(xpath)
    self.root.elements.each(xpath){}.map do |row|
      row.elements.each{}.inject([]) do |r,node|
        r << node.name.to_s << node.text.to_s.strip
      end.to_h
    end
  end
end

