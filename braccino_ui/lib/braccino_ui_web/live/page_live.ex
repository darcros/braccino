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
    # params are passed as strings, so we need to parse them
    # it is very important that we check the name before coverting it to an atom
    # TODO: use ecto to cast the parameters instead of doing it by hand
    parsed_params =
      for {name, angle} <- params,
          name in [
            "base",
            "shoulder",
            "elbow",
            "wrist_ver",
            "wrist_rot",
            "gripper"
          ],
          into: %{},
          do: {String.to_atom(name), String.to_integer(angle)}

    {:ok, angles} = Angles.new(parsed_params)
    :ok = Braccio.set_angles(angles)

    {:noreply, assign(socket, angles: angles)}
  end
end
