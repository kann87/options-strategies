# Options Strategies - NSE F&O

This gem helps you to use the Options pre-defined strategies with the respective inputs and also allows to create the custom strategy as you want.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add options-strategies

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install options-strategies

## Usage

    require 'options-strategies'
    
    options = {:index_name=>"NIFTY", :spot_price=>17840}
    LongStraddle.new(options).build.to_hash
    
    ==> {"LONG"=>[{"strike_price"=>17850, "index_name"=>"NIFTY", "default_units"=>50, "size"=>1, "execute_units"=>50, "option_type"=>"CEOption"}, {"strike_price"=>17850, "index_name"=>"NIFTY", "default_units"=>50, "size"=>1, "execute_units"=>50, "option_type"=>"PEOption"}], "SHORT"=>[], "index_name"=>"NIFTY", "spot_price"=>17840, "strike_price"=>17850, "klass_name"=>"LongStraddle"}
    or
    
    options = {:index_name=>"BANKNIFTY", :spot_price=>40000}
    LongStraddle.new(options).build.to_hash
    
    {"LONG"=>[{"strike_price"=>40000, "index_name"=>"BANKNIFTY", "default_units"=>25, "size"=>1, "execute_units"=>25, "option_type"=>"CEOption"}, {"strike_price"=>40000, "index_name"=>"BANKNIFTY", "default_units"=>25, "size"=>1, "execute_units"=>25, "option_type"=>"PEOption"}], "SHORT"=>[], "index_name"=>"BANKNIFTY", "spot_price"=>40000, "strike_price"=>40000, "klass_name"=>"LongStraddle"}


## Implemented Strategies

* LongCall
* LongPut
* ShortCall
* ShortPut
* ShortStrangle
* ShortStraddle
* IronCondor
* IronFly
* LongIronCondor
* BullCallSpread
* BullPutSpread
* BearPutSpread
* BearCallSpread
* CallRatioBackSpread
* PutRatioBackSpread
* PutRatioSpread
* CallRatioSpread


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kann87/options-strategies. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/kann87/options-strategies/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Options::Strategies project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/options-strategies/blob/master/CODE_OF_CONDUCT.md).
