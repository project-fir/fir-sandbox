# fir-sandbox
exploratory data analytics, with a metric twist


#### local dev
I typically use port 8082, so dev-only Auth callbacks will need to be configured accordingly
```shell
lamdera live --port 8082
```

### elm-test-rs

Lamdera recommends `elm-test-rs`, which requires Rust to run.

Instll Rust the recommended way: https://www.rust-lang.org/tools/install

Download the latest binary for your system from: https://github.com/mpizenberg/elm-test-rs/releases

Unzip, place in a folder thats in your `$PATH`

Running tests while developing:
```shell script
elm-test-rs --watch
```
