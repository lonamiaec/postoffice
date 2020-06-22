defmodule PostofficeWeb.Api.SearchControllerTest do
  use PostofficeWeb.ConnCase, async: true

  describe "the search endpoint" do
    test "returns 404 when requested with a message id that is not found", %{conn: conn} do
      conn = get(conn, Routes.api_search_path(conn, :show, 999))

      assert json_response(conn, 404) == %{}
    end

    test "returns 200 when requested with a message id that is found", %{conn: conn} do
      topic = Postoffice.Fixtures.create_topic(%{name: "interesting-topic", origin_host: "example.com", recovery_enabled: true})
      message_data = %{
        attributes: %{
          section: "science"
        },
        payload: %{
          title: "Scientifics discover life on Mars",
          text: "Aliens are spying us..."
        }
      }
      message = Postoffice.Fixtures.add_message_to_deliver(topic, message_data)

      conn = get(conn, Routes.api_search_path(conn, :show, message.id))

      assert json_response(conn, 200) == %{
        "id" => message.id,
        "attributes" => %{
          "section" => "science"
        },
        "payload" => %{
          "title" => "Scientifics discover life on Mars",
          "text" => "Aliens are spying us..."
        }
      }
    end
  end
end
