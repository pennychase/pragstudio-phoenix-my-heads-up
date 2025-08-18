defmodule MyHeadsUp.Incident do
  defstruct [:id, :name, :description, :priority, :status, :image_path] 
end

defmodule MyHeadsUp.Incidents do
  
  def list_incidents do
    [
      %MyHeadsUp.Incident {
        id: 1,
        name: "Lost Dog",
        description: "A friendly dog is wandering around the neighborhood. 🐶",
        priority: 2,
        status: :pending,
        image_path: "/images/lost-dog.jpg"
      },
      %MyHeadsUp.Incident {
        id: 2,
        name: "Flat Tire",
        description: "Our beloved ice cream truck has a flat tire! 🛞",
        priority: 1,
        status: :resolved,
        image_path: "/images/flat-tire.jpg"
      },
      %MyHeadsUp.Incident {
        id: 3,
        name: "Bear in the Trash",
        description: "A curious bear is digging through the trash! 🐻",
        priority: 1,
        status: :canceled,
        image_path: "/images/bear-in-trash.jpg"
      }
    ]
  end

  def get_incident(id) when is_integer(id) do
    Enum.find(list_incidents(), fn t -> t.id == id end)
  end

  def get_incident(id) when is_binary(id) do
    id |> String.to_integer() |> get_incident()
  end

  def urgent_incidents(incident) do
    list_incidents() |> List.delete(incident)
  end

end