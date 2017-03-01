require 'sinatra'
require 'pony'
require 'dotenv/load'
require 'pry'
require 'json'
require 'sinatra/cross_origin'
require 'httparty'

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

post "/send_email" do
  return status [415, email_sent_response(false)]  unless request.content_type == 'application/json'
  request.body.rewind
  @request_payload = JSON.parse request.body.read.to_s
  return [400, email_sent_response(false)] unless captcha_response_verified?
  send_email
  # send_email("")
  [250, email_sent_response(true)]
end

private

def email_sent_response(bool)
 [{email_sent: bool}.to_json]
end

def captcha_response_verified?
  get_captcha_response["success"]
end

def get_captcha_response
  url = 'https://www.google.com/recaptcha/api/siteverify'
  user_captcha_response = @request_payload["captchaResponse"]
  HTTParty.post(url,
    :query => {
      :secret => ENV['CAPTCHA_SECRET_KEY'],
      :response => user_captcha_response
    },
    :headers => { 'Content-Type' => 'application/json' }
  )
end

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

def send_email(company = "")
  puts 'sending email'
  return
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
