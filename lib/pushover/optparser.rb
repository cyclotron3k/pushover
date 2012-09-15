require 'optparse'

module Pushover
  class OptionParser < ::OptionParser
    def initialize
      super
      @options = {}

      on("-V", "--version", "Print version") { |version| @options[:version] = true}
      on("-u", "--user USER", "Which user, can be a saved name or token.") { |o| @options[:user] = o}
      on("-a", "--app APPKEY", "Which app to notify, can be a saved name or apikey.") { |o| @options[:appkey] = o}
      on("-T", "--title [TITLE]", "Set the title of the notification (optional).") { |o| @options[:title] = o}
      on("--save-app NAME", "Saves the application to the config file under NAME.") { |o| @options[:save_app] = [@options[:appkey], o]}
      on("--save-user NAME", "Saves the user to the config file under NAME.") { |o| @options[:save_user] = [@options[:user], o]}
    end

    # This will build an on/off option with a default value set to false.
    def bool_on(word, description = "")
      Options[word.to_sym] = false
      on "-#{word.chars.first}", "--[no]#{word}", description  do |o|
        Options[word.to_sym] == o
      end
    end

    def parse!
      @banner = Pushover::VERSION
      super

      if @options[:version]
        puts Pushover::VERSION
        exit 0
      end

      # we need to mash in our config array.  To do this we want to make config
      # options that don't overwrite cli options.
      Config.each do |k,v|
        @options[k] = v if !@options[k] && ["applications", "users"].include?(k)
      end
    end

    def [](k = nil)
      return @options[k] if k
      return @options if @options.any?
      nil
    end

    def []=(k,v)
      @options[k] = v
    end

    def empty?
      @options.empty?
    end
  end

  Options = OptionParser.new
end