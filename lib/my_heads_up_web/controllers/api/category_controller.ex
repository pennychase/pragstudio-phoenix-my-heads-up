defmodule MyHeadsUpWeb.Api.CategoryController do
  use MyHeadsUpWeb, :controller

  alias MyHeadsUp.Categories

  def show(conn, %{"id" => id}) do
    category = Categories.get_category_with_incidents!(id)

    render(conn, :show, category: category)
  end
end