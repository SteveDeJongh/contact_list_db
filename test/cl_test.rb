ENV['RACK_ENV'] = 'test'

require 'fileutils'
require 'minitest/autorun'
require 'minitest/reporters'
require 'rack/test'
Minitest::Reporters.use!

require_relative '../cl'

class ClTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    
  end

  def teardown

  end

  def signed_in_session
    { 'rack.session' => { username: 'dev' } }
  end

  def test_sign_in_page
    get '/sign_in'

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Please sign'
  end

  def test_index_redirect
    get '/'

    assert_equal 302, last_response.status

    get last_response['Location']

    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Please sign in'
  end

  def test_index_has_contacts
    get "/", {}, signed_in_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "test2"
  end

  def test_add_contact
    post "/addcontact", {name: 'test123', phonenumber: 'test123', email: 'test123', category: 'test123'}, signed_in_session

    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'test123'
  end
end