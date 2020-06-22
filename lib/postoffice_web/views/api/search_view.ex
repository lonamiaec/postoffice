defmodule PostofficeWeb.Api.SearchView do
  use PostofficeWeb, :view

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      attributes: message.attributes,
      payload: message.payload
    }
  end
end
