# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"

module TMoodleActions
  class Scanner
    def perform(target : String)
      puts "Scanning #{target}!"
      version_regex = /(?:(\d+)\.)?(?:(\d+)\.)?(\d+)/

      response = HTTP::Client.get "#{target}/lib/upgrade.txt"
      if regex_data = response.body.match(version_regex)
        version_str = regex_data.not_nil![0]
        puts "Version #{version_str} detected."
        vulnerabilities(version_str)
      end
    end

    def vulnerabilities(version)
      regex = /^(\d+\.)?(\d+\.)?(\*|\d+)$/
    end
  end
end
