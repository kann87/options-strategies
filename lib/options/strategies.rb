# frozen_string_literal: true

require_relative "strategies/version"
require 'options/strategies'

module Options
  module Strategies
    class Error < StandardError; end
    # Your code goes here...
    module OrderType
      LONG = "LONG"
      SHORT = "SHORT"
    end

    module IndexList
      NIFTY = "NIFTY"
      BANKNIFTY = "BANKNIFTY"
    end

    module Multiplier
      NIFTY = 50
      BANKNIFTY = 100
      FINNIFTY = 100
    end

    module IndexUnits
      NIFTY = 50
      BANKNIFTY = 25
      FINNIFTY = 40
    end

    class OptionType
      require 'json'
      include OrderType
      include IndexList

      attr_reader :strike_price, :size, :type, :expiry_date, :ltp, :index_name, :default_units, :execute_units

      def initialize(options={})
        @strike_price = options[:strike_price]
        @index_name = options[:index_name]
        @default_units = eval("IndexUnits::#{@index_name}")
      end

      def size=(size)
        @size = size
        @execute_units = @size * @default_units
      end

      def type=(type)
        @type = type
      end

      def expiry_date=(expiry_date)
        @expiry_date = expiry_date
      end

      def ltp=(ltp)
        @ltp = ltp
      end

      def to_hash
        hash = {}.tap do |hash|
          self.instance_variables.each do |var|
            variable = var.to_s.tr('@', '')
            hash[variable] = instance_variable_get("@#{variable}")
          end
          hash["option_type"] = self.class.name.split('::').last
        end
      end

      def to_json
        to_hash.to_json
      end
    end

    class CEOption < OptionType
    end

    class PEOption < OptionType
    end

    class Strategy
      include OrderType
      include Multiplier
      include IndexList
      include IndexUnits

      attr_accessor :legs, :ce_increment, :pe_increment, :increment, :strike_price, :index_name, :default_lot_size, :input_lot_size, :option_type_klasses, :options_data

      def initialize(options={})
        @options = options
        @index_name = @options[:index_name]
        @increment = eval("Multiplier::#{@index_name}")
        @spot_price = @options[:spot_price]
        @strike_price = @options.key?(:strike_price) ? @options[:strike_price] : @increment * ((@spot_price + @increment/2.0).to_i / @increment)
        @options[:strike_price] = @strike_price
        @ce_increment = 0
        @pe_increment = 0
        @default_lot_size = 1
        @input_lot_size = 1
        @options_data = []
        @legs = {OrderType::LONG => [], OrderType::SHORT => [], "index_name" => @index_name, "spot_price" => @spot_price, "strike_price" => @strike_price, "klass_name" => self.class.name.split('::').last}
      end

      def long=(option_type)
        @legs[OrderType::LONG] << option_type.to_hash
      end

      def short=(option_type)
        @legs[OrderType::SHORT] << option_type.to_hash
      end

      def lot_size=(val)
        @input_lot_size = val
      end

      def parse_option_type_klasses
        @option_type_klasses.each do |klass, option_strike_price|
          @options[:strike_price] = option_strike_price
          # puts "#{klass} --> #{option_strike_price} --> #{@options}"
          option = klass.new(@options)
          # puts "#{option}"
          @options_data << option
          @options[:strike_price] = @strike_price
        end
      end

      def merge_legs(input_legs)
        @legs.each do |k,v|
          if @legs[k].kind_of? Array
            @legs[k] << input_legs[k] unless input_legs[k].empty?
            @legs[k].flatten!
          end
        end
      end

      def construct
        parse_option_type_klasses
        @default_lot_size = @input_lot_size * @default_lot_size
        @options_data.each do |option_data|
          option_data.size = @default_lot_size
          yield option_data
        end
        self
      end

      def to_hash
        self.legs
      end

      def to_json
        self.legs.to_json
      end
    end

    class Hedge < Strategy
      attr_accessor :parent_ce_strike_price, :parent_pe_strike_price
      def initialize(options={})
        super(options)
        @ce_increment = 3 * @increment
        @pe_increment = -3 * @increment
        @parent_pe_strike_price = @options.key?(:parent_pe_strike_price) ? @options[:parent_pe_strike_price] : @strike_price
        @parent_ce_strike_price = @options.key?(:parent_ce_strike_price) ? @options[:parent_ce_strike_price] : @strike_price
        @option_type_klasses = {CEOption => @parent_ce_strike_price + @ce_increment, PEOption => @parent_pe_strike_price + @pe_increment}
      end

      def build
        construct {|option_data| self.long = option_data }
      end
    end

    class ShortHedge < Hedge
      def build
        construct {|option_data| self.short = option_data }
      end
    end

    class Straddle < Strategy
      def initialize(options={})
        super(options)
        @options = options
        @option_type_klasses = {CEOption => @options[:strike_price], PEOption => @options[:strike_price]}
      end
    end

    class Strangle < Strategy
      def initialize(options={})
        super(options)
        @ce_increment = 4 * @increment
        @pe_increment = -4 * @increment
        @option_type_klasses = {CEOption => @options[:strike_price] + @ce_increment, PEOption => @options[:strike_price] + @pe_increment}
      end
    end

    class LongCall < Strategy
      def initialize(options ={})
        super(options)
        @option_type_klasses = {CEOption => @options[:strike_price]}
      end

      def build
        construct {|option_data| self.long = option_data }
      end
    end

    class ShortCall < Strategy
      def initialize(options ={})
        super(options)
        @option_type_klasses = {CEOption => @options[:strike_price]}
      end

      def build
        construct {|option_data| self.short = option_data }
      end
    end

    class LongPut < Strategy
      def initialize(options ={})
        super(options)
        @option_type_klasses = {PEOption => @options[:strike_price]}
      end

      def build
        construct {|option_data| self.long = option_data }
      end
    end

    class ShortPut < Strategy
      def initialize(options ={})
        super(options)
        @option_type_klasses = {PEOption => @options[:strike_price]}
      end

      def build
        construct {|option_data| self.short = option_data }
      end
    end

    # options = {:index_name=>"NIFTY", :spot_price=>17840, :strike_price=>17850}
    #example => ShortStrangle.new(options).build.to_hash
    #example => ShortStrangle.new(options).build.to_json
    class ShortStrangle < Strangle
      def build
        construct {|option_data| self.short = option_data }
      end
    end

    # options = {:index_name=>"NIFTY", :spot_price=>17840, :strike_price=>17850}
    #example => ShortStraddle.new(options).build.to_hash
    #example => ShortStraddle.new(options).build.to_json
    class ShortStraddle < Straddle
      def build
        construct {|option_data| self.short = option_data }
      end
    end

    # options = {:index_name=>"NIFTY", :spot_price=>17840, :strike_price=>17850}
    #example => LongStrangle.new(options).build.to_hash
    #example => LongStrangle.new(options).build.to_json
    class LongStrangle < Strangle
      def build
        construct {|option_data| self.long = option_data }
      end
    end

    # options = {:index_name=>"NIFTY", :spot_price=>17840, :strike_price=>17850}
    #example => LongStraddle.new(options).build.to_hash
    #example => LongStraddle.new(options).build.to_json
    class LongStraddle < Straddle
      def build
        construct {|option_data| self.long = option_data }
      end
    end

    class IronStrategy < Strategy
      def build
        @strategy_type_klasses.each do |strategy_klass, _strike_price|
          sk = strategy_klass.new(@options)
          sk.lot_size = self.input_lot_size
          unless (strategy_klass == Hedge && strategy_klass == ShortHedge)
            sk_option_type_klasses = sk.option_type_klasses
            @options[:parent_ce_strike_price] = sk_option_type_klasses[CEOption]
            @options[:parent_pe_strike_price] = sk_option_type_klasses[PEOption]
          end
          self.merge_legs(sk.build.legs)
        end
        self.legs
      end
    end

    class IronCondor < IronStrategy
      def initialize(options)
        super(options)
        @strategy_type_klasses = {ShortStrangle => @strike_price, Hedge => @strike_price}
      end
    end

    class IronFly < IronStrategy
      def initialize(options)
        super(options)
        @strategy_type_klasses = {ShortStraddle => @strike_price, Hedge => @strike_price}
      end
    end

    class LongIronCondor < IronStrategy
      def initialize(options)
        super(options)
        @strategy_type_klasses = {LongStrangle => @strike_price, ShortHedge => @strike_price}
      end
    end

    class LongIronFly < IronStrategy
      def initialize(options)
        super(options)
        @strategy_type_klasses = {LongStraddle => @strike_price, ShortHedge => @strike_price}
      end
    end

    class SpreadStrategy < Strategy
      def build
        @strategy_type_klasses.each do |strategy_klass, strike_price|
          @options[:strike_price] = strike_price
          sk = strategy_klass.new(@options)
          sk.lot_size = self.input_lot_size
          # puts "KKKKKK --> #{@options} --> #{strategy_klass} --> #{strike_price} --> #{sk.to_hash}"
          self.merge_legs(sk.build.legs)
        end
        @options[:strike_price] = @strike_price
        self.legs
      end
    end

    class BullCallSpread < SpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {LongCall => @strike_price, ShortCall => @strike_price + (5 * @increment)}
      end
    end

    class BullPutSpread < SpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {ShortPut => @strike_price, LongPut => @strike_price + (5 * @increment)}
      end
    end

    class BearPutSpread < SpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {LongPut => @strike_price, ShortPut => @strike_price + (5 * @increment)}
      end
    end

    class BearCallSpread < SpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {ShortCall => @strike_price, LongCall => @strike_price + (5 * @increment)}
      end
    end

    class RatioBackSpreadStrategy < Strategy
      def build
        @strategy_type_klasses.each do |strategy_klass, strike_prices|
          strike_prices.each do |strike_price|
            @options[:strike_price] = strike_price
            sk = strategy_klass.new(@options)
            sk.lot_size = self.input_lot_size
            # puts "KKKKKK --> #{@options} --> #{strategy_klass} --> #{strike_price} --> #{sk.to_hash}"
            self.merge_legs(sk.build.legs)
          end
        end
        @options[:strike_price] = @strike_price
        self.legs
      end
    end

    class CallRatioBackSpread < RatioBackSpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {ShortCall => [@strike_price], LongCall => [@strike_price + (5 * @increment), @strike_price + (5 * @increment)]}
      end
    end

    class PutRatioBackSpread < RatioBackSpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {ShortPut => [@strike_price], LongPut => [@strike_price + (5 * @increment), @strike_price + (5 * @increment)]}
      end
    end

    class PutRatioSpread < RatioBackSpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {LongPut => [@strike_price], ShortPut => [@strike_price - (5 * @increment), @strike_price - (5 * @increment)]}
      end
    end

    class CallRatioSpread < RatioBackSpreadStrategy
      def initialize(options ={})
        super(options)
        @strategy_type_klasses = {LongCall => [@strike_price], ShortCall => [@strike_price + (5 * @increment), @strike_price + (5 * @increment)]}
      end
    end
  end
end
