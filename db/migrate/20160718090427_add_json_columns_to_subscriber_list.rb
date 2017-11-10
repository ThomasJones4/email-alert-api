class AddJsonColumnsToSubscriberList < ActiveRecord::Migration[4.2]
  def change
    add_column :subscriber_lists, :tags_json, :json, default: {}, null: false
    add_column :subscriber_lists, :links_json, :json, default: {}, null: false
  end
end
