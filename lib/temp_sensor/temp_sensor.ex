defmodule TempSensor.Reader do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

  @base_dir "/sys/bus/w1/devices/"
  @default_time 1000

  defmodule State do
    defstruct [:timer, :temp]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: TempSensor.Reader)
  end

  @impl GenServer
  def init(_opts) do
    # Send ourselves a message to read the sensor
    {:ok, ref} = :timer.send_interval(@default_time, :read_sensors)

    state = %State{
      timer: ref,
      temp: []
    }

    Logger.info("Starting reader")

    {:ok, state}
  end

  @impl GenServer
  def handle_cast(:temperature, state) do
    Enum.map(state.temp,
    fn {sensor, temperature} ->
    IO.puts("Sensor: #{sensor} Temperature: #{temperature / 1000} C")
  end)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:read_sensors, state) do
    temp =
      File.ls!(@base_dir)
      |> Enum.filter(&String.starts_with?(&1, "28-"))
      |> Enum.map(&read_temp(&1, @base_dir))

    {:noreply, %State{state | temp: temp}}
  end

  defp read_temp(sensor, base_dir) do
    temp =
      File.read!("#{base_dir}#{sensor}/temperature")
      |> String.trim()
      |> String.to_integer()

    Logger.info("#{sensor}: #{temp / 1000} C")
    {sensor, temp}
  end
end
