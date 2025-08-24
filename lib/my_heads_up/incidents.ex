defmodule MyHeadsUp.Incidents do

  alias MyHeadsUp.Incidents
  alias MyHeadsUp.Incidents.Incident
  alias MyHeadsUp.Repo
  import Ecto.Query
  
  def list_incidents do
    Repo.all(Incident)
  end

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

  def filter_incidents do
    Incident
    |> where([i], ilike(i.name, "%in%"))
    |> order_by(desc: :name)
    |> Repo.all()
  end 

  def urgent_incidents(incident) do
    Incident
    |> where(status: :pending)
    |> where([i], i.id != ^incident.id)
    |> limit(3)
    |> order_by(asc: :priority)
    |> Repo.all()
  end

  def get_values(field) do
    Ecto.Enum.values(Incidents.Incident, field)
  end

end