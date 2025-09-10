defmodule MyHeadsUpWeb.Api.IncidentController do
  use MyHeadsUpWeb, :controller

  alias MyHeadsUp.Admin

  def index(conn, _params) do
    incidents = Admin.list_incidents()

    render(conn, :index, incidents: incidents)
  end

  def show(conn, %{"id" => id}) do
    incident = Admin.get_incident!(id)

    render(conn, :show, incident: incident)
  end
  
end