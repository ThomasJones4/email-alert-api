RSpec.describe DailyDigestInitiatorWorker do
  describe ".perform" do
    it "calls the daily digest initiator service" do
      expect(DigestInitiatorService).to receive(:call)
        .with(range: Frequency::DAILY)

      subject.perform
    end
  end
end
