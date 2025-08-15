defmodule MyHeadsUpWeb.IncidentLive.Index do
  use MyHeadsUpWeb, :live_view

  alias MyHeadsUp.Incidents
  import MyHeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket = assign(socket, :incidents, Incidents.list_incidents())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="incident-index">
      <div class="incidents">
        <.incident_card :for={incident <- @incidents} incident={incident} />
      </div>
    </div>
    """
  end

  attr :incident, MyHeadsUp.Incident, required: true

  def incident_card(assigns) do
    ~H"""
    <div class="card">
      <img src={@incident.image_path} />
      <h2>{@incident.name}</h2>
      <div class="details">
        <div class="badge">
          <.badge status={@incident.status} />
        </div>
        <div class="priority">
          {@incident.priority}
        </div>
      </div>
    </div>
    """   
  end

  
end