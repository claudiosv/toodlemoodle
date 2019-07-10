# ToodleMoodle
A simple CLI tool for analyzing and attacking Moodle installations for pentesters using various publicly available exploits. Developed using Crystal, the fast, natively compiled Ruby lookalike.

## Development

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
or
```
crystal build src/tmoodle.cr && ./tmoodle
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
