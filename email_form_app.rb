require 'sinatra'
require 'pony'
require 'dotenv/load'
require 'pry'
require 'json'
require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end

if Sinatra::Base.production?
  set :allow_origin, ENV["ALLOWED_ORIGIN"]
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
   200
end

get '/' do
  "welcome"
end

post "/send_email_for" do
  return status 415  unless request.content_type == 'application/json'
  request.body.rewind
  @request_payload = JSON.parse request.body.read.to_s
  puts send_email_for
  # send_email_for("")
  [250, [{email_sent: true}.to_json]]
end

private

def build_email
  name = @request_payload[:name] || @request_payload['name']
  email = @request_payload[:email] || @request_payload['email']
  body = @request_payload[:body] || @request_payload['body']

  "
    Name: #{name}
    Email: #{email}
    Body: #{body}
  "
end

def send_email_for(company = "")
  Pony.options = {
    subject: ENV["COMPANY_NAME"] + " form submission",
    body: build_email,
    via: :smtp,
    via_options: {
      address: "smtp.gmail.com",
      port: "587",
      enable_starttls_auto: true,
      user_name: ENV["ADMIN_EMAIL"],
      password: ENV["SMTP_PASSWORD"],
      authentication: :plain,
      domain: "localhost.localadmin"
    }
  }
  Pony.mail(to: ENV["SEND_TO_EMAIL"])
  puts 'email sent'
end
