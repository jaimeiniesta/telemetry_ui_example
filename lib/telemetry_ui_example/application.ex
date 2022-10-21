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
      TelemetryUiExampleWeb.Endpoint,
      # Start a worker by calling: TelemetryUiExample.Worker.start_link(arg)
      # {TelemetryUiExample.Worker, arg}

      {TelemetryUI, telemetry_config()}
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

  defp telemetry_config do
    import TelemetryUI.Metrics

    [
      metrics: [
        value_over_time("page.index.duration",
          description: "Execution time for page index",
          unit: :millisecond,
          ui_options: [unit: " milliseconds"]
        ),
        counter("phoenix.router_dispatch.stop.duration",
          description: "Number of requests",
          unit: {:native, :millisecond},
          ui_options: [unit: " requests"]
        ),
        value_over_time("vm.memory.total", unit: {:byte, :megabyte}),
        distribution("phoenix.router_dispatch.stop.duration",
          description: "Requests duration",
          unit: {:native, :millisecond},
          reporter_options: [buckets: [0, 100, 500, 2000]]
        )
      ],
      backend: %TelemetryUI.Backend.EctoPostgres{
        repo: TelemetryUiExample.Repo,
        pruner_threshold: [months: -1],
        pruner_interval_ms: 84_000,
        max_buffer_size: 10_000,
        flush_interval_ms: 10_000
      }
    ]
  end
end
