defmodule BraccinoUiWeb.PageLive do
  use BraccinoUiWeb, :live_view

  alias Braccino.Braccio
  alias Braccino.Braccio.Angles

  @impl true
  def mount(_params, _session, socket) do
    # TODO:
    # - update page when status changes
    # - allow one user at a time to use the page

    {
      :ok,
      assign(
        socket,
        angles: %Angles{},
        status: Braccio.current_status()
      )
    }
  end

  @impl true
  def handle_event("angles", params, socket) do
    {:ok, angles} = Angles.new(params)
    :ok = Braccio.set_angles(angles)

    {:noreply, assign(socket, angles: angles)}
  end
end
