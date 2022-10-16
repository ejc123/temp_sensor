defmodule TempSensor.Reader do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

  @base_dir "/sys/bus/w1/devices/"
  @default_time 1000

  defmodule State do
    defstruct [:timer, :temps]
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
      temps: %{}
    }

    Logger.info("Starting reader")

    {:ok, state}
  end

  @impl GenServer
  def handle_cast(:temperature, %State{temps: temps} = state) do
    Enum.each(
      temps,
      fn
        {sensor, temperature} ->
          Logger.info("Sensor: #{sensor} Temperature: #{temperature / 1000} C")
      end
    )

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:read_sensors, state) do
    new_temps =
      File.ls!(@base_dir)
      |> Enum.filter(&String.starts_with?(&1, "28-"))
      |> Enum.reduce(%{}, fn sensor, accum ->
        temp = read_temp(sensor)

        case temp do
          :error ->
            accum

          {:ok, t} ->
            Map.merge(
              accum,
              %{sensor => t}
            )
        end
      end)

    {:noreply, %State{state | temps: new_temps}}
  end

  defp read_temp(sensor) do
    with {:ok, temp} <- File.read("#{@base_dir}#{sensor}/temperature") do
      formatted =
        temp
        |> String.trim()
        |> String.to_integer()

      {:ok, formatted}
    else
      {:error, _} -> :error
    end
  end
end
