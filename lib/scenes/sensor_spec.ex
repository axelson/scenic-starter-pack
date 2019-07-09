defmodule ScenicStarter.Scene.SensorSpec do
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

  @moduledoc """
  This version of `Sensor` illustrates using anonymous functions to
  construct the display graph. Compare this with `SensorSpec` which uses
  the `xxx_spec` builders.
  """

  @buttons [
    button_spec("Calibrate",
      id: :button_1,
      height: 46,
      theme: :primary
    ),
    button_spec("Maintenance",
      id: :button_2,
      height: 46,
      theme: :secondary,
      translate: {0, 60}
    ),
    button_spec("Settings",
      id: :button_3,
      height: 46,
      theme: :secondary
    )
  ]

  @temperature_display text_spec("",
                         id: :temperature,
                         text_align: :center,
                         font_size: @font_size
                       )

  @graph Graph.build(font: :roboto, font_size: 16, theme: :dark)
         |> add_specs_to_graph(
           [
             @temperature_display,
             group_spec(@buttons,
               id: :button_group,
               button_font_size: 24
             )
           ],
           translate: {0, @body_offset}
         )
         # NavDrop and Notes are added last so that they draw on top
         |> Nav.add_to_graph(__MODULE__)
         |> Notes.add_to_graph(@notes)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    # Align the buttons and the temperature display. This has to be done at runtime
    # as we won't know the viewport dimensions until then.

    {:ok, %ViewPort.Status{size: {vp_width, _}}} = ViewPort.info(opts[:viewport])
    col = vp_width / 6

    graph =
      @graph
      |> Graph.modify(:temperature, &update_opts(&1, translate: {vp_width / 2, @font_size}))
      |> Graph.modify(:button_group, &update_opts(&1, translate: {col, @font_size + 60}))
      |> Graph.modify(:button_1, &update_opts(&1, width: col * 4))
      |> Graph.modify(:button_2, &update_opts(&1, width: col * 2 - 6))
      |> Graph.modify(
        :button_3,
        &update_opts(&1, width: col * 2 - 6, translate: {col * 2 + 6, 60})
      )

    # subscribe to the simulated temperature sensor
    Sensor.subscribe(:temperature)

    {:ok, graph, push: graph}
  end

  # --------------------------------------------------------
  # receive updates from the simulated temperature sensor
  def handle_info({:sensor, :data, {:temperature, kelvin, _}}, graph) do
    # fahrenheit
    temperature =
      (9 / 5 * (kelvin - 273) + 32)
      # temperature = kelvin - 273                      # celsius
      |> :erlang.float_to_binary(decimals: 1)

    # center the temperature on the viewport
    graph = Graph.modify(graph, :temperature, &text(&1, temperature <> @degrees))

    {:noreply, graph, push: graph}
  end
end
