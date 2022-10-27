# frozen_string_literal: true

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
  end
end