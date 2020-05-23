defmodule Postoffice.Repo.Migrations.CreateSubscriptionIngestion do
  use Ecto.Migration

  def change do
    create table(:subscription_ingestion) do
      add :topic_id, references(:topics), null: false
      add :subscription_id, references(:subscriptions), null: false

      timestamps()
    end

    create unique_index(:subscription_ingestion, [:topic_id, :subscription_id],
             name: :index_topic_to_subscription
           )
  end
end
