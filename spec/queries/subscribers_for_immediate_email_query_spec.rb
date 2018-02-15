require "rails_helper"

RSpec.describe SubscribersForImmediateEmailQuery do
  it "returns Subscriber objects that have an email-less SubscriptionContent" do
    create(:subscription_content, email: nil)
    expect(described_class.call.count).to eq(1)
  end

  it "does not return Subscriber objects with email_id != nil" do
    create(:subscription_content, email: build(:email))
    expect(described_class.call.count).to eq(0)
  end

  it "does not return Subscriber for subscribers with nil addresses" do
    create(:subscription_content, subscription: create(:subscription, subscriber: create(:subscriber, address: nil)))
    expect(described_class.call.count).to eq(0)
  end

  it "only associates subscription_contents with nil emails" do
    create(:subscription_content, subscription: create(:subscription, subscriber: subscriber = create(:subscriber)))
    create(:subscription_content, subscription: create(:subscription, subscriber: subscriber))

    create(:subscription_content, email: create(:email), subscription: create(:subscription, subscriber: subscriber))

    subscriber = described_class.call.first
    expect(subscriber.unprocessed_subscription_contents.count).to eq(2)
  end

  it "returns one record per subscriber" do
    create(:subscription_content, subscription: create(:subscription, subscriber: subscriber = create(:subscriber)))
    create(:subscription_content, subscription: create(:subscription, subscriber: subscriber))

    create(:subscription_content, email: create(:email), subscription: create(:subscription, subscriber: subscriber))

    expect(described_class.call.count).to eq(1)
  end
end
