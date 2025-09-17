defmodule MyHeadsUpWeb.Router do
  use MyHeadsUpWeb, :router

  import MyHeadsUpWeb.UserAuth
  import MyHeadsUp.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyHeadsUpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug :snoop
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  def snoop(conn, _opts) do
    answer = ~w(Yes No Maybe) |> Enum.random()

    conn = assign(conn, :answer, answer)

    IO.inspect(conn)
  end

  scope "/", MyHeadsUpWeb do
    pipe_through :browser

    # get "/", PageController, :home

    get "/tips", TipController, :index
    get "/tips/:id", TipController, :show

    live "/", IncidentLive.Index
    live "/effort", EffortLive
    live "/incidents", IncidentLive.Index
    live "/incidents/:id", IncidentLive.Show
      
  end


  # Other scopes may use custom stacks.
  scope "/api", MyHeadsUpWeb.Api do
    pipe_through :api

    get "/incidents", IncidentController, :index
    get "/incidents/:id", IncidentController, :show
    get "/categories/:id/incidents", CategoryController, :show
    post "/incidents", IncidentController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:my_heads_up, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyHeadsUpWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MyHeadsUpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MyHeadsUpWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", MyHeadsUpWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admins,
      on_mount: [
        {MyHeadsUpWeb.UserAuth, :require_authenticated},
        {MyHeadsUpWeb.UserAuth, :ensure_admin}
      ] do

      live "/admin/incidents", AdminIncidentLive.Index, :index
      live "/admin/incidents/new", AdminIncidentLive.Form, :new
      live "/admin/incidents/:id/edit", AdminIncidentLive.Form, :edit

      live "/categories", CategoryLive.Index, :index
      live "/categories/new", CategoryLive.Form, :new
      live "/categories/:id", CategoryLive.Show, :show
      live "/categories/:id/edit", CategoryLive.Form, :edit
    end
  end


  scope "/", MyHeadsUpWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{MyHeadsUpWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
