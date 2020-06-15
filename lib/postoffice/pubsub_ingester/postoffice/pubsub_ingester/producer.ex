defmodule Postoffice.PubSubIngester.Producer do
  use GenStage
  require Logger

  alias Postoffice.Dispatch
  alias Postoffice.Messaging

  @rescuer_interval 1000 * 30

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
    IO.inspect(pending_demand, label: "Entro en el handle_info, a ver que sale!")
    Process.send_after(self(), :populate_state, @rescuer_interval)

    pubsub_subscription = Messaging.get_pubsub_subscriptions()

    queue = Enum.reduce(pubsub_subscription, queue, fn subscription, acc ->
        :queue.in(subscription, acc)
      end)
    IO.inspect(queue, label: "la Queue que vale...")

    {events, state} = Dispatch.dispatch_events(queue, pending_demand, [])
    IO.inspect(events, label: "Los eventos generados han sido estos...")
    IO.inspect(state, label: "Los state generados han sido estos...")
    {:noreply, events, state}
  end
end
