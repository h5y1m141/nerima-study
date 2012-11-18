require 'twitter'
require 'sinatra'
require 'haml'
require 'yaml'

class MyApp < Sinatra::Base
  before do
    my_conf = YAML.load_file("config.yaml")

    Twitter.configure do |config|
       config.consumer_key       = my_conf["config"]["consumer_key"]
       config.consumer_secret    = my_conf["config"]["consumer_secret"]
       config.oauth_token        = my_conf["config"]["oauth_token"]
       config.oauth_token_secret = my_conf["config"]["oauth_token_secret"]
    end
  end

  get '/' do
    @home_timeline = Twitter.home_timeline
    erb :top
  end
end

MyApp.run! :host => 'localhost', :port => 4567
