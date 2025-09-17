defmodule MyHeadsUp.Responses.Response do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responses" do
    field :note, :string
    field :status, Ecto.Enum, values: [:enroute, :arrived, :departed]
 
    belongs_to :incident, MyHeadsUp.Incidents.Incident
    belongs_to :user, MyHeadsUp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(response, attrs, user_scope) do
    changeset =
      response
      |> cast(attrs, [:note, :status])
      |> validate_required([:status])
      |> validate_length(:note, max: 500)
      |> assoc_constraint(:incident)
      |> assoc_constraint(:user)
    
    if user_scope && user_scope.user do
      changeset =
        changeset |> put_change(:user_id, user_scope.user.id)
    end

    changeset
  end
end
