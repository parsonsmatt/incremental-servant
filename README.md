# `incremental-servant`

This repository hosts the code to accompany [my blog post]() where I describe a means by which an API can be incrementally and (mostly) transparently be converted to a Haskell `servant` API.

## Getting Started

### Ruby

You need `ruby` and `bundler` to run the server. Any version should work.

```bash
cd rubby
bundle install
ruby api.rb &
```

Let that process run, and it'll be serving up on `localhost:4567`.

### Haskell

You need `stack`, which will take care of the rest.

```haskell
stack setup && stack ghci
```

opens the REPL for use. In the master branch, `startApp` will run the application as a straight up reverse proxy, forwarding requests to `localhost:8080` to `localhost:4567`.
In the other branches, more and more functionality is assumed from the Ruby to the Haskell until eventually it's all taken care of.
