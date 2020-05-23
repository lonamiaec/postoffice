defmodule Postoffice.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :name, :string

      timestamps()
    end
  end
end
