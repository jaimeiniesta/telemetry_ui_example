defmodule TelemetryUiExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Start metrics
    :ok =
      :telemetry.attach(
        "metrics",
        [:page, :index],
        &TelemetryUiExample.Metrics.handle_event/4,
        nil
      )

    children = [
      # Start the Ecto repository
      TelemetryUiExample.Repo,
      # Start the Telemetry supervisor
      TelemetryUiExampleWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TelemetryUiExample.PubSub},
      # Start the Endpoint (http/https)
      TelemetryUiExampleWeb.Endpoint
      # Start a worker by calling: TelemetryUiExample.Worker.start_link(arg)
      # {TelemetryUiExample.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TelemetryUiExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TelemetryUiExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
