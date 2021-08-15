defmodule Braccino.Braccio do
  @moduledoc """
  This module represents the braccio controlled by the arduino.
  """

  alias Braccino.Braccio.Angles

  # behaviour definition

  @type reason :: term
  @type impl_state :: term

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

  # genserver public functions

  use GenServer

  @args Application.compile_env(:braccino, __MODULE__)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, @args, name: __MODULE__)
  end

  @doc """
  Upload the firmware to the braccio.

  Will return an error if called when the braccio is connected.
  """
  @spec upload_firmware() :: :ok | {:error, reason()}
  def upload_firmware() do
    GenServer.call(__MODULE__, :upload_firmware, 30_000)
  end

  @doc """
  Connec to the bracio.

  This function blocks until the braccio is ready to accept commands.
  Will return an error if called when the braccio is connected.
  """
  @spec connect() :: :ok | {:error, reason()}
  def connect() do
    GenServer.call(__MODULE__, :connect, 10_000)
  end

  @doc """
  Disconnect from the braccio.

  Will return an error if called when the braccio is not connected.
  """
  @spec disconnect() :: :ok | {:error, reason()}
  def disconnect do
    GenServer.call(__MODULE__, :disconnect, 1000)
  end

  @doc """
  Returns whether the braccio is connected.
  """
  @spec connected?() :: boolean
  def connected?() do
    GenServer.call(__MODULE__, :connected?)
  end

  @doc """
  Set the angles of the braccio.

  Will return an error if called when the braccio is not connected.
  """
  @spec set_angles(Angles.t()) :: :ok | {:error, reason()}
  def set_angles(angles = %Angles{}) do
    GenServer.call(__MODULE__, {:set_angles, angles}, 1000)
  end

  # genserver callbacks

  @impl true
  def init(args) do
    impl = Keyword.fetch!(args, :implementation)
    {:ok, impl_state} = impl.init(args)
    {:ok, %{impl: impl, impl_state: impl_state, connected: false}}
  end

  @impl true
  def handle_call(:upload_firmware, _from, %{connected: false} = state) do
    {reply, impl_state} = state.impl.upload_firmware(state.impl_state)
    {:reply, reply, %{state | impl_state: impl_state}}
  end

  @impl true
  def handle_call(:upload_firmware, _from, %{connected: true} = state),
    do: {:reply, {:error, :connected}, state}

  @impl true
  def handle_call(:connect, _from, %{connected: false} = state) do
    {reply, impl_state} = state.impl.connect(state.impl_state)

    connected =
      case reply do
        :ok -> true
        _ -> false
      end

    {:reply, reply, %{state | connected: connected, impl_state: impl_state}}
  end

  @impl true
  def handle_call(:connect, _from, %{connected: true} = state),
    do: {:reply, {:error, :already_connected}, state}

  @impl true
  def handle_call(:disconnect, _from, %{connected: true} = state) do
    {reply, impl_state} = state.impl.disconnect(state.impl_state)

    connected =
      case reply do
        :ok -> false
        _ -> true
      end

    {:reply, reply, %{state | connected: connected, impl_state: impl_state}}
  end

  @impl true
  def handle_call(:disconnect, _from, %{connected: false} = state),
    do: {:reply, {:error, :not_connected}, state}

  @impl true
  def handle_call(:connected?, _from, state) do
    {:reply, state.connected, state}
  end

  @impl true
  def handle_call({:set_angles, angles}, _from, %{connected: true} = state) do
    {reply, impl_state} =
      case Angles.validate(angles) do
        :ok ->
          state.impl.set_angles(angles, state.impl_state)

        reply ->
          {reply, state.impl_state}
      end

    {:reply, reply, %{state | impl_state: impl_state}}
  end

  @impl true
  def handle_call({:set_angles, _angles}, _from, %{connected: false} = state),
    do: {:reply, {:error, :not_connected}, state}
end
