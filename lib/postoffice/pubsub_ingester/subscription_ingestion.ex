defmodule Postoffice.PubSubIngester.SubscriptionIngestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscription_ingestion" do
    belongs_to :topic, Postoffice.Messaging.Topic
    belongs_to :subscription, Postoffice.PubSubIngester.Subscription

    timestamps()
  end

  @doc false
  def changeset(subscription_ingestion, attrs) do
    subscription_ingestion
    |> cast(attrs, [:topic_id, :subscription_id])
    |> validate_required([:topic_id, :subscription_id])
    |> unique_constraint(:topic_id, name: :index_topic_to_subscription)
  end
end
