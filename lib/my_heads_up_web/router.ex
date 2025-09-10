defmodule MyHeadsUpWeb.Router do
  use MyHeadsUpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyHeadsUpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :snoop
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  def snoop(conn, _opts) do
    answer = ~w(Yes No Maybe) |> Enum.random()

    conn = assign(conn, :answer, answer)

    # IO.inspect(conn)
  end

  scope "/", MyHeadsUpWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/tips", TipController, :index
    get "/tips/:id", TipController, :show
    live "/effort", EffortLive
    live "/incidents", IncidentLive.Index
    live "/incidents/:id", IncidentLive.Show

    live "/admin/incidents", AdminIncidentLive.Index
    live "/admin/incidents/new", AdminIncidentLive.Form, :new
    live "/admin/incidents/:id/edit", AdminIncidentLive.Form, :edit

    live "/categories", CategoryLive.Index, :index
    live "/categories/new", CategoryLive.Form, :new
    live "/categories/:id", CategoryLive.Show, :show
    live "/categories/:id/edit", CategoryLive.Form, :edit
    
  end

  # Other scopes may use custom stacks.
  scope "/api", MyHeadsUpWeb.Api do
    pipe_through :api

    get "/incidents", IncidentController, :index
    get "/incidents/:id", IncidentController, :show
    get "/categories/:id/incidents", CategoryController, :show
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
end
