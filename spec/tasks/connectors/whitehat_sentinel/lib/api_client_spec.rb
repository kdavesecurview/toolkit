# frozen_string_literal: true

require "rspec_helper"

RSpec.describe Kenna::Toolkit::WhitehatSentinel::ApiClient do
  subject(:api_client) { described_class.new(api_key: "0xdeadbeef") }

  describe "#vulns" do
    context "when given query conditions" do
      let(:query) { { "query_severity" => 2 } }

      it "includes the condition in the API request" do
        response = {}.to_json
        expect(Kenna::Toolkit::Helpers::Http).to receive(:http_get).with(anything, { params: hash_including(query) }, anything).and_return(response)
        api_client.vulns(query)
      end
    end
  end
end
