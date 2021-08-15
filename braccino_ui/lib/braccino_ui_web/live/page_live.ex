defmodule BraccinoUiWeb.PageLive do
  use BraccinoUiWeb, :live_view

  alias Braccino.Braccio
  alias Braccino.Braccio.Angles

  @impl true
  def mount(_params, _session, socket) do
    if Braccio.connected?() do
      :ok = Braccio.disconnect()
    end

    send(self(), :connect)
    {:ok, assign(socket, angles: %Angles{}, status: :connecting)}
  end

  @impl true
  def handle_info(:connect, socket) do
    :ok = Braccio.connect()

    # set the initial angles
    :ok = Braccio.set_angles(socket.assigns.angles)

    {:noreply, assign(socket, status: :connected)}
  end

  @impl true
  def handle_event("angles", params, socket) do
    {:ok, angles} = Angles.new(params)
    :ok = Braccio.set_angles(angles)

    {:noreply, assign(socket, angles: angles)}
  end
end
