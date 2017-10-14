require 'spotify-client'

module Crosstify
  class Spotify

    AUTH_BASE_URI = 'https://accounts.spotify.com'.freeze

    def initialize(client, authenticator)
      @client = client
      @authenticator = authenticator
    end

    def self.get_instance(refresh_token)
      config = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config', 'spotify.yml'))[Rails.env])
      self.new(::Spotify::Client.new(config), ::Spotify::Authenticator.new(config, refresh_token));
    end

    def authorization_url
      @authenticator.authorization_url
    end

    def method_missing(sym, *args, &block)
      @client.send(sym, *args, &block)
    rescue ::Spotify::AuthenticationError
      @client.access_token = @authenticator.new_token
      @client.send(sym, *args, &block)
    end
  end
end
