class Subscription < ApplicationRecord
  belongs_to :subscriber
  belongs_to :subscriber_list

  has_many :subscription_contents

  enum frequency: { immediately: 0, daily: 1, weekly: 2 }
  enum source: { user_signed_up: 0, frequency_changed: 1, imported: 2, subscriber_list_changed: 3 }, _prefix: true
  enum ended_reason: { unsubscribed: 0, non_existant_email: 1, frequency_changed: 2, subscriber_list_changed: 3, marked_as_spam: 4 }, _prefix: :ended

  validates_uniqueness_of :subscriber, scope: :subscriber_list, conditions: -> { active }

  scope :active, -> { where(ended_at: nil) }
  scope :ended, -> { where.not(ended_at: nil) }

  def as_json(options = {})
    options[:except] ||= %i(signon_user_uid subscriber_list_id subscriber_id)
    options[:include] ||= %i(subscriber_list subscriber)
    super(options)
  end

  def active?
    ended_at.nil?
  end

  def ended?
    ended_at.present?
  end

  def end(reason:, datetime: nil)
    raise "Already ended." if ended?

    update!(
      ended_reason: reason,
      ended_at: datetime || Time.now,
    )
  end
end
