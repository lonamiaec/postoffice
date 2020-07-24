defmodule Postoffice.PubSubIngester.Producer do
  use GenStage
  require Logger

  alias Postoffice.Dispatch
  alias Postoffice.Messaging

  @rescuer_interval 1000 * 3

  def start_link(_args) do
    Logger.info("Starting subscription producer")
    GenStage.start_link(__MODULE__, :ok, name: :pubsub_ingester_producer)
  end

  @impl true
  def init(:ok) do
    send(self(), :populate_state)

    {:producer, {:queue.new(), 0}}
  end

  @impl true
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    Logger.info("Entro en el handle_demand!!")
    {events, state} = Dispatch.dispatch_events(queue, incoming_demand + pending_demand, [])

    {:noreply, events, state}
  end

  @impl true
  def handle_info(:populate_state, {queue, pending_demand} = _state) do
    Process.send_after(self(), :populate_state, @rescuer_interval)

    # pubsub_subscription = Messaging.get_pubsub_subscriptions()
    pubsub_subscription = []

    queue =
      Enum.reduce(pubsub_subscription, queue, fn subscription, acc ->
        :queue.in(subscription, acc)
      end)

    {events, state} = Dispatch.dispatch_events(queue, pending_demand, [])
    {:noreply, events, state}
  end
end
