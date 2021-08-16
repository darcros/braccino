defmodule BraccinoUiWeb.PageLive do
  use BraccinoUiWeb, :live_view

  alias Braccino.Braccio
  alias Braccino.Braccio.Angles

  @impl true
  def mount(_params, _session, socket) do
    # TODO:
    # - update page when status changes

    # `page status` can contain any of the values that can be returned by
    # `Braccio.current_status/0` but also the atom `:busy` in case the live
    #  view cannot acquire control of the braccio
    page_status =
      case Braccio.acquire_control() do
        :ok -> Braccio.current_status()
        _ -> :busy
      end

    {
      :ok,
      assign(
        socket,
        angles: %Angles{},
        page_status: page_status
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
