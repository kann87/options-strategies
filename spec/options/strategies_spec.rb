# frozen_string_literal: true

require 'options/strategies'

RSpec.describe Options::Strategies do
  before do
    @options = {:index_name=>"NIFTY", :spot_price=>17840}
  end

  it "has a version number" do
    expect(Options::Strategies::VERSION).not_to be nil
  end

  it "Validate the Constants" do
    expect(Options::Strategies::OrderType::LONG).to eq('LONG')
    expect(Options::Strategies::OrderType::SHORT).to eq('SHORT')
    expect(Options::Strategies::IndexUnits::NIFTY).to eq(50)
    expect(Options::Strategies::IndexUnits::BANKNIFTY).to eq(25)
    expect(Options::Strategies::Multiplier::BANKNIFTY).to eq(100)
    expect(Options::Strategies::IndexUnits::NIFTY).to eq(50)
  end

  it "check LongCall result" do
    data = Options::Strategies::LongCall.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(0)
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
  end

  it "check LongPut result" do
    data = Options::Strategies::LongPut.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(0)
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("PEOption")
  end

  it "check ShortCall result" do
    data = Options::Strategies::ShortCall.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(0)
    expect(data["SHORT"].size).to eq(1)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
  end

  it "check ShortPut result" do
    data = Options::Strategies::ShortPut.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(0)
    expect(data["SHORT"].size).to eq(1)
    expect(data["SHORT"][0]["option_type"]).to eq("PEOption")
  end

  it "check ShortStrangle result" do
    data = Options::Strategies::ShortStrangle.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check ShortStraddle result" do
    data = Options::Strategies::ShortStraddle.new(@options).build.to_hash
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"][0]["strike_price"]).to eq(data["SHORT"][1]["strike_price"])
  end

  it "check IronCondor result" do
    data = Options::Strategies::IronCondor.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["LONG"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check IronFly result" do
    data = Options::Strategies::IronFly.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["LONG"][1]["option_type"]).to eq("PEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("PEOption")
  end

  it "check LongIronCondor result" do
    data = Options::Strategies::LongIronCondor.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
  end

  it "check BullCallSpread result" do
    data = Options::Strategies::BullCallSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check BullPutSpread result" do
    data = Options::Strategies::BullPutSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check BearPutSpread result" do
    data = Options::Strategies::BearPutSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check BearCallSpread result" do
    data = Options::Strategies::BearCallSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check CallRatioBackSpread result" do
    data = Options::Strategies::CallRatioBackSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check PutRatioBackSpread result" do
    data = Options::Strategies::PutRatioBackSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(2)
    expect(data["SHORT"].size).to eq(1)
  end

  it "check PutRatioSpread result" do
    data = Options::Strategies::PutRatioSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["SHORT"].size).to eq(2)
  end

  it "check CallRatioSpread result" do
    data = Options::Strategies::CallRatioSpread.new(@options).build.to_hash
    expect(data["LONG"].size).to eq(1)
    expect(data["LONG"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"].size).to eq(2)
    expect(data["SHORT"][0]["option_type"]).to eq("CEOption")
    expect(data["SHORT"][1]["option_type"]).to eq("CEOption")
  end
end
