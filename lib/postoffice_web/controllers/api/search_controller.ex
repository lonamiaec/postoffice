defmodule PostofficeWeb.Api.SearchController do
  use PostofficeWeb, :controller

  def show(conn, _) do
    conn
    |> put_status(:not_found)
    |> json(%{})
  end
end
