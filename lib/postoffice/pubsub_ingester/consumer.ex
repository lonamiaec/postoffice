defmodule Postoffice.PubSubIngester.Consumer do
  use GenStage

  alias Postoffice.PubSubIngester.PubSubIngester

  require Logger

  def start_link(topic_to_relation) do
    ingestion_name = "#{topic_to_relation[:topic]}-#{topic_to_relation[:sub]}"
    Logger.info("Starting ingestion from pubsub for #{ingestion_name}")

    GenStage.start_link(__MODULE__, ingestion_name, name: {:via, :swarm, ingestion_name})

    Task.start_link(PubSubIngester, :run, [
      topic_to_relation
    ])
  end

  def init(:ok) do
    {:consumer, %{}}
  end
end
