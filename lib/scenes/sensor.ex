defmodule ScenicStarter.Scene.Sensor do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias Scenic.Sensor

  import Scenic.Primitives
  import Scenic.Components

  alias ScenicStarter.Component.Nav
  alias ScenicStarter.Component.Notes

  @body_offset 80
  @font_size 160
  @degrees "°"

  @notes """
    \"Sensor\" is a simple scene that displays data from a simulated sensor.
    The sensor is in /lib/sensors/temperature and uses Scenic.Sensor
    The buttons are placeholders showing custom alignment.
  """

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    # Register this process so that we can reload it by killing it
    Process.register(self(), __MODULE__)

    {:ok, %ViewPort.Status{size: {vp_width, _}}} =
      opts[:viewport]
      |> ViewPort.info()

    col = vp_width / 6

    # build the graph
    graph =
      Graph.build(font: :roboto, font_size: 16, theme: :dark)
      # text input
      |> group(
        fn graph ->
          graph
          |> text(
            "",
            id: :temperature,
            text_align: :center,
            font_size: @font_size,
            translate: {vp_width / 2, @font_size}
          )
          |> group(
            fn g ->
              g
              |> button("Calibrate", width: col * 4, height: 46, theme: :primary)
              |> button(
                "Maintenance",
                width: col * 2 - 6,
                height: 46,
                theme: :secondary,
                translate: {0, 60}
              )
              |> button(
                "Settings",
                width: col * 2 - 6,
                height: 46,
                theme: :secondary,
                translate: {col * 2 + 6, 60}
              )
            end,
            translate: {col, @font_size + 60},
            button_font_size: 24
          )
        end,
        translate: {0, @body_offset}
      )

      # NavDrop and Notes are added last so that they draw on top
      |> Nav.add_to_graph(__MODULE__)
      |> Notes.add_to_graph(@notes)
      |> push_graph()

    # subscribe to the simulated temperature sensor
    Sensor.subscribe(:temperature)

    {:ok, graph}
  end

  # --------------------------------------------------------
  # receive updates from the simulated temperature sensor
  def handle_info({:sensor, :data, {:temperature, kelvin, _}}, graph) do
    # fahrenheit
    temperature =
      (9 / 5 * (kelvin - 273) + 32)
      # temperature = kelvin - 273                      # celcius
      |> :erlang.float_to_binary(decimals: 1)

    graph
    # center the temperature on the viewport
    |> Graph.modify(:temperature, &text(&1, temperature <> @degrees))
    |> push_graph()

    {:noreply, graph}
  end
end
