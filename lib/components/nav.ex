defmodule ScenicStarter.Component.Nav do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:text, 3}, {:rect, 3}]
  import Scenic.Components, only: [{:dropdown, 3}]
  import Scenic.Clock.Components

  # import IEx

  @height 60

  # --------------------------------------------------------
  def verify(scene) when is_atom(scene), do: {:ok, scene}
  def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(current_scene, opts) do
    # Register this module so that it can receive the callback from ExSync
    Process.register(self(), __MODULE__)

    styles = opts[:styles] || %{}

    # Get the viewport width
    {:ok, %ViewPort.Status{size: {width, _}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph =
      Graph.build(styles: styles, font_size: 20)
      |> rect({width, @height}, fill: {48, 48, 48})
      |> text("Scene:", translate: {14, 35}, align: :right)
      |> dropdown(
        {[
           {"Sensor", ScenicStarter.Scene.Sensor},
           {"Primitives", ScenicStarter.Scene.Primitives},
           {"Components", ScenicStarter.Scene.Components},
           {"Transforms", ScenicStarter.Scene.Transforms}
         ], current_scene},
        id: :nav,
        translate: {70, 15}
      )
      |> digital_clock(text_align: :right, translate: {width - 20, 35})
      |> Scenic.Components.button("Reload", id: :reload_app_btn, width: 100, translate: {240, 15})
      |> push_graph()

    state = %{graph: graph, viewport: opts[:viewport], current_scene: current_scene}
    {:ok, state}
  end

  # ----------------------------------------------------------------------------
  def filter_event({:value_changed, :nav, scene}, _, %{viewport: vp} = state)
      when is_atom(scene) do
    ViewPort.set_root(vp, {scene, nil})
    {:stop, state}
  end

  # ----------------------------------------------------------------------------
  def filter_event({:value_changed, :nav, scene}, _, %{viewport: vp} = state) do
    ViewPort.set_root(vp, scene)
    {:stop, state}
  end

  def filter_event({:click, :reload_app_btn}, _pid, state) do
    %{current_scene: current_scene} = state
    reload_current_scene(current_scene)

    {:stop, state}
  end

  # Handle reload callback from ExSync
  def handle_call(:reload_current_scene, _, state) do
    %{current_scene: current_scene} = state
    reload_current_scene(current_scene)
    {:reply, nil, state}
  end

  defp reload_current_scene(current_scene) do
    current_scene
    |> Process.whereis()
    |> case do
      nil ->
        IO.puts("Unable to reload #{current_scene} because it was not registered")
        nil

      pid ->
        Process.exit(pid, :kill)
    end
  end
end
