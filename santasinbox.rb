require 'twilio-ruby'
require 'dropbox_sdk'
require 'sinatra'

post '/message' do
  puts "PARAMS: #{params}"

  message = nil
  begin
    if text = params["Body"]
      team_number, title = text.strip.split(" ", 2)
      team_number = team_number.to_i
    end

    raise "ERROR: Please provide a title for your image after your team number. For example: 5 Santa Claus"

    if params["NumMedia"] == "0"
      message = "ERROR: No image was attached to your message!"
    else
      media_url = params["MediaUrl0"]
      message = "Team #:#{team_number}\nTitle: #{title}\nURL: #{media_url}"

      file = open(media_url)
      client = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
      response = client.put_file("Team #{team_number}/#{title.strip.gsub(/\s/, '_')}.jpg", file)
      puts "Dropbox response: #{response}"
    end

  rescue => e
    puts "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
    message = "There was a problem processing your message: #{e.message}"
  end

  puts "Sending message: #{message}"
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message(message)
  end
  twiml.text
end
