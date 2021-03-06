require 'twilio-ruby'
require 'dropbox_sdk'
require 'sinatra'

post '/message' do
  puts "PARAMS: #{params}"

  message = nil
  begin
    if (text = params["Body"]) && text.length > 0
      team_number, title = text.strip.split(" ", 2)
      team_number = Integer(team_number)
    end

    raise ArgumentError unless title && title.length > 0

    if params["NumMedia"] == "0"
      message = "ERROR: No image was attached to your message!"
    else
      media_url = params["MediaUrl0"]
      message = "Thanks! Got team #{team_number}'s photo '#{title}'"

      file = open(media_url)
      client = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
      response = client.put_file("Team #{team_number}/#{title.strip.gsub(/\s/, '_')}.jpg", file)
      puts "Dropbox response: #{response}"
    end

  rescue => e
    puts "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
    message = "ERROR: Please provide your team number, a title, and your photo. For example: 5 Santa Claus"
  end

  puts "Sending message: #{message}"
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message(message)
  end
  twiml.text
end
