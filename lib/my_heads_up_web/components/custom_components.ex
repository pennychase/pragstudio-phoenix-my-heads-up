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
  
end

