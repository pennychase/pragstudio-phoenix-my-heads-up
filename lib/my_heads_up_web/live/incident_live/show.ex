defmodule MyHeadsUpWeb.IncidentLive.Show do

  use MyHeadsUpWeb, :live_view

  alias MyHeadsUp.Incidents
  alias MyHeadsUp.Responses
  alias MyHeadsUp.Responses.Response
  alias MyHeadsUpWeb.Presence
  import MyHeadsUpWeb.CustomComponents

  on_mount {MyHeadsUpWeb.UserAuth, :mount_current_scope}

  def mount(_params, _session, socket) do
    changeset = Responses.change_response(%MyHeadsUp.Accounts.Scope{}, %Response{})
    socket = assign(socket, :form, to_form(changeset))

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do

    %{current_scope: current_scope} = socket.assigns

    if connected?(socket) do
      Incidents.subscribe(id)

      if current_scope do
        Presence.track_user(id, current_scope.user)

        Presence.subscribe(id)
      end
    end

    incident = Incidents.get_incident!(id)

    responses = Incidents.list_responses(incident)

    presences = Presence.list_users(id)

    socket =
      socket
      |> assign(:incident, incident)
      |> stream(:responses, responses)
      |> stream(:presences, presences)
      |> assign(:response_count, Enum.count(responses))
      |> assign(:page_title, incident.name)
      |> assign_async(:urgent_incidents, fn ->
         {:ok, %{urgent_incidents: Incidents.urgent_incidents(incident)}} end)

    {:noreply, socket}
  end

  defp topic(incident_id) do
    "incident_onlookers:${incident_id"
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="incident-show">
        <.headline :if={@incident.heroic_response}>
          <.icon name="hero-sparkles-solid" />
          Heroic Responder:
          <%= @incident.heroic_response.user.username %>
          <:tagline>
            <%= @incident.heroic_response.note %>
          </:tagline>
        </.headline>
        <div class="incident">
          <img src={@incident.image_path} />
          <section>
            <.badge status={@incident.status} />
            <header>
              <div>
                <h2>{@incident.name}</h2>
                <h3>{@incident.category.name}</h3>
              </div>
              <div class="priority">
                {@incident.priority}
              </div>
            </header>
            <div class="totals">
              {@response_count} Responses
            </div>
            <div class="description">
              {@incident.description}
            </div>
          </section>
        </div>
        <div class="activity">
          <div class="left">   
            <div :if={@incident.status == :pending}>
              <%= if @current_scope do %>         
                <.form for={@form} id="response-form" phx-change="validate" phx-submit="save">
                  <.input
                    field={@form[:status]}
                    type="select"
                    prompt="Choose a status"
                    options={[:enroute, :arrived, :departed]} />

                  <.input field={@form[:note]}
                    type="textarea"
                    placeholder="Note..."
                    autofocus />
                  <.button>Post</.button>
                </.form>
              <% else %>
                <.link href={~p"/users/log-in"} class="button">
                  Log In To Post
                </.link>
              <% end %>
            </div>
            <div id="responses" phx-update="stream">
              <.response :for={{dom_id, response} <- @streams.responses} response={response} id={dom_id} />
            </div>
          </div>
          <div class="right">
            <.urgent_incidents incidents={@urgent_incidents} />

            <.onlookers :if={@current_scope} presences={@streams.presences} />
          </div>
        </div>
          <.back navigate={~p"/incidents"}>All Incidents</.back>
      </div>
    </Layouts.app>
    """
  end

  def urgent_incidents(assigns) do
    ~H"""
    <section>
      <h4>Urgent Incidents</h4>
      <.async_result :let={result} assign={@incidents}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">
            Whoops: {reason}
          </div>
        </:failed>
        <ul class="incidents">
          <li :for={incident <- result}>
            <.link navigate={~p"/incidents/#{incident}"}>
              <img src={incident.image_path} /> {incident.name}
            </.link>
          </li>
        </ul>
      </.async_result>
    </section>
    """
  end

  def onlookers(assigns) do
    ~H"""
    <section>
      <h4>Onlookers</h4>
      <ul class="presences" id="incident-watchers" phx-update="stream">
        <li :for={{dom_id, %{id: username, metas: metas}} <- @presences} id={dom_id}>
          <.icon name="hero-user-circle-solid" class="w-5 h-5" />
          {username} ({length(metas)})
        </li>
      </ul>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :response, Response, required: true

  def response(assigns) do
    ~H"""
    <div class="response" id={@id}>
      <span class="timeline"></span>
      <section>
        <div class="avatar">
          <.icon name="hero-user-solid" />
        </div>
        <div>
          <span class="username">
            {@response.user.username}
          </span>
          <span>
            {@response.status}
          </span>
          <blockquote>
            {@response.note}
          </blockquote>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("validate", %{"response" => response_params}, socket) do
    changeset = Responses.change_response(socket.assigns.current_scope, %Response{}, response_params)

    socket = assign(socket, :form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"response" => response_params}, socket) do
    %{incident: incident, current_scope: current_scope} = socket.assigns

    case Responses.create_response(current_scope, incident, response_params) do
      {:ok, response} ->
        changeset = Responses.change_response(current_scope, %Response{}, response_params)

        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :form, to_form(changeset))

        {:noreply, socket}
    end
  end

  def handle_info({:response_created, response}, socket) do
    socket = 
      socket
      |> stream_insert(:responses, response, at: 0)
      |> update(:response_count, &(&1 + 1))
      |> push_navigate(to: ~p"/incidents/#{response.incident.id}")

    {:noreply, socket}
  end

  def handle_info({:incident_updated, incident}, socket) do
    {:noreply, assign(socket, :incident, incident)}
  end

  def handle_info({:user_joined, presence}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({:user_left, presence}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end
  
end