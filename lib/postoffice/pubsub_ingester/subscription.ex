defmodule Postoffice.PubSubIngester.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :name, :string, null: false

    timestamps()
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
