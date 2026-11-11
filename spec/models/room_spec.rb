require "rails_helper"

RSpec.describe Room do
  it "requires a unique name regardless of case" do
    create(:room, name: "random")

    expect(build(:room, name: "Random")).not_to be_valid
    expect(build(:room, name: " ")).not_to be_valid
  end

  describe ".general" do
    it "creates the general room once and then reuses it" do
      general = described_class.general

      expect(general.name).to eq("general")
      expect(described_class.general).to eq(general)
      expect(described_class.count).to eq(1)
    end
  end
end
