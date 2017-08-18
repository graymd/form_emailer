#http://binarylies.ghost.io/sinatra-tests-101/
require_relative '../email_form_app.rb'
require 'rspec'
require 'rack/test'
require 'json'

set :environment, :test

describe 'Server Service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'get /' do
    it "should load the root page" do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'post /send_email_for' do
    context "when not sent as json" do
      it 'responds with 415' do
        post '/send_email_for'
        expect(last_response.status).to eq(415)
      end
    end

    context "when sent as json" do
      it 'responds with 250' do
        data = {
          name: 'name',
          email: 'email@email.com',
          body: 'body'
        }
        post '/send_email_for', data.to_json, "CONTENT_TYPE" => "application/json"
        expect(last_response.status).to eq(250)
      end

      it { should have_sent_email }
    end
  end


end
