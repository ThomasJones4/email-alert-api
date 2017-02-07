require 'json'
require_relative "extensions/symbolize_json"

class SubscriberList < ActiveRecord::Base
  include SymbolizeJSON

  self.include_root_in_json = true

  validate :tag_values_are_valid
  validate :link_values_are_valid
  validate :either_document_type_tags_or_links_present

  def self.build_from(params:, gov_delivery_id:)
    new(
      title: params[:title],
      tags:  params[:tags],
      links: params[:links],
      document_type: params[:document_type],
      gov_delivery_id: gov_delivery_id,
    )
  end

  def subscription_url
    gov_delivery_config.fetch(:protocol) +
    "://" +
    gov_delivery_config.fetch(:public_hostname) +
    "/accounts/" +
    gov_delivery_config.fetch(:account_code) +
    "/subscriber/new?topic_id=" +
    self.gov_delivery_id
  end

  def to_json
    super(methods: :subscription_url)
  end

private
  def tag_values_are_valid
    unless self[:tags].all? { |_, v| v.is_a?(Array) }
      self.errors.add(:tags, "All tag values must be sent as Arrays")
    end
  end

  def link_values_are_valid
    unless self[:links].all? { |_, v| v.is_a?(Array) }
      self.errors.add(:links, "All link values must be sent as Arrays")
    end
  end

  def either_document_type_tags_or_links_present
    return if self[:document_type].present?
    return if self[:tags].present?
    return if self[:links].present?

    self.errors.add(:base, "Must have either a document_type, tags or links")
  end

  def gov_delivery_config
    EmailAlertAPI.config.gov_delivery
  end
end
