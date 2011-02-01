class Request

  # defaults
  METHOD = 'search' 
  OBJECTTYPE = 'Image'
  LIMIT = 10 
  DEPTH = 1
  FORMAT = 'id'

  # a subset of VALID_OPTIONS, these are concatenated in the request
  URI_PARAMS = [:limit, :format, :depth, :objecttype, :firstResult, :keywords, :id, :taxonName, :user, :group, :change, :lastDateChanged, :numChangeDays]

  # possible options for a Request instance 
  VALID_OPTIONS = {'v3' => URI_PARAMS + [:version, :method] } 

  attr_reader(:request_url, :request_options)

  def initialize(options = {}) 
    opt = {
      :version => 'v3',
      :method => METHOD,
      :limit => LIMIT,
      :format => FORMAT,                # 'id' (brief results) or 'svc' (schema based results)
      :depth => DEPTH,
      :objecttype => OBJECTTYPE,        #  [nil, Taxon, Image, Character, Specimen, View, Matrix, Locality, Collection, OTU ] (nil = all)
      :firstResult => 0,
      :keywords => ''
    }.merge!(options)

    # check for legal parameters
    opt.keys.each do |p|
      raise RubyMorphbankError, "#{p} is not a valid parameter" if !VALID_OPTIONS[opt[:version]].include?(p)
    end 


    opt[:keywords].gsub!(/\s*/, '+') 


    # create the request 
    @request_url = SERVICES_URI + "method=#{opt[:method]}" +
    opt.keys.sort{|a,b| a.to_s <=> b.to_s}.collect{
      |k| ( (URI_PARAMS.include?(k) && (!opt[k].nil? || opt[k].empty?)) ? "&#{k.to_s}=#{opt[k]}" : '')
    }.join

    # and some housekeepers
    @request_options = opt 
  end

  def get_response
    Response.new(self)
  end

  # .root.elements.each(xpath){}.map do |row|

    ## REXML::XPath.match(@xml, '//object/width').collect{|e| e.text.to_s}
end
