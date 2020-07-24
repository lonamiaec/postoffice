defmodule Postoffice.PubSubIngester.PubSubIngester do
  alias Postoffice.PubSubIngester.PubSubClient

  def run(%{topic: topic_name, pubsub_topic: pubsub_topic_name}) do
    conn = PubSubClient.connect()

    PubSubClient.get(conn, %{
      topic: topic_name,
      sub: "#{subscription_prefix}-#{pubsub_topic_name}"
    })
    |> case do
      {:ok, messages} ->
        ingest_messages({:ok, messages})
        |> confirm(conn, "#{subscription_prefix}-#{pubsub_topic_name}")

      error ->
        error
    end
  end

  def get_messages(%{topic: topic_name, pubsub_subscription: pubsub_subscription}) do
    conn = PubSubClient.connect()

    PubSubClient.get(conn, %{
      topic: topic_name,
      sub: pubsub_subscription
    })
    |> case do
      {:ok, messages} ->
        {:ok, messages}

      error ->
        error
    end
  end

  defp ingest_messages({:ok, []} = response), do: response

  defp ingest_messages({:ok, messages}) do
    Enum.map(messages, fn message ->
      {:ok, _message} = Postoffice.receive_message(message)
      message["ackId"]
    end)
  end

  defp confirm({:ok, []}, _conn, _sub_name), do: {:ok, []}

  defp confirm(ackIds, conn, sub_name), do: PubSubClient.confirm(conn, sub_name, ackIds)
  defp subscription_prefix, do: System.get_env("SUBSCRIPTION_PREFIX")
end
