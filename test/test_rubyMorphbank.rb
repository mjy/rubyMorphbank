require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/rubyMorphbank'))

include RubyMorphbank


class TestRubyMorphbank < Test::Unit::TestCase

  should "initialize a new instance without parameters" do
    assert @bhl = Rmb.new()
  end

  should "return an hash object using get_metadata_for_one_image" do
    # WARNING: this XML to hash is not a terribly useful conversion, the process drops all children and attributes
    hash = metadata_hash_for_one_image(195815) # It's fixed data, not the best test, but if it's gone something is seriously wrong anyways
    assert_equal '1360', hash['width']
  end

end


class TestRequest < Test::Unit::TestCase

  should "return a properly formatted request url with no options" do
    @rmb = Rmb.new
    assert @request = @rmb.request
    assert_equal  "http://services.morphbank.net/mb3/request?method=search&depth=1&firstResult=0&format=id&keywords=&limit=10&objecttype=Image",  @request.request_url 
  end

end


class TestResponse < Test::Unit::TestCase

  should "return initialize with a unparameterized request" do
    @request = Rmb.new.request
    @response = @request.get_response
    assert_equal 'mbresponse', @response.doc.elements.first.name 
  end

  should "return 10 results when unparameterized" do
    @request = Rmb.new.request
    assert_equal 10, @request.get_response.get_int('numResultsReturned')
  end

  should "return many more than 10 results in MB when unparameterized" do
    @request = Rmb.new.request
    assert (10 < @request.get_response.get_int('numResults'))
  end

  should "should link_forward when unparameterized" do
    @request = Rmb.new.request
    assert @request.get_response.link_forward?
  end

  should "should not link_back when unparameterized" do
    @request = Rmb.new.request
    assert !@request.get_response.link_back?
  end

  should "return an array of morphbank image ids when using :format => id and mb_image_ids" do
    @request = Rmb.new.request(:format => 'id')
    @response = @request.get_response
    assert @response.mb_image_ids.size == 10 # not a good test, but variable data return on a vanilla request
    # this is an array of ids like ["32029", ... "32038"]
  end

  # test get_int
  should "return a fixnum using get_int for element numResultsReturned" do
    @request = Rmb.new.request()
    assert_equal 10, @request.get_response.get_int('numResultsReturned')
  end

  # test get_text
  should "return a mbresponse of objecttypes == Image by default" do
    @request = Rmb.new.request()
    assert_equal 'Image', @request.get_response.get_text('objecttypes')
  end

  # return a link to a thumbnail in a call for a single image
  should "return a URI to a thumb for a single object query" do
    foo =  Rmb.new.request(:format => 'svc', :id => 195815, :method => 'id')
    assert_equal 'http://images.morphbank.net/?id=195815&imgType=thumb', foo.get_response.get_text('thumbUrl')
  end

  should "return an array of hashified array of Morphbank objects" do 
    foo =  Rmb.new.request(:format => 'svc').get_response.hashified_objects
    assert_equal 10, foo.size
  end

end

