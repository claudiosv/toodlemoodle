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
      #   captures = version.match(regex).not_nil!.captures
      #   major = captures.delete('.').not_nil!.to_i
      #   minor = captures.delete('.').not_nil!.to_i
      #   fix = captures.delete('.').not_nil!.to_i
      #   if major <= 3 && minor <= 6
      #     puts "Vulnerable to CVE-2019-3847"
      #   end
    end
  end
end
