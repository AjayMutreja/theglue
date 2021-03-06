# encoding: utf-8
require "rubygems"
require "bundler/setup"
Bundler.require(:default)

configure do
  # Load .env vars
  Dotenv.load
  # Disable output buffering
  $stdout.sync = true
end

post "/" do
  begin
    puts "[LOG] #{params}"
    params[:text] = params[:text].sub(params[:trigger_word], "").strip
    unless params[:token] != ENV["OUTGOING_WEBHOOK_TOKEN"]
      response = { text: "Yelp Results:" }
      response[:attachments] = [ generate_attachment ]
      response[:username] = ENV["BOT_USERNAME"] unless ENV["BOT_USERNAME"].nil?
      response[:icon_emoji] = ENV["BOT_ICON"] unless ENV["BOT_ICON"].nil?
      response = response.to_json
    end
  end
  status 200
  body response
end

def generate_attachment
  user_query = params[:text]

  # Yelp logic
  client = Yelp::Client.new({ consumer_key: ENV["YELP_CONSUMER_KEY"],
                              consumer_secret: ENV["YELP_CONSUMER_SECRET"]
                            })
  options = { term: "#{user_query}",
             limit: 1,
             radius_filter: ENV["RADIUS"],
           }
  query = client.search("#{ENV["LOCATION"]}", options)

  @name = query.businesses[0].name
  @location = query.businesses[0].location.address[0]
  @url = query.businesses[0].url
  @rating = query.businesses[0].rating
  @summary = query.businesses[0].snippet_text
  @review_count = query.businesses[0].review_count
  @image = query.businesses[0].image_url

  # response
  response = { mrkdwn_in: ["text"], title: "#{@name}", title_link: "#{@url}", text: "*#{@location}*\n#{@summary} <#{@url}| more>", thumb_url: "#{@image}", fields: [ { title: "Reviews", value: "#{@review_count}", short: true }, { title: "Rating", value: "#{@rating}", short: true } ] }

end
