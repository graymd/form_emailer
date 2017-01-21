require 'sinatra'
require 'pony'
require 'dotenv/load'
require 'pry'

post "/send_email_for" do
  if params[:token] = ENV["QUICK_TOKEN"]
    send_email_for("", params)
    "complete"
  else
    "unauthorized"
  end
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
  # return email_body
end



def send_email_for(company = "", params)
  body = build_email(params)
  puts body
  Pony.options = {
    subject: ENV["COMPANY_NAME"] + " form submission",
    body: body,
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
