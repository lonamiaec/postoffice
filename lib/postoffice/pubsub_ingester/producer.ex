defmodule Postoffice.PubSubIngester.Producer do
  use GenStage
  require Logger

  alias Postoffice.Dispatch
  alias Postoffice.Messaging

  @rescuer_interval 1000 * 30

  def start_link(_args) do
    Logger.info("Starting ingest messages from pubsub producer")
    GenStage.start_link(__MODULE__, :ok, name: :ingestion_producer)
  end

  @impl true
  def init(:ok) do
    send(self(), :populate_state)

    {:producer, {:queue.new(), 0}}
  end

  @impl true
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    {events, state} = Dispatch.dispatch_events(queue, incoming_demand + pending_demand, [])

    {:noreply, events, state}
  end

  @impl true
  def handle_info(:populate_state, {queue, pending_demand} = _state) do
    Process.send_after(self(), :populate_state, @rescuer_interval)

    subscription_to_topics = Messaging.get_subscription_to_topic()

    queue =
      Enum.reduce(subscription_to_topics, queue, fn subscription_to_topic, acc ->
        :queue.in(subscription_to_topic, acc)
      end)

    {events, state} = Dispatch.dispatch_events(queue, pending_demand, [])
    {:noreply, events, state}
  end
end
