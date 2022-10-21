defmodule TelemetryUiExample.Metrics do
  require Logger

  def handle_event([:page, :index], %{duration: duration}, _metadata, _config) do
    Logger.info("#{__MODULE__} observed [:page, :index] event with duration #{duration}")
  end
end
