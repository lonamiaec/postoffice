defmodule Postoffice.PubSubIngester.IngesterBroadwayTest do
  use Postoffice.DataCase, async: true
  use ExUnit.Case, async: true

  import Mox

  alias Postoffice.Fixtures
  alias Postoffice.Messaging
  alias Postoffice.Messaging.PendingMessage
  alias Postoffice.PubSubIngester.PubSubIngester
  alias Postoffice.PubSubIngester.Adapters.PubSubMock

  setup [:set_mox_global, :verify_on_exit!]

  setup do
    System.put_env("SUBSCRIPTION_PREFIX", "prefix")
    {:ok, pubsub_conn: Fixtures.pubsub_conn()}
  end

  @acks_ids [
    "ISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFEAcGTwIoXXkyVSFBXBoHUQ0Zcnxmd2tTGwMKEwUtVVsRDXptXFcnUAwccHxhcm1dEwIBQlJ4W3OK75niloGyYxclSoGxxaxvM7nUxvhMZho9XhJLLD5-MjVFQV5AEkw5AERJUytDCypYEU4E",
    "ISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFEAcGTwIoXXkyVSFBXBoHUQ0Zcnxmd2tTGwMKEwUtVVoRDXptXFcnUAwccHxhcm9eEwQFRFt-XnOK75niloGyYxclSoGxxaxvM7nUxvhMZho9XhJLLD5-MjVFQV5AEkw5AERJUytDCypYEU4E"
  ]

  @argument %{
    topic: "test",
    pubsub_topic: "fake-sub"
  }

  describe "one" do
    test "two", %{pubsub_conn: pubsub_conn} do
      topic = Fixtures.create_topic()
      Fixtures.create_publisher(topic)

      # expect(PubSubMock, :connect, fn -> pubsub_conn end)
      expect(PubSubMock, :get, fn _pubsub_conn, "lll" ->
        Fixtures.two_google_pubsub_messages()
      end)

      expect(PubSubMock, :confirm, fn _pubsub_conn, @acks_ids, "prefix-fake-sub" ->
        Fixtures.google_ack_message()
      end)

      expect(PubSubMock, :connect, fn ->
        pubsub_conn
      end)

      ref = Broadway.test_message(Postoffice.PubSubIngester.Consumer, %{topic: "bem", pubsub_subscription: "lll"})

      assert_receive {:ack, ^ref, messages = [%{data: [%{"ackId" => "ISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFEAcGTwIoXXkyVSFBXBoHUQ0Zcnxmd2tTGwMKEwUtVVsRDXptXFcnUAwccHxhcm1dEwIBQlJ4W3OK75niloGyYxclSoGxxaxvM7nUxvhMZho9XhJLLD5-MjVFQV5AEkw5AERJUytDCypYEU4E", "topic" => "bem"}, %{"ackId" => "ISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFEAcGTwIoXXkyVSFBXBoHUQ0Zcnxmd2tTGwMKEwUtVVoRDXptXFcnUAwccHxhcm9eEwQFRFt-XnOK75niloGyYxclSoGxxaxvM7nUxvhMZho9XhJLLD5-MjVFQV5AEkw5AERJUytDCypYEU4E", "topic" => "bem"}]}], []}

      IO.inspect(messages, label: "Vaaaamos")

      assert 1 == 2
    end

    # test "threeeee", %{pubsub_conn: pubsub_conn} do
    #   topic = Fixtures.create_topic()
    #   Fixtures.create_publisher(topic)


    #   Postoffice.PubSubIngester.Consumer.ack(:ack_id, [%{"ackId" => "ISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFEAcGTwIoXXkyVSFBXBoHUQ0Zcnxmd2tTGwMKEwUtVVsRDXptXFcnUAwccHxhcm1dEwIBQlJ4W3OK75niloGyYxclSoGxxaxvM7nUxvhMZho9XhJLLD5-MjVFQV5AEkw5AERJUytDCypYEU4E", "topic" => "bem"}, %{"ackId" => "ISE-MD5FU0RQBhYsXUZIUTcZCGhRDk9eIz81IChFEAcGTwIoXXkyVSFBXBoHUQ0Zcnxmd2tTGwMKEwUtVVoRDXptXFcnUAwccHxhcm9eEwQFRFt-XnOK75niloGyYxclSoGxxaxvM7nUxvhMZho9XhJLLD5-MjVFQV5AEkw5AERJUytDCypYEU4E", "topic" => "bem"}], [])
    # end
  end
end
