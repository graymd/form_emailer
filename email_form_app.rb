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
  set :allow_origin, [ ENV["ALLOWED_ORIGIN1"], ENV["ALLOWED_ORIGIN2"] ]
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
  return status 415 unless request.content_type == 'application/json'
  request.body.rewind
  request_payload = JSON.parse request.body.read
  send_email_for("", build_email(params))
  status 250
end

def build_email(params)
  name = params[:name]
  email = params[:email]
  body = params[:body]

  "
    Name: #{name}
    Email: #{email}
    Body: #{body}
  "
end



def send_email_for(company = "", params)
  return "sent"
  email_text = build_email(params)
  Pony.options = {
    subject: ENV["COMPANY_NAME"] + " form submission",
    body: email_text,
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
end
