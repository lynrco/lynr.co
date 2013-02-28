require 'rspec/autorun'
require 'log4r'
require './lib/log4r/json_formatter'

require 'yajl/json_gem'

describe Log4r::JsonFormatter do

  let(:f) { Log4r::Logger.new('json formatter') }
  let(:event_s) { Log4r::LogEvent.new(0, f, nil, "some data") }
  let(:event_h) { Log4r::LogEvent.new(0, f, nil, { some: 'data'}) }
  let(:formatter) { Log4r::JsonFormatter.new }

  let(:result) { formatter.format(event_s) }
  let(:info) { info = JSON.parse(result) }

  describe "#initialize" do

    context "given info" do

      let(:formatter) { Log4r::JsonFormatter.new({ info: { here: 'be pirates' } }) }

      it "is included in #format output" do
        expect(info['here']).to eq('be pirates')
      end

    end

  end

  describe "#format" do

    it "includes translated level" do
      expect(info['level']).to eq(Log4r::LNAMES[event_s.level])
    end

    it "includes a valid timestamp" do
      time = info['time']
      expect(Time.parse(time)).to be_an_instance_of(Time)
    end

    it "includes logger context" do
      expect(info['context']).to eq('json formatter')
    end

    it "includes pid" do
      expect(info['pid']).to eq(Process.pid)
    end

    context "logging strings" do

      it "includes logged data" do
        expect(info['data']).to eq('some data')
      end

    end

    context "logging hashes" do

      let(:result) { formatter.format(event_h) }

      it "includes logged data as hash" do
        expect(info['data']).to be_an_instance_of(Hash)
      end

      it "includes data of hash" do
        data = info['data']
        expect(data['some']).to eq('data')
      end

    end

  end

end
