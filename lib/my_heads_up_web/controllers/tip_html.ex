defmodule MyHeadsUpWeb.TipHTML do

  use MyHeadsUpWeb, :html

  embed_templates "tip_html/*"

  def show(assigns) do
    ~H"""
    <div class="mt-16 ml-16 tips">
      <h1>You Like a Tip, {@answer}?</h1>
      <p>
        {@tip.text}
      </p>
    </div>
    """
  end
  
end