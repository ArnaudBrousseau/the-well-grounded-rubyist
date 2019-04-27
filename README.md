# The Well-Grounded Rubyist
I'm reading this, and keeping track of the things I'm learning along the way.

## `load` vs `require`

* `load` is for files, and does not keep track of whether files are loaded or
  not. Useful for re`load`ing in interactive IRB sessions
* `require` is for "features". File extensions don't matter and the underlying
  feature can be in C or Ruby. Requiring a file twice will result in a single
  inclusion (good for performance)

## Gems

To install from local

    $ gem install /path/to/gem

To install a gem AND ALL ITS DEPS from local:

    $ gem install -l /path/to/gem

Same, but only remote:

    $ gem install -r bundler

## Misc Tips

Syntax check:

    $ ruby -wc program.rb

Executing inline ruby code

    $ ruby -e 'puts 4+7'

Echoing Ruby's load path

    $ ruby -e '$:'

Requiring stuff into `irb` and `ruby`

    $ irb -r rbconfig
    $ ruby -r rbconfig -e 'RbConfig::CONFIG["sitedir"]'

Grep in Ruby!

    $ ruby -e 'puts $:.grep(/arnaud/)'

Using a different version of a Gem in irb:

    $ irb
    >> gem "bundler", "1.17.3"
