require 'sinatra'
require 'pony'
require 'dotenv/load'

post "/send_email_for" do
  send_email_for()
end

def send_email_for(company = "")
  Pony.options = {
    subject: "testing sinatra email sender",
    body: "testing body for sinatra email",
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
