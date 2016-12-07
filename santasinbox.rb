require 'twilio-ruby'
require 'dropbox_sdk'
require 'sinatra'

post '/message' do
  logger.debug "PARAMS: #{params.inspect}"

  response = nil
  begin
    if text = params["Body"]
      team_number, title = text.strip.split(" ", 2)
      team_number = team_number.to_i
      title = title.strip
    end

    if params["NumMedia"] == "0"
      response = "No image was attached to your text!"
    else
      media_url = params["MediaUrl0"]
      response = "Team #:#{team_number}\nTitle: #{title}\nURL: #{media_url}"

      file = open(media_url)
      client = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
      response = client.put_file("Team #{team_number}/#{title.gsub(/\s/, '_')}.jpg", file)
    end

  rescue => e
    logger.error "Error: #{e}"
    response = "There was a problem processing your message: #{e}"
  end

  logger.info "Sending response: #{response}"
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message(response)
  end
  twiml.text
end
