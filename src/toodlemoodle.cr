# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"

module Toodlemoodle
  class Main
    VERSION = "0.1.0"
    @scan = false
    @target = ""
    @destination = ""

    def parser_config(parser)
      parser.banner = "Usage: tmoodle [arguments] TARGET"
      parser.on("-s", "--scan", "Scans the target (default)") { @scan = true }
      parser.on("-t NAME", "--to=NAME", "Specifies the name to target (ignore, for ref)") { |name| @destination = name }
      parser.on("-h", "--help", "Show this help") { puts parser }
      parser.invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option.\n"
        STDERR.puts parser
        exit(1)
      end
      parser.unknown_args do |args|
        @target = args[0]
      end
    end

    def main
      OptionParser.parse! do |parser|
        parser_config(parser)
      end

      if !@target
        STDERR.puts "ERROR: Please specify a target.\n"
        exit(1)
      else
        puts "Attacking #{@target}!"
        version_regex = /(?:(\d+)\.)?(?:(\d+)\.)?(\d+)/

        # TODO: Put your code here
        params = HTTP::Params.encode({"author" => "John Doe", "offset" => "20"}) # => author=John+Doe&offset=20
        response = HTTP::Client.get "https://#{@target}/lib/upgrade.txt"         # https://ole.unibz.it
        # puts response.body
        if regex_data = response.body.match(version_regex)
          puts "Version #{regex_data.not_nil![0]} detected." # => 200
        end
      end
    end
  end

  main = Main.new
  main.main
end
