defmodule BraccinoFirmware.ArduinoDue do
  alias Circuits.UART

  @doc """
  Uploads the firmware to the Arduino board.
  """
  @spec upload(binary) :: :ok | {:error, {:bossac, pos_integer, binary}} | {:error, any}
  def upload(port) do
    with :ok <- reset(port) do
      write_bin(port)
    end
  end

  @doc """
  Resets the Arduino board.

  The reset is caused by opening and closing the serial port.
  """
  @spec reset(binary) :: :ok | {:error, any}
  def reset(port) do
    # opening the serial port with a 1200 baud rate will cause the arduino to
    # reset, allowing us to upload the sketch
    with {:ok, pid} <- UART.start_link(),
         :ok <- UART.open(pid, port, speed: 1200, active: false) do
      UART.close(pid)
    end
  end

  @spec write_bin(any) :: :ok | {:error, {:bossac, pos_integer, binary}}
  defp write_bin(port) do
    {:ok, application} = :application.get_application(__MODULE__)

    priv_dir =
      :code.priv_dir(application)
      |> List.to_string()

    bossac_path = Path.join([priv_dir, "bossac"])
    bin_path = Path.join([priv_dir, "arduino-sketch.ino.bin"])

    args = [
      # print more verbose output, in case there is an error
      "--info",
      "--debug",

      # erase the flash memory
      "--erase",

      # write the sketch to the flash memory
      "--write",

      # boot from the flash memory
      "--boot",

      # reset the CPU
      "--reset",

      # i'm not sure what this does, but it's used by the arduino IDE, so I will keep it
      "--force_usb_port=false",

      # the serial port to use
      "--port=#{port}",

      # the .bin file to write
      bin_path
    ]

    case System.cmd(bossac_path, args) do
      {_stdout, 0} ->
        :ok

      {stdout, exit_code} ->
        {:error, {:bossac, exit_code, stdout}}
    end
  end
end
