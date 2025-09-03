defmodule MyHeadsUpWeb.EffortLive do
  use MyHeadsUpWeb, :live_view

  def mount(_params, _session, socket) do
    # IO.inspect(self(), label: "MOUNT")

    # if connected?(socket) do
    #   Process.send_after(self(), :tick, 2000)
    # end

    socket = assign(socket, responders: 0, minutes_per_responder: 10) |> assign(page_title: "Effort")

    {:ok, socket}
  end

  def render(assigns) do
    # IO.inspect(self(), label: "RENDER")

    ~H"""
    <Layouts.app flash={@flash}>
      <div class="effort">
      <h1>Community Love</h1>
        <section>
          <button phx-click="add" phx-value-quantity="3">
            + 3
          </button>
          <div>
            {@responders}
          </div>
          &times;
          <div>
            {@minutes_per_responder}
          </div>
          =
          <div>
            {@responders * @minutes_per_responder}
          </div>
        </section>

        <form phx-submit="recalculate">
          <label>Minutes Per Responder:</label>
          <input type="number" name="minutes_per_responder" value={@minutes_per_responder} />
        </form>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("add", %{"quantity" => quantity}, socket) do
    # IO.inspect(self(), label: "ADD")

    socket = update(socket, :responders, &(&1 + String.to_integer(quantity)))

    {:noreply, socket}
  end

  def handle_event("recalculate", %{"minutes_per_responder" => minutes_per_responder}, socket) do
    socket = assign(socket, :minutes_per_responder, String.to_integer(minutes_per_responder))

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 2000)
    socket = update(socket, :responders, &(&1 + 3))

    {:noreply, socket}
  end
  
end