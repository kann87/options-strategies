# frozen_string_literal: true

module Options
  module Strategies
    class Error < StandardError; end

    class OptionType
      require 'json'

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
  end
end
