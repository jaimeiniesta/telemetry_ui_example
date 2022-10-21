defmodule TelemetryUiExampleWeb.PageController do
  use TelemetryUiExampleWeb, :controller

  def index(conn, _params) do
    start = System.monotonic_time()

    100 |> :rand.uniform() |> :timer.sleep()

    duration =
      (System.monotonic_time() - start)
      |> System.convert_time_unit(:native, :millisecond)

    :telemetry.execute([:page, :index], %{duration: duration}, %{})

    render(conn, "index.html", duration: duration)
  end
end
