#!/usr/bin/env ruby
# rulers/test/test_application.rb
require_relative "test_helper"

class TestController < Rulers::Controller
  def index
    "Hello"  # Not rendering a view
  end
end

class TestApp < Rulers::Application
  def get_controller_and_action(env)
    unless env['PATH_INFO'] == "/example/route"
      raise StandardError
    end
    [TestController, "index"]
  end
end

class FileModelTest < Test::Unit::TestCase
  include Rulers::Model

  def test_all
    all = FileModel.all
    assert FileModel.all.length == 3, "#{all}"
  end

  def test_file_find_by_submitter
    data = FileModel.find "J", "submitter"
    assert data.length == 2, "#{data}"
  end

  def test_file_save
    assert FileModel.find(3)["submitter"] != "test", "Bad initial state"
    updated = FileModel.save 3, {"submitter" => "test"}
    assert updated["submitter"] == "test", "Submitter not updated: #{updated}"
    updated = FileModel.save 3, {"submitter" => "Hank"}
  end

  def test_file_find_by_id
    first = FileModel.find 1
    assert first
    assert first.id == 1
  end
end

class RulersAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  def test_request
    get "/example/route"

    assert last_response.ok?, last_response.inspect
    body = last_response.body
    assert body["Hello"]
  end

  def test_favicon
    get "/favicon.ico"

    assert last_response.status == 404, last_response.inspect
  end

  def test_index_redirect
    get "/"

    assert last_response.status == 302, last_response.inspect
  end

  def test_exception
    get "/example/blah"

    assert last_response.status == 500, last_response.inspect
    body = last_response.body
    assert body.start_with?("Something went wrong"), last_response.inspect
  end

end
