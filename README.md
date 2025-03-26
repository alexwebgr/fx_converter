# FX Converter

### Purpose
This is a demo app that showcases some interesting features
* Encrypted credentials with plain ruby
* Integrating an external service
* A CLI wizard with autocomplete filtering
* Mocking web requests with webmock

![demo](demo.gif)
[asciinema](https://asciinema.org/a/710067)

### Installation
In order to install and run locally you will need ruby installed locally with 
```ruby
ruby app/main.rb
```

or with docker installed 
```ruby
docker build -t fx_converter .
```
```ruby
docker run -it fx_converter
```
