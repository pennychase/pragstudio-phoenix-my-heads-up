defmodule MyHeadsUpWeb.CustomComponents do

  use MyHeadsUpWeb, :html

  attr :badge, :atom, values: [:pending, :resolved, :canceled], default: :pending
  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <div class=
    {["rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status==:resolved && "text-lime-600 border-lime-600",
      @status==:pending && "text-lime-600 border-amber-600",
      @status==:canceled && "text-lime-600 border-gray-600",
      @class
    ]}>
      {@status}
    </div>
    """
  end

  slot :inner_block, required: true
  slot :tagline

  def headline(assigns) do
    assigns = assign(assigns, :emoji, ~w(👍 🙌 👊) |> Enum.random())

    ~H"""
    <div class="headline">
      <h1>
        {render_slot(@inner_block)}
      </h1>
      <div :for={tagline <- @tagline} class="tagline">
        {render_slot(tagline, @emoji)}
      </div>
    </div>
    """

  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end
  
end

