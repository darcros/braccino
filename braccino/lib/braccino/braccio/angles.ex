defmodule Braccino.Braccio.Angles do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @type t :: %__MODULE__{
          base: integer,
          shoulder: integer,
          elbow: integer,
          wrist_ver: integer,
          wrist_rot: integer,
          gripper: integer
        }

  schema "Angles" do
    field :base, :integer, default: 0
    field :shoulder, :integer, default: 45
    field :elbow, :integer, default: 180
    field :wrist_ver, :integer, default: 180
    field :wrist_rot, :integer, default: 90
    field :gripper, :integer, default: 10
  end

  def new(raw_map) do
    %__MODULE__{}
    |> changeset(raw_map)
    |> apply_action(:update)
  end

  def changeset(base, raw_map) do
    base
    |> cast(raw_map, [:base, :shoulder, :elbow, :wrist_ver, :wrist_rot, :gripper])
    |> validate_required([:base, :shoulder, :elbow, :wrist_ver, :wrist_rot, :gripper])
    |> validate_inclusion(:base, 0..180)
    |> validate_inclusion(:shoulder, 15..165)
    |> validate_inclusion(:elbow, 0..180)
    |> validate_inclusion(:wrist_ver, 0..180)
    |> validate_inclusion(:wrist_rot, 0..180)
    |> validate_inclusion(:gripper, 10..73)
  end
end
