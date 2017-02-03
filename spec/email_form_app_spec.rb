#http://binarylies.ghost.io/sinatra-tests-101/
require_relative '../email_form_app.rb'
require 'rspec'
require 'rack/test'

set :environment, :test

describe 'Server Service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should load the root page" do
    get '/'
    expect(last_response).to be_ok
  end

  it 'should respond with "incorrect format" when not sent as javascript' do
    data = {
      'kitter' => 'cat'
    }
    post '/send_email_for'
    expect(last_response.body).to eq('incorrect format')
  end

  it 'should respond with "incorrect format" when not sent as javascript' do
    data = {
      'kitter' => 'cat'
    }
    post '/send_email_for', data.to_json, "CONTENT_TYPE" => "application/json"
    expect(last_response).to be_ok
  end

end
