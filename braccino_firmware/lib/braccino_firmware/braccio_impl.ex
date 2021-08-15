defmodule BraccinoFirmware.BraccioImpl do
  alias Circuits.UART
  alias BraccinoFirmware.ArduinoDue

  @behaviour Braccino.Braccio

  @impl true
  def init(opts) do
    state = %{
      port: Keyword.get(opts, :port, "ttyACM0"),
      baud_rate: Keyword.get(opts, :baud_rate, 38400),
      pid: nil
    }

    {:ok, state}
  end

  @impl true
  def upload_firmware(state) do
    reply = ArduinoDue.upload(state.port)
    {reply, state}
  end

  @impl true
  def connect(state) do
    pid =
      case state do
        %{pid: nil} ->
          {:ok, pid} = UART.start_link()
          pid

        %{pid: pid} ->
          pid
      end

    :ok =
      UART.open(pid, state.port,
        speed: state.baud_rate,
        framing: BraccinoFirmware.Framing.COBS,
        active: false
      )

    # block until we get the "ready" message from the arduino
    {:ok, <<0x00>>} = UART.read(pid, 10_000)

    {:ok, %{state | pid: pid}}
  end

  @impl true
  def disconnect(%{pid: pid} = state) do
    :ok = UART.close(pid)
    {:ok, state}
  end

  @impl true
  def set_angles(angles, state) do
    data =
      <<0x01, angles.base, angles.shoulder, angles.elbow, angles.wrist_ver, angles.wrist_rot,
        angles.gripper>>

    reply = UART.write(state.pid, data)
    {reply, state}
  end
end
