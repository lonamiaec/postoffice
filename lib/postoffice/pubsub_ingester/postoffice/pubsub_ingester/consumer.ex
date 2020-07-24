defmodule Postoffice.PubSubIngester.Consumer do
  use Broadway

  alias Broadway.Message
  alias Postoffice.PubSubIngester.PubSubIngester

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Postoffice.PubSubIngester.Producer, :ok},
        transformer: {__MODULE__, :transform, []}
      ],
      processors: [
        default: [concurrency: 5]
      ]
    )
  end

  @impl true
  def handle_message(:default, message, _context) do
    IO.inspect(message, label: "en el handle_message")
    {:ok, pubsub_messages} = PubSubIngester.get_messages(message.data)

    ingested_message =
      pubsub_messages
      |> Enum.map(fn m ->
        %{"ackId" => m["ackId"], "topic" => m["topic"]}
      end)

    message
    |> Message.update_data(fn data ->
      ingested_message
    end)
  end

  def transform(event, _opts) do
    IO.inspect(event, label: "llego al transform!!!!")
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, successful, failed) do
    pubsub_messages =
      Enum.map(successful, fn message ->
        message.data
      end)
      |> List.flatten()
      |> Enum.group_by(fn message -> message["topic"] end)

    IO.inspect(pubsub_messages, label: "Habrá funcionado?????")
    :ok
  end
end
