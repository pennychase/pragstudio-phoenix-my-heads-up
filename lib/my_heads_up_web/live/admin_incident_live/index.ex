defmodule MyHeadsUpWeb.AdminIncidentLive.Index do

  use MyHeadsUpWeb, :live_view

  alias MyHeadsUp.Admin
  import MyHeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Incidents")
      |> stream(:incidents, Admin.list_incidents())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-index">
        <.button phx-click ={
          JS.toggle(
            to: "#joke",
            in: {"ease-in-out duration-300", "opacity-0", "opacity-100"},
            out: {"ease-in-out duration-300", "opacity-100", "opacity-0"},
            time: 300
          )
        }>
          Toggle Joke
        </.button>
        <div id="joke" class="joke hidden" phx-click={JS.toggle_class("animate-bounce")}>
          Why shouldn't you trust trees?
        </div>
        <.header>
          <:actions>
            <.link navigate={~p"/admin/incidents/new"} class="button">
              New Incident
            </.link>
          </:actions>
        </.header>
        <.table id="incidents" 
                rows={@streams.incidents}
                row_click={fn {_, incident} -> JS.navigate(~p"/incidents/#{incident}") end}>
          <:col :let={{_dom_id, incident}} label="Name">
            <.link navigate={~p"/incidents/#{incident}"}>
              <%= incident.name %>
            </.link>
          </:col>
          <:col :let={{_dom_id, incident}} label="Status">
            <.badge status={incident.status} />
          </:col>
          <:col :let={{_dom_id, incident}} label="Priority">
            <%= incident.priority %>
          </:col>
        <:action :let={{_dom_id, incident}}>
          <.link navigate={~p"/admin/incidents/#{incident}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{dom_id, incident}}>
          <.link phx-click={JS.push("delete", value: %{id: incident.id})
                            |> JS.hide(to: "##{dom_id}", transition: "fade-out")
                          } phx-value-id={incident.id} data-confirm="Are you sure?">
            <.icon name="hero-trash" class="h-4 w-4" />
          </.link>
        </:action>
        </.table>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    incident = Admin.get_incident!(id)

    {:ok, _} = Admin.delete_incident(incident)

    {:noreply, stream_delete(socket, :incidents, incident)}

  end
  
end