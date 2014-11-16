# Musicality

The library is based around an abstract representation for music notation. From here, functions are built up to make composing elaborate pieces in this notation representation more manageable. Finally, music performance is supported by providing translation to common formats, like MIDI.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'musicality'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install musicality

## Usage

Raw notation objects can be created like this:
```ruby
require 'musicality'
include Musicality
include Pitches
include Dynamics

single = Note.quarter(Ab4)
rest = Note.quarter
chord = Note.whole([C3,E3,G3])
part = Part.new(MP, notes:[single,rest,chord])
```

Or, a compact, string representation can be used, instead.
```ruby
Part.new(FF, "/4Ab4 /4 1C3,E3,G3".to_notes)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/musicality/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
