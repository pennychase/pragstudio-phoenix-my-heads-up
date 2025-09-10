 defmodule MyHeadsUpWeb.Api.CategoryJSON do
  def show(%{category: category}) do
    %{category: data(category)}
  end

  defp data(category) do
    %{
      id: category.id,
      name: category.name,
      slug: category.slug,
      incidents: for(incident <- category.incidents,
        do: %{id: incident.id,
              name: incident.name,
              description: incident.description,
              status: incident.status,
              priority: incident.priority
            }
        )
    }
  end
   
 end