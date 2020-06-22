defmodule PostofficeWeb.Api.SearchController do
  use PostofficeWeb, :controller

  alias Postoffice.Messaging

  def show(conn, %{"id" => id}) do
    conn
    |> render("message.json", message: Messaging.get_message!(id))
  end
end
