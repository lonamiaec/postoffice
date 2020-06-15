defmodule PostofficeWeb.Api.SearchControllerTest do
  use PostofficeWeb.ConnCase, async: true

  alias Postoffice.Messaging

  describe "the search endpoint" do
    test "returns 404 when requested with a message id that is not found", %{conn: conn} do
      conn = get(conn, Routes.api_search_path(conn, :show, 999))

      assert json_response(conn, 404)
    end
  end
end
