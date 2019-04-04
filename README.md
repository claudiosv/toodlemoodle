# toodlemoodle

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

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
