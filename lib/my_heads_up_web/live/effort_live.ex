defmodule MyHeadsUpWeb.EffortLive do
  use MyHeadsUpWeb, :live_view

  def mount(_params, _session, socket) do

    socket = assign(socket, responders: 0, minutes_per_responder: 10)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="effort">
    <h1>Community Love</h1>
      <section>
        <div>
          <%= @responders %>
        </div>
        &times;
        <div>
          <%= @minutes_per_responder %>
        </div>
        =
        <div>
          <%= @responders * @minutes_per_responder %>
        </div>
      </section>
    </div>
    """
  end
  
end