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

    if params["NumMedia"] == "0"
      response = "No image was attached to your text!"
    else
      media_url = params["MediaUrl0"]
      response = "Team #:#{team_number}\nTitle: #{title}\nURL: #{media_url}"

      file = open(media_url)
      response = client.put_file("Team #{team_number}/#{title.underscore}.jpg", file)
    end

  rescue => e
    puts "Error: #{e}"
    response = "There was a problem processing your message: #{e}"
  end

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message(response)
  end
  twiml.text
end
