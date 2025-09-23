defmodule MyHeadsUp.Admin do
  alias Hex.API.User
  alias MyHeadsUp.Incidents
  alias MyHeadsUp.Incidents.Incident
  alias MyHeadsUp.Accounts.User
  alias MyHeadsUp.Repo
  import Ecto.Query

  ## Admin Incidents

  def get_incident!(id) do
    Repo.get!(Incident, id)
  end

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
  
  def update_incident(%Incident{} = incident, attrs) do
    incident
    |> Incident.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, incident} ->
        incident = Repo.preload(incident, [:category, :heroic_response, heroic_response: :user])
        Incidents.broadcast(incident.id, {:incident_updated, incident})
        {:ok, incident}
      {:error, _} = error -> error
    end

  end

  def delete_incident(%Incident{} = incident) do
    Repo.delete(incident)
  end

  def draw_heroic_response(%Incident{status: :resolved} = incident) do
    incident = Repo.preload(incident, :responses)

    case incident.responses do
      [] ->
        {:error, "No responses to draw!"}

      responses ->
        response = Enum.random(responses)

        {:ok, _incident} = update_incident(incident, %{heroic_response_id: response.id})
    end
  end

  def draw_heroic_response(%Incident{}) do
    {:error, "Incident must be respolved to draw a heroic response!"}
  end

  ## Admin Users

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def list_users do
    User
    |> Repo.all()
  end 

  def update_user(%User{} = user, attrs) do
    user
    |> User.is_admin_changeset(attrs)
    |> Repo.update()
  end

  def toggle_admin_status(user, current_user) do
    if user.id == current_user.id do
      {:error, "Can't change your own admin status!"}
    else
      {:ok, _user} = update_user(user, %{is_admin: !user.is_admin})
    end
       
  end

end
