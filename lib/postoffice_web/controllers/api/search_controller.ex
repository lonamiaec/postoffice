defmodule PostofficeWeb.Api.SearchController do
  use PostofficeWeb, :controller

  alias Postoffice.Messaging
  alias Postoffice.Messaging.Message

  def show(conn, %{"id" => id}) do
    case Messaging.get_message!(id) do
      %Message{} = message -> render(conn, "message.json", message: message)
      _ ->
        conn
        |> put_status(404)
        |> render("not_found.json", conn.assigns)
    end
  end
end
