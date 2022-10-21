defmodule TelemetryUiExample.Repo do
  use Ecto.Repo,
    otp_app: :telemetry_ui_example,
    adapter: Ecto.Adapters.Postgres
end
