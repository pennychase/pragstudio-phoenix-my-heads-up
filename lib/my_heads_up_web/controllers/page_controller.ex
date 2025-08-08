defmodule MyHeadsUpWeb.PageController do
  use MyHeadsUpWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
