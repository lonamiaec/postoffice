defmodule PostofficeWeb.Api.PublisherControllerTest do
  use PostofficeWeb.ConnCase, async: true

  import Ecto.Query, warn: false

  alias Postoffice.Fixtures
  alias Postoffice.Messaging
  alias Postoffice.Messaging.Publisher
  alias Postoffice.Repo
  alias Phoenix.PubSub

  @valid_http_publisher_payload %{
    active: true,
    target: "http://fake.target",
    topic: "test",
    type: "http",
    seconds_timeout: 15,
    seconds_retry: 10
  }

  @valid_pubsub_publisher_payload %{
    active: true,
    target: "test",
    topic: "test",
    type: "pubsub",
    seconds_timeout: 15,
    seconds_retry: 10
  }

  @invalid_http_publisher_payload %{
    active: true,
    target: "http://fake.target",
    topic: "fake_topic",
    type: "http"
  }

  @invalid_publisher_target_payload %{
    active: true,
    target: "",
    topic: "test",
    type: "http"
  }

  @invalid_publisher_type_payload %{
    active: true,
    target: "http://fake.target",
    topic: "test",
    type: "false_type"
  }

  @valid_topic_attrs %{
    name: "test",
    origin_host: "example.com"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp get_last_publisher() do
    from(p in Publisher, order_by: [desc: :id], limit: 1)
    |> Repo.one()
  end

  describe "create publisher" do
    test "create http publisher when data is valid", %{conn: conn} do
      {:ok, topic} = Messaging.create_topic(@valid_topic_attrs)

      conn = post(conn, Routes.api_publisher_path(conn, :create), @valid_http_publisher_payload)

      assert json_response(conn, 201)["data"] == %{}
      assert length(Repo.all(Publisher)) == 1
      created_publisher = get_last_publisher()
      assert created_publisher.active == true
      assert created_publisher.target == "http://fake.target"
      assert created_publisher.topic_id == topic.id
      assert created_publisher.type == "http"
      assert created_publisher.seconds_timeout == 15
      assert created_publisher.seconds_retry == 10
    end

    test "create pubsub publisher when data is valid", %{conn: conn} do
      {:ok, topic} = Messaging.create_topic(@valid_topic_attrs)

      conn = post(conn, Routes.api_publisher_path(conn, :create), @valid_pubsub_publisher_payload)

      assert json_response(conn, 201)["data"] == %{}
      assert length(Repo.all(Publisher)) == 1

      created_publisher = get_last_publisher()
      assert created_publisher.active == true
      assert created_publisher.target == topic.name
      assert created_publisher.topic_id == topic.id
      assert created_publisher.type == "pubsub"
      assert created_publisher.seconds_timeout == 15
      assert created_publisher.seconds_retry == 10
    end

    test "renders errors when topic does not exists", %{conn: conn} do
      conn = post(conn, Routes.api_publisher_path(conn, :create), @invalid_http_publisher_payload)

      assert json_response(conn, 400)["data"] == %{"errors" => %{"topic" => ["is invalid"]}}
    end

    test "renders errors when type does not exists", %{conn: conn} do
      Messaging.create_topic(@valid_topic_attrs)

      conn = post(conn, Routes.api_publisher_path(conn, :create), @invalid_publisher_type_payload)

      assert json_response(conn, 400)["data"] == %{"errors" => %{"type" => ["is invalid"]}}
      assert length(Repo.all(Publisher)) == 0
    end

    test "renders errors when target is empty", %{conn: conn} do
      Messaging.create_topic(@valid_topic_attrs)

      conn =
        post(conn, Routes.api_publisher_path(conn, :create), @invalid_publisher_target_payload)

      assert json_response(conn, 400)["data"] == %{
               "errors" => %{"target" => ["can't be blank"]}
             }

      assert length(Repo.all(Publisher)) == 0
    end

    test "do not create publisher in case it already exists", %{conn: conn} do
      Messaging.create_topic(@valid_topic_attrs)
      post(conn, Routes.api_publisher_path(conn, :create), @valid_http_publisher_payload)

      conn = post(conn, Routes.api_publisher_path(conn, :create), @valid_http_publisher_payload)

      assert json_response(conn, 409)["data"] == %{
               "errors" => %{"target" => ["has already been taken"]}
             }

      assert length(Repo.all(Publisher)) == 1
    end
  end

  describe "delete publisher" do
    test "Delete publisher mark publisher as deleted", %{conn: conn} do
      publisher =
        Fixtures.create_topic()
        |> Fixtures.create_publisher()

      conn = delete(conn, Routes.api_publisher_path(conn, :delete, publisher))

      assert response(conn, 204)

      assert length(Repo.all(Publisher)) == 1
      created_publisher = get_last_publisher()
      assert created_publisher.deleted == true
    end

    test "Delete publisher broadcast the publisher updated", %{conn: conn} do
      PubSub.subscribe(Postoffice.PubSub, "publishers")

      publisher =
        Fixtures.create_topic()
        |> Fixtures.create_publisher()

      delete(conn, Routes.api_publisher_path(conn, :delete, publisher))

      assert_receive {:publisher_deleted, _publisher}
    end

    test "Returns 400 when can not delete publisher", %{conn: conn} do
      Fixtures.create_topic()
      |> Fixtures.create_publisher()

      conn = delete(conn, Routes.api_publisher_path(conn, :delete, %Publisher{id: "100000"}))

      assert response(conn, 400)

      assert length(Repo.all(Publisher)) == 1
      created_publisher = get_last_publisher()
      assert created_publisher.deleted == false
    end
  end
end
