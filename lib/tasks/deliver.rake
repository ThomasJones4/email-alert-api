namespace :deliver do
  def test_email
    OpenStruct.new(subject: "Test email", body: "This is a test email.")
  end

  desc "Send a test email to a subscriber by id"
  task :to_subscriber, [:id] => :environment do |_t, args|
    subscriber = Subscriber.find(args[:id])
    email = test_email
    DeliverToSubscriber.call(subscriber: subscriber, email: email)
  end

  desc "Send a test email to an email address"
  task :to_test_email, [:test_email_address] => :environment do |_t, args|
    subscriber = Subscriber.new(address: args[:test_email_address])
    email = test_email
    DeliverToSubscriber.call(subscriber: subscriber, email: email)
  end
end
