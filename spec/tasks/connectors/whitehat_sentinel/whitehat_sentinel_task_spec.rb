# frozen_string_literal: true

require "rspec_helper"

RSpec.describe Kenna::Toolkit::WhitehatSentinelTask do
  subject(:task) { described_class.new }

  describe "#run" do
    let(:api_client) { instance_double(Kenna::Toolkit::WhitehatSentinel::ApiClient, api_key_valid?: valid, vulns: [vuln], assets: [asset]) }
    let(:key) { "0xdeadbeef" }
    let(:options) { { whitehat_api_key: key } }
    let(:valid) { true }
    let(:vuln) { { found: "2016-03-21T15:48:48Z", status: "accepted", severity: "4", risk: 5 } }
    let(:asset) { { asset: { id: 12 } } }

    before do
      allow(Kenna::Toolkit::WhitehatSentinel::ApiClient).to receive(:new) { api_client }
    end

    it "succeeds" do
      expect { task.run(options) }.to_not raise_error
    end

    context "when using an unknown scoring system" do
      before do
        options[:whitehat_scoring] = "kenna"
      end

      it "exits the script" do
        expect { task.run(options) }.to raise_error(SystemExit)
      end
    end

    context "when the API key is wrong" do
      let(:valid) { false }

      it "exits the script" do
        expect { task.run(options) }.to raise_error(SystemExit)
      end
    end
  end

  describe "#sanitize" do
    it "returns nil for protocol only urls" do
      url = "http://"
      expect(task.sanitize(url)).to be_nil
    end

    it "returns nil for blank urls" do
      url = ""
      expect(task.sanitize(url)).to be_nil
    end

    it "removes query parameters" do
      url = "http://test.com/path?item=1"
      expect(task.sanitize(url)).to eq "http://test.com/path"
    end

    it "removes fragments" do
      url = "http://test.com/path#item"
      expect(task.sanitize(url)).to eq "http://test.com/path"
    end

    it "adds http if there is no protocol" do
      url = "test.com"
      expect(task.sanitize(url)).to eq "http://test.com"
    end
  end

  describe "#query_severity_for" do
    it "returns nil for a severity of 1" do
      expect(task.query_severity_for(1)).to be_nil
    end

    it "returns 5 for a severity of 5" do
      expect(task.query_severity_for(5)).to eq "5"
    end

    it "returns 3,4,5 for a severity of 3" do
      expect(task.query_severity_for(3)).to eq "3,4,5"
    end

    it "raises an ArgumentError for values below 1" do
      expect { task.query_severity_for(0) }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError for values above 5" do
      expect { task.query_severity_for(10) }.to raise_error(ArgumentError)
    end

    it "accepts integers as strings" do
      expect(task.query_severity_for("2")).to eq "2,3,4,5"
    end

    it "rejects non-integer strings" do
      expect { task.query_severity_for("foobar") }.to raise_error(ArgumentError)
    end
  end
end
