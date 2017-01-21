require 'sinatra'
require 'pony'
require 'dotenv/load'
require 'pry'
require 'json'

get '/' do
  "welcome"
end

post "/send_email_for" do
  return "incorrect format" unless request.content_type == 'application/json'
  request.body.rewind
  request_payload = JSON.parse request.body.read
  "complete"
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
