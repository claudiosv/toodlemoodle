# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"

class SessionInfo
  def perform(target)
    puts "[?] Enter the username"
    username = gets().not_nil!
    puts "[?] Enter the password"
    psw = gets().not_nil!
    session = get_session(target, username, psw)
    puts "[*] Session token: " + session["moodle_session"]
    puts "[*] Session key: " + session["session_key"]
    puts "[!] Done, session retrived!"
  end

  def get_session(url, user, psw)
    data = {
      "anchor"   => "",
      "username" => user,
      "password" => psw,
    }
    puts "[>] Logging in as " + data["username"]
    redirect_response = http_post(url + "/login/index.php", data)

    if redirect_response.status_code == 303
      # extract the new moodle session ID
      moodle_session = /path=\/\", \"MoodleSession=(.*); path=\/\",/.match(redirect_response.headers.to_s).try &.[1]
      puts "[>] Extracting new session ID"
      response = http_get(url + "/my/", moodle_session)
      if response.status_code == 303
        puts "[!] Login failed!"
      else
        puts "[*] Login success!"
        session_key = /sesskey\":\"(.*)\",\"loadingicon/.match(response.body).try &.[1]
        puts "[>] Authenticated session ID => " + moodle_session.not_nil!
        puts "[>] Authenticated session key => " + session_key.not_nil!
      end
    end
    return {"moodle_session" => moodle_session.not_nil!, "session_key" => session_key.not_nil!}
  end

  private def http_post(url, data : String | Hash(String, String | Int32), moodle_session = "", json = nil)
    headers = HTTP::Headers.new
    if moodle_session != ""
      headers.add("Cookie", "MoodleSession=" + moodle_session)
    end
    if json
      headers.add("Content-Type", "application/json")
    end

    return HTTP::Client.post(url, headers: headers, form: data)
  end

  private def http_get(url, moodle_session)
    headers = HTTP::Headers.new
    headers.add("Cookie", "MoodleSession=" + moodle_session.to_s)
    return HTTP::Client.get(url, headers: headers)
  end
end
