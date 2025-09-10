defmodule MyHeadsUpWeb.Api.ChangesetJSON do
  use MyHeadsUpWeb, :controller

  def error(%{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, &translate_error/1)

    %{errors: errors}
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

end