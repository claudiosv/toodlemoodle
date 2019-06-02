# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"

module TMoodleActions
  class Scanner
    def perform(target : String)
      puts "[>] Scanning #{target} ..."
      version_regex = /(?:(\d+)\.)?(?:(\d+)\.)?(\d+)/

      response = HTTP::Client.get "#{target}/lib/upgrade.txt"
      if response.status_code == 200 
        if regex_data = response.body.match(version_regex)
          version_str = regex_data.not_nil![0]
          puts "[*] Version #{version_str} detected."
        end
      else
        puts "[!] Unable to get moodle version!"
      end
    end
  end
end
