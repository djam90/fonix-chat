require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  def connect_as(user)
    warden = instance_double(Warden::Proxy)
    allow(warden).to receive(:user).with(:user).and_return(user)

    connect "/cable", env: { "warden" => warden }
  end

  it "connects a signed in, confirmed user" do
    user = create(:user)

    connect_as user

    expect(connection.current_user).to eq(user)
  end

  it "rejects a connection without a signed in user" do
    expect { connect_as nil }.to have_rejected_connection
  end

  it "rejects an unconfirmed user" do
    expect { connect_as create(:user, :unconfirmed) }.to have_rejected_connection
  end
end
