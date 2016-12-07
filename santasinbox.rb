require 'twilio-ruby'
require 'sinatra'

post '/message' do
  puts params.inspect

  response = nil
  begin
    if text = params[:message]
      team_number, title = text.strip.split(" ", 2)
      team_number = team_number.to_i
    end

    response = "Team #:#{team_number}\nTitle: #{title}\nURL: #{media_url}"

  rescue => e
    response = "There was a problem processing your message"
  end

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message(response)
  end
  twiml.text
end
