require 'bundler'
Bundler.require

Sequel.migration do
  change do
    create_table(:messages) do
      primary_key :id
      foreign_key :original_message, :messages
      String :content, null: false
      Integer :original_message_id
      Time :created_at
      Time :updated_at
    end
  end
end
