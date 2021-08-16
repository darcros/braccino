defmodule Braccino.Braccio do
  @moduledoc """
  This module represents the braccio controlled by the arduino.
  """

  alias Braccino.Braccio.Angles
  require Logger
  use GenServer

  @type reason :: term
  @type impl_state :: term
  @type braccio_status :: :disconnected | :uploading_firmware | :connecting | :connected | :error

  @doc """
  Initialize the state of the braccio based on the options in the config.

  This function should return the initial state or an error.
  """
  @callback init(opts :: Keyword.t()) :: {:ok, impl_state()} | :error

  @doc """
  Upload the Arduino firmware.

  This function will be called only when the serial port is not open.
  This function should return `:ok` or an error and the new state.
  """
  @callback upload_firmware(state :: impl_state()) ::
              {:ok, impl_state()} | {{:error, reason()}, impl_state()}

  @doc """
  Open the serial port with braccio.

  This function should block until the braccio is ready to accept commands.
  This function will be called only when the serial port is not open.
  This function should return `:ok` or an error and the new state.
  """
  @callback connect(state :: impl_state()) ::
              {:ok, impl_state()} | {{:error, reason()}, impl_state()}

  @doc """
  Close the serial port with the braccio.

  This function will be called only when the serial port is open.
  This function should return `:ok` or an error and the new state.
  """
  @callback disconnect(state :: impl_state()) ::
              {:ok, impl_state()} | {{:error, reason()}, impl_state()}

  @doc """
  Set the angles of the braccio.

  This function will be called only when the serial port is open.
  This function should return `:ok` or an error and the new state.
  """
  @callback set_angles(angles :: Angles.t(), state :: impl_state()) ::
              {:ok, impl_state()} | {{:error, reason()}, impl_state()}

  # client API

  def start_link(args) do
    env_args = Application.get_env(:braccino, __MODULE__)
    GenServer.start_link(__MODULE__, args ++ env_args, name: __MODULE__)
  end

  @doc """
  Returns the current status of the braccio.
  """
  @spec current_status() :: braccio_status()
  def current_status() do
    GenServer.call(__MODULE__, :current_status)
  end

  @doc """
  Set the angles of the braccio.

  Will return an error if called when the braccio is not connected.
  """
  @spec set_angles(Angles.t()) :: :ok | {:error, reason()}
  def set_angles(angles = %Angles{}) do
    GenServer.call(__MODULE__, {:set_angles, angles})
  end

  # callbacks

  def init(args) do
    impl = Keyword.fetch!(args, :implementation)
    {:ok, impl_state} = impl.init(args)

    state = %{
      impl: impl,
      impl_state: impl_state,
      status: :disconnected,
      task: nil
    }

    {:ok, state, {:continue, :upload_firmware}}
  end

  # start a task to upload the firmware
  def handle_continue(:upload_firmware, %{status: :disconnected, task: nil} = state) do
    task =
      Task.Supervisor.async_nolink(Braccino.TaskSupervisor, fn ->
        state.impl.upload_firmware(state.impl_state)
      end)

    {:noreply, %{state | status: :uploading_firmware, task: task}}
  end

  # start a task to connect to the braccio
  def handle_continue(:connect, %{status: :disconnected, task: nil} = state) do
    task =
      Task.Supervisor.async_nolink(Braccino.TaskSupervisor, fn ->
        state.impl.connect(state.impl_state)
      end)

    {:noreply, %{state | status: :connecting, task: task}}
  end

  # handle the result of the task that uploads the firmware
  # if the task is successful, connect to the braccio
  def handle_info({ref, result}, %{status: :uploading_firmware} = state) do
    # The task succeed so we can cancel the monitoring and discard the DOWN message
    Process.demonitor(ref, [:flush])

    case result do
      {:ok, impl_state} ->
        state = %{state | impl_state: impl_state, status: :disconnected, task: nil}
        {:noreply, state, {:continue, :connect}}

      {{:error, reason}, impl_state} ->
        Logger.error("Failed to upload arduino firmware: #{inspect(reason)}")

        state = %{state | impl_state: impl_state, status: :error, task: nil}
        {:noreply, state}
    end
  end

  # handle the result of the task that connects to the braccio
  def handle_info({ref, result}, %{status: :connecting} = state) do
    # The task succeed so we can cancel the monitoring and discard the DOWN message
    Process.demonitor(ref, [:flush])

    case result do
      {:ok, impl_state} ->
        state = %{state | impl_state: impl_state, status: :connected, task: nil}
        {:noreply, state}

      {{:error, reason}, impl_state} ->
        Logger.error("Failed to connecte to braccio: #{inspect(reason)}")

        state = %{state | impl_state: impl_state, status: :error, task: nil}
        {:noreply, state}
    end
  end

  # if a task fails...
  def handle_info({:DOWN, _ref, _, _, reason}, state) do
    case state.status do
      :uploading_firmware ->
        Logger.error("Task crashed while uploading firmware: #{inspect(reason)}")

      :connecting ->
        Logger.error("Task crashed while connecting: #{inspect(reason)}")
    end

    state = %{state | status: :error, task: nil}
    {:noreply, state}
  end

  def handle_call(:current_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call({:set_angles, angles}, _from, state) when state.status == :connected do
    {reply, impl_state} = state.impl.set_angles(angles, state.impl_state)
    state = %{state | impl_state: impl_state}
    {:reply, reply, state}
  end

  def handle_call({:set_angles, _angles}, _from, state),
    do: {:reply, {:error, :not_connected}, state}
end
