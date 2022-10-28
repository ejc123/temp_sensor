defmodule TempSensor.Reader do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

  @base_dir "/sys/bus/w1/devices/"
  # half-second minimum
  @min_time 500

  defmodule State do
    defstruct [:time, :temps]
  end

  def start_link(time_interval \\ @min_time) do
    GenServer.start_link(__MODULE__, time_interval, name: TempSensor.Reader)
  end

  @impl GenServer
  def init(time_interval) do
    # Send ourselves a message to read the sensor
    time = max(@min_time, time_interval)

    state = %State{
      time: time,
      temps: %{}
    }

    Logger.info("Starting reader")

    :erlang.send_after(time, self(), :read_sensors)
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:set_time, time}, _, state) do
    new_time = max(@min_time, time)
    {:reply, "Old Time #{state.time} New Time #{new_time}", %State{state | time: new_time}}
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
            Logger.debug("Set sensor: #{sensor} to: #{t}")
            Map.merge(
              accum,
              %{sensor => t}
            )
        end
      end)


    :erlang.send_after(state.time, self(), :read_sensors)
    {:noreply, %State{state | temps: new_temps}}
  end

  defp read_temp(sensor) do
    with {:ok, temp} <- File.read("#{@base_dir}#{sensor}/temperature"),
         {formatted, _} <- temp |> String.trim() |> Integer.parse() do
      {:ok, formatted}
    else
      {:error, _} -> :error
      :error -> :error
    end
  end
end
