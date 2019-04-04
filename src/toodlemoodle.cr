# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"

module Toodlemoodle
  VERSION = "0.1.0"

  scan = false
  target = Nil

  OptionParser.parse! do |parser|
    parser.banner = "Usage: tmoodle [arguments] TARGET"
    parser.on("-s", "--scan", "Scans the target (default)") { scan = true }
    parser.on("-t NAME", "--to=NAME", "Specifies the name to target (ignore, for ref)") { |name| destination = name }
    parser.on("-h", "--help", "Show this help") { puts parser }
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option.\n"
      STDERR.puts parser
      exit(1)
    end
    parser.unknown_args do |args|
      target = args[0]
    end
  end

  if !target
    STDERR.puts "ERROR: Please specify a target.\n"
    exit(1)
  else
    puts "Attacking #{target}!"
    version_regex = /(?:(\d+)\.)?(?:(\d+)\.)?(\d+)/

    # TODO: Put your code here
    params = HTTP::Params.encode({"author" => "John Doe", "offset" => "20"}) # => author=John+Doe&offset=20
    response = HTTP::Client.get "https://#{target}/lib/upgrade.txt"          # https://ole.unibz.it
    # puts response.body
    if regex_data = response.body.match(version_regex)
      puts "Version detected: " + regex_data.not_nil![0] # => 200
    end
  end
end
