defmodule Braccino.Braccio.Mock do
  @moduledoc """
  A mock implementation of Braccino.Braccio that will always succeed and will
  simulate the time needed for certain operations by just sleeping.
  """

  require Logger

  @behaviour Braccino.Braccio

  @impl true
  def init(opts) do
    state = %{
      upload_firmware_sleep: Keyword.get(opts, :upload_firmware_sleep, 10_000),
      connect_sleep: Keyword.get(opts, :connect_sleep, 5000)
    }

    {:ok, state}
  end

  @impl true
  def upload_firmware(state) do
    Logger.info("Uploading firmware... (sleeping #{state.upload_firmware_sleep}ms)")
    Process.sleep(state.upload_firmware_sleep)
    Logger.info("Uploaded firmware")
    {:ok, state}
  end

  @impl true
  def connect(state) do
    Logger.info("Connecting... (sleeping #{state.connect_sleep}ms)")
    Process.sleep(state.connect_sleep)
    Logger.info("Connected")
    {:ok, state}
  end

  @impl true
  def disconnect(state) do
    Logger.info("Disconnected")
    {:ok, state}
  end

  @impl true
  def set_angles(angles, state) do
    Logger.info("Setting angles: #{inspect(angles)}")
    {:ok, state}
  end
end
