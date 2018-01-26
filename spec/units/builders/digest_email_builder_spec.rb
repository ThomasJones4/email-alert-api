require "rails_helper"
RSpec.describe DigestEmailBuilder do
  let(:digest_run) { double(daily?: true) }
  let(:subscriber) { build(:subscriber) }
  let(:subscription_content_change_results) {
    [
      double(
        subscription_id: 1,
        subscription_uuid: "ABC1",
        subscriber_list_title: "Test title 1",
        content_changes: [
          build(:content_change, public_updated_at: "1/1/2016 10:00"),
          build(:content_change, public_updated_at: "2/1/2016 11:00"),
          build(:content_change, public_updated_at: "3/1/2016 12:00"),
        ],
      ),
      double(
        subscription_id: 2,
        subscription_uuid: "ABC2",
        subscriber_list_title: "Test title 2",
        content_changes: [
          build(:content_change, public_updated_at: "4/1/2016 10:00"),
          build(:content_change, public_updated_at: "5/1/2016 11:00"),
          build(:content_change, public_updated_at: "6/1/2016 12:00"),
        ],
      ),
    ]
  }

  let(:email) {
    described_class.call(
      subscriber: subscriber,
      digest_run: digest_run,
      subscription_content_change_results: subscription_content_change_results,
    )
  }

  it "returns an Email" do
    expect(email).to be_a(Email)
  end

  it "adds an entry to body for each content change" do
    expect(UnsubscribeLinkPresenter).to receive(:call).with(
      uuid: "ABC1",
      title: "Test title 1"
    ).and_return("unsubscribe_link_1")

    expect(UnsubscribeLinkPresenter).to receive(:call).with(
      uuid: "ABC2",
      title: "Test title 2"
    ).and_return("unsubscribe_link_2")

    expect(ContentChangePresenter).to receive(:call).exactly(6).times
      .and_return("presented_content_change\n")

    expect(email.body).to eq(
      <<~BODY
        #Test title 1

        presented_content_change

        ---

        presented_content_change

        ---

        presented_content_change

        ---

        unsubscribe_link_1

        &nbsp;

        #Test title 2

        presented_content_change

        ---

        presented_content_change

        ---

        presented_content_change

        ---

        unsubscribe_link_2
      BODY
    )
  end

  context "daily" do
    it "sets the subject" do
      expect(email.subject).to eq("GOV.UK Daily Update")
    end
  end

  context "weekly" do
    let(:digest_run) { double(daily?: false) }
    it "sets the subject" do
      expect(email.subject).to eq("GOV.UK Weekly Update")
    end
  end
end