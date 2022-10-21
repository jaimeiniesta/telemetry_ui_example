defmodule TelemetryUiExampleWeb.PageController do
  use TelemetryUiExampleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
