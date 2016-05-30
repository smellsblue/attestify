# Attestify

Attestify has a few key goals:
* Be fast
* Be slim
* Be (mostly) API compatible with [Minitest](https://github.com/seattlerb/minitest)
* Allow multiple failed assertions

While the first 3 goals are probably self explanatory, you might
scratch your head a bit at the last. If you have ever used
[QUnit](https://qunitjs.com/), then you may already be familiar with
this style of testing. Essentially, your entire test runs every time,
_regardless of failures_. The only thing that will stop a test from
continuing is an exception.

To give a quick example of how this might benefit you, consider the
following code:

```
def test_some_functionality_involving_an_array
  some_object = SomeCode.that_returns_an_object
  assert_equal 42, some_object.an_attribute
  assert_equal 4, some_object.another_attribute
  assert_equal 2, some_object.a_final_attribute
end
```

Now, what would happen if every assertion would fail? In most Ruby
test frameworks, you will get a single message about the first
failure. Sometimes the later assertions would give incredibly useful
information for diagnosing the test failure. You could break it up
into 3 tests, but sometimes the setup code is incredibly slow, or all
the attributes are related to the one test case.

In Attestify, every assertion that fails will be reported, giving you
the full picture of what your tests could tell you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "attestify"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attestify

## Usage

This section is still to come, but in the meantime, write your tests
as if they were Minitest tests, but replace `Minitest::` with
`Attestify::`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/smellsblue/attestify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
