defmodule TelemetryUiExampleWeb.Router do
  use TelemetryUiExampleWeb, :router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TelemetryUiExampleWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin_protected do
    plug(:basic_auth,
      username: "admin",
      password: "admin"
    )

    plug(:enable_telemetry_ui)
  end

  defp enable_telemetry_ui(conn, _), do: assign(conn, :telemetry_ui_allowed, true)

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TelemetryUiExampleWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/admin" do
    pipe_through [:browser, :admin_protected]

    get("/metrics", TelemetryUI.Web, [], assigns: %{telemetry_ui_allowed: true})
  end

  # Other scopes may use custom stacks.
  # scope "/api", TelemetryUiExampleWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TelemetryUiExampleWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
