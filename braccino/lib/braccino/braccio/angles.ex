defmodule Braccino.Braccio.Angles do
  @moduledoc """
  Module Angles contains a struct representing the angles of the Braccio.
  """

  # the range of each angle and its default position
  @angles %{
    base: {0..180, 0},
    shoulder: {15..165, 45},
    elbow: {0..180, 180},
    wrist_ver: {0..180, 180},
    wrist_rot: {0..180, 90},
    gripper: {10..73, 10}
  }

  @type angle_name :: :base | :shoulder | :elbow | :wrist_ver | :wrist_rot | :gripper
  @type t :: %__MODULE__{
          base: integer,
          shoulder: integer,
          elbow: integer,
          wrist_ver: integer,
          wrist_rot: integer,
          gripper: integer
        }
  defstruct Enum.map(@angles, fn {name, {_range, default}} -> {name, default} end)

  @spec in_range?(name :: angle_name, angle :: integer) :: boolean
  def in_range?(name, angle) do
    {range, _default} = Map.fetch!(@angles, name)
    angle in range
  end

  @spec validate(Braccino.Braccio.Angles.t()) ::
          {:error, {:out_of_range, [angle_name]}} | :ok
  def validate(angles = %__MODULE__{}) do
    out_of_range =
      @angles
      |> Map.keys()
      |> Enum.filter(fn name ->
        angle = Map.fetch!(angles, name)
        not in_range?(name, angle)
      end)

    case out_of_range do
      [] -> :ok
      _ -> {:error, {:out_of_range, out_of_range}}
    end
  end

  @spec is_valid?(angles :: Braccino.Braccio.Angles.t()) :: boolean
  def is_valid?(angles = %__MODULE__{}) do
    case validate(angles) do
      :ok -> true
      _ -> false
    end
  end

  @spec new(any) ::
          {:error, {:out_of_range, [angle_name]}} | {:ok, Braccino.Braccio.Angles.t()}
  def new(angles) do
    angles_struct = struct(__MODULE__, angles)

    case validate(angles_struct) do
      :ok -> {:ok, angles_struct}
      error -> error
    end
  end
end
