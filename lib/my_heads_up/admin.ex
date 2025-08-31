defmodule MyHeadsUp.Admin do
  alias MyHeadsUp.Incidents
  alias MyHeadsUp.Incidents.Incident
  alias MyHeadsUp.Repo
  import Ecto.Query

  def list_incidents do
    Incident
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_incident(attrs \\ %{}) do
    %Incident{}
    |> Incident.changeset(attrs)
    |> Repo.insert()
  end

  def change_incident(%Incident{} = incident, attrs \\ %{}) do
    Incident.changeset(incident, attrs)
  end
  
  def get_incident!(id) do
    Repo.get!(Incident, id)
  end
end