require "rails_helper"
require "notifications/client"
require "app/services/email_sender/email_sender_service"

RSpec.describe EmailSenderService do
  it "sends an email to the override email address" do
    config = { provider: "NOTIFY", email_address_override: "override@example.com" }

    notify = instance_double("Notify")

    expect(notify).to receive(:call).with(
      hash_including(address: "override@example.com")
    )

    email_sender = EmailSenderService.new(config, notify)

    email_sender.call(address: "test@test.com", subject: "subject", body: "body")
  end
end
