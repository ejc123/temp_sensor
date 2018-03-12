defmodule TempSensor.Application do
  use Application

  @moduledoc """
  Attempt to read temperature from DS18B20 temperature sensor
  """

  require Logger
  # for more information on OTP Applications
  @base_dir "/sys/bus/w1/devices/"

  def start(_type, _args) do

    Logger.debug "Start temperature measurement"

    spawn(fn -> read_temp_forever() end)

    {:ok, self()}
  end

  def read_temp_forever do
    File.ls!(@base_dir)
    |> Enum.filter(&(String.starts_with?(&1, "28-")))
    |> Enum.each(&read_temp(&1, @base_dir))

    :timer.sleep(1000)
    read_temp_forever()
  end

  defp read_temp(sensor, base_dir) do
    sensor_data = File.read!("#{base_dir}#{sensor}/w1_slave")
    #Logger.debug("reading sensor: #{sensor}: #{sensor_data}")
    {temp, _} = Regex.run(~r/t=(\d+)/, sensor_data)
    |> List.last
    |> Float.parse
    Logger.debug("#{sensor}: #{temp/1000} C")
  end
end
