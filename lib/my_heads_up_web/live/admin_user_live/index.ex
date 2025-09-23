defmodule MyHeadsUpWeb.AdminUserLive.Index do
   use MyHeadsUpWeb, :live_view

  alias MyHeadsUp.Admin
  import MyHeadsUpWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Listing Users")
      |> stream(:users, Admin.list_users())

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="admin-user-index">
        <.table id="users" 
                rows={@streams.users}
        >
          <:col :let={{_dom_id, user}} label="Username">
            <%= user.username %>
          </:col>
          <:col :let={{_dom_id, user}} label="Email">
            <%= user.email %>
          </:col>
          <:col :let={{_dom_id, user}} label="Admin?">
            <%= user.is_admin %>
          </:col>
        <:action :let={{_dom_id, user}}>
          <.link phx-click="toggle-admin-status" phx-value-id={user.id}>
            Toggle Admin Status
          </.link>
        </:action>

        </.table>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("toggle-admin-status", %{"id" => id}, socket) do
    user = Admin.get_user!(id)
    current_user = socket.assigns.current_scope.user

    case Admin.toggle_admin_status(user, current_user) do
      {:ok, user} ->
        socket =
          socket
          |> put_flash(:info, "Changed User's Admin Status!")
          |> stream_insert(:users, user)

        {:noreply, socket}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, error)}
    end
  end


end