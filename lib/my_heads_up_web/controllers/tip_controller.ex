defmodule MyHeadsUpWeb.TipController do
  use MyHeadsUpWeb, :controller

  alias MyHeadsUp.Tips

  def index(conn, _params) do

    emojis = ~w(💚 💜 💙) |> Enum.random() |> String.duplicate(5)
    
    tips = Tips.list_tips()

    render(conn, :index, emojis: emojis, tips: tips)
  end

  def show(conn, %{"id" => id}) do
    tip = Tips.get_tip(id)

    render(conn, :show, tip: tip)
  end
  
end