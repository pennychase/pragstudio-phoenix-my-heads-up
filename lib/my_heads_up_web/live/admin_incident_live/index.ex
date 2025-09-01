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
    <div class="admin-index">
      <.header>
        <%= @page_title %>
        <:actions>
          <.link navigate={~p"/admin/incidents/new"} class="button">
            New Incident
          </.link>
        </:actions>
      </.header>
      <.table id="incidents" rows={@streams.incidents}>
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
      <:action :let={{_dom_id, incident}}>
        <.link phx-click="delete" phx-value-id={incident.id} data-confirm="Are you sure?">
          <.icon name="hero-trash" class="h-4 w-4" />
        </.link>
      </:action>
      </.table>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    incident = Admin.get_incident!(id)

    {:ok, _} = Admin.delete_incident(incident)

    {:noreply, stream_delete(socket, :incidents, incident)}

  end
  
end