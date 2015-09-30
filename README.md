# BackgroundProxy

This gem provides a proxy interface to background method calls to a background thread. A good case is for an external api request that can be deferred until later (rather than blocking the rest of the request).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'background_proxy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install background_proxy

## Usage

Instead of using your client instance, wrap that client instance in a background proxy. It will create new Thread(s) to handle writing to the client.

```
# example usage for writing messages to Kafka via the Poseidon gem
client = Poseidon::Producer.new(...)
proxy = BackgroundProxy::Proxy.new(client)
proxy.send_messages([...])
```

Any message that the wrapped object can handle, the proxy will send through to that model.

**IMPORTANT NOTES**
* These proxies do not currently clean themselves up until after the request finishes.
* The clients need to be thread-safe or not have any kind of mutable state (that is mutated).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chingor13/background_proxy.

