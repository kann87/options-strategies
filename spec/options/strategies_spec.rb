# frozen_string_literal: true

require 'options/strategies'
include Options::Strategies

RSpec.describe Options::Strategies do
  before do
    @options = {:index_name=>"NIFTY", :spot_price=>17840}
  end

  it "has a version number" do
    expect(VERSION).not_to be nil
  end

  it "Validate the Constants" do
    expect(OrderType::LONG).to eq('LONG')
    expect(OrderType::SHORT).to eq('SHORT')
    expect(IndexUnits::NIFTY).to eq(50)
    expect(IndexUnits::BANKNIFTY).to eq(25)
    expect(Multiplier::BANKNIFTY).to eq(100)
    expect(IndexUnits::NIFTY).to eq(50)
  end

  it "check LongCall result" do
    data = LongCall.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(0)
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
  end

  it "check LongPut result" do
    data = LongPut.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(0)
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("PEOption")
  end

  it "check ShortCall result" do
    data = ShortCall.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(0)
    expect(data["SHORT"].size).to eq(1)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
  end

  it "check ShortPut result" do
    data = ShortPut.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(0)
    expect(data["SHORT"].size).to eq(1)
    expect(data["SHORT"][0]["option_type"]).to eq("PEOption")
  end

  it "check ShortStrangle result" do
    data = ShortStrangle.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check ShortStraddle result" do
    data = ShortStraddle.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"][0]["strike_price"]).to eq(data["SHORT"][1]["strike_price"])
  end

  it "check IronCondor result" do
    data = IronCondor.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["LONG"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check IronFly result" do
    data = IronFly.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["LONG"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check LongIronCondor result" do
    data = LongIronCondor.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
  end

  it "check BullCallSpread result" do
    data = BullCallSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check BullPutSpread result" do
    data = BullPutSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check BearPutSpread result" do
    data = BearPutSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check BearCallSpread result" do
    data = BearCallSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check CallRatioBackSpread result" do
    data = CallRatioBackSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check PutRatioBackSpread result" do
    data = PutRatioBackSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check PutRatioSpread result" do
    data = PutRatioSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("PEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check CallRatioSpread result" do
    data = CallRatioSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("CEOption")
  end

  it "check LongCallLadder result" do
    data = LongCallLadder.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("CEOption")
  end

  it "check LongPutLadder result" do
    data = LongPutLadder.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("PEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check ShortCallLadder result" do
    data = ShortCallLadder.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["LONG"][1]["option_type"]).to eq("CEOption")
    expect(data["SHORT"].size).to eq(1)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
  end

  it "check ShortPutLadder result" do
    data = ShortPutLadder.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["LONG"][0]["option_type"]).to eq("PEOption")
    expect(data["LONG"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(1)
    expect(data["SHORT"][0]["option_type"]).to eq("PEOption")
  end
end
