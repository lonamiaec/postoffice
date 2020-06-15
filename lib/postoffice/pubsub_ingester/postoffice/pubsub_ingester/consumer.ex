defmodule Postoffice.PubSubIngester.Consumer do
  use Broadway

  alias Broadway.Message
  alias Postoffice.PubSubIngester.PubSubIngester

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Postoffice.PubSubIngester.Producer, :ok},
        transformer: {__MODULE__, :transform, []},
      ],
      processors: [
        default: [concurrency: 5]
      ]
    )
  end

  @impl true
  def handle_message(:default, %{data: data} = message, _context) do
    IO.inspect(message, label: "Que vale mi mensajito!!!")
    IO.inspect(data, label: "Y mi datita?????")
    {:ok, messages} = PubSubIngester.get_messages(data)
    message
    |> Message.update_data(fn data -> messages end)
  end

  def transform(event, _opts) do
    IO.inspect(event, label: "Entro en el transform de mis amores!")
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, successful, failed) do
    IO.inspect(successful, label: "Que todo va beeene")
    IO.inspect(failed, label: "Que todo va maaalmente")
    pubsub_messages = Enum.map(successful, fn message ->
      message.data
    end)
    |> List.flatten
    |> Enum.map(fn  message ->
      %{ackId: message["ackId"], topic: message["topic"]}
    end)
    |> Enum.group_by(fn message -> message[:topic] end)

    IO.inspect(pubsub_messages, label: "Habrá funcionado?????")
    :ok
  end
end