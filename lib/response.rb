class Response
  
  attr_reader(
              :response,              # the Net:HTTP response
              :doc,                   # the REXML:Document for :response
              :request                # cache the request object for reference in the response
             )

  # all the objects returned
  attr :objects, true
  attr :ids, true

  attr :annotations
  attr :images

  def initialize(request = Request.new)
   
    begin 
      @response = Net::HTTP.get_response(URI.parse(request.request_url)).body
    rescue SocketError
      raise "can not connect to socket, check SERVICES_URI"
    end 

    # TODO: check that we're getting a legit XML document back before trying to parse it
    @doc = REXML::Document.new(@response)

    @request = request # TODO: can this be aliased some how?
    self
  end

  # return an Array of ids representing morphbankIds to images
  def mb_image_ids
    if request.request_options[:format] == 'id' 
      REXML::XPath.match(@doc, "//id").collect{|e| e.text.to_s}
    else
      raise RubyMorphbankError, "you must use method='image' in requests to use the mb_image_ids method"
    end
  end

  # get the Integer of the first match
  def get_int(element_name)
    REXML::XPath.first(@doc, "//#{element_name}").nil? ? 0 : REXML::XPath.first(@doc, "//#{element_name}").text.to_i
  end

  # get the String of the first match
  def get_text(element_name)
    REXML::XPath.first(@doc, "//#{element_name}").nil? ? 0 : REXML::XPath.first(@doc, "//#{element_name}").text
  end

  # return an Array of XML elements whose root is an object element
  def objects
    REXML::XPath.match(@doc, "//object") 
  end

  # TODO: the has conversion is NOT optimal (no attributes, children of root only), see extension in rubyMorpbank
  def hashified_objects
    self.doc.records("//object")
  end

  # pagination
  def link_forward?
    ((get_int('numResultsReturned') + get_int('firstResult')) < get_int('numResults')) and return true
    false
  end

  # pagination
  def link_back?
    (get_int('firstResult') > @request.request_options[:limit].to_i) and return true
    false
  end

end

