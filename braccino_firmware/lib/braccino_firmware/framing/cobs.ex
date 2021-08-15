defmodule BraccinoFirmware.Framing.COBS do
  @behaviour Circuits.UART.Framing

  alias Circuits.UART.Framing.Line

  def init(_args) do
    Line.init(max_length: 254, separator: <<0>>)
  end

  def add_framing(data, state) do
    case Cobs.encode(data) do
      {:ok, encoded} ->
        Line.add_framing(encoded, state)

      # FIXME: ElixirLS shows an error here but actually the typespec of the
      # cobs library is wrong
      {:error, reason} ->
        {:error, reason, state}
    end
  end

  def remove_framing(data, state) do
    {rc, lines, new_state} = Line.remove_framing(data, state)
    frames = Enum.map(lines, &Cobs.decode!/1)
    {rc, frames, new_state}
  end

  def frame_timeout(state) do
    {:ok, _partial_lines, new_state} = Line.frame_timeout(state)
    {:ok, [], new_state}
  end

  def flush(direction, state) do
    Line.flush(direction, state)
  end
end
