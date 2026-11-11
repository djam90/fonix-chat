require "rails_helper"

RSpec.describe DigestMailerHelper do
  describe "#digest_date" do
    it "formats dates like the brief, adding the year when it isn't this year" do
      travel_to Time.zone.parse("2026-03-10 12:00") do
        expect(helper.digest_date(Time.zone.parse("2026-02-01 09:00"))).to eq("1st of February")
        expect(helper.digest_date(Time.zone.parse("2025-12-22 09:00"))).to eq("22nd of December 2025")
      end
    end
  end
end
