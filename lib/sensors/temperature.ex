# this is a SIMULATED temperature sensor
# it pretends to get a temperature and sets it into the sensor cache.

defmodule ScenicStarter.Sensor.Temperature do
  use GenServer

  alias Scenic.Sensor

  @name :temperature
  @version "0.1.0"
  @description "Simulated temperature sensor"

  @timer_ms 400
  @initial_temp 295.372
  @amplitude 1.5
  @frequency 0.001
  @tau :math.pi() * 2

  # --------------------------------------------------------
  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: @name)

  # --------------------------------------------------------
  def init(_) do
    # register this sensor
    Sensor.register(:temperature, @version, @description)

    # put the first sensor value - in kelvin
    Sensor.publish(:temperature, @initial_temp)

    # start the timer so that it simulates a changing temperature
    {:ok, timer} = :timer.send_interval(@timer_ms, :tick)

    {:ok, %{timer: timer, temperature: @initial_temp, t: 0}}
  end

  # --------------------------------------------------------
  # in a real sensor you would use a timer like this to read from a real device.
  # this one just fakes it with a sine wave
  def handle_info(:tick, %{t: t} = state) do
    Sensor.publish(
      :temperature,
      @initial_temp + @amplitude * :math.sin(@tau * @frequency * t)
    )

    {:noreply, %{state | t: t + 1}}
  end
end
