defmodule ScenicStarter.Component.Notes do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:text, 3}, {:rect, 3}]

  @height 110
  @font_size 20
  @indent 30

  # --------------------------------------------------------
  def verify(notes) when is_bitstring(notes), do: {:ok, notes}
  def verify(_), do: :invalid_data

  # ----------------------------------------------------------------------------
  def init(notes, opts) do
    # Get the viewport width
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph =
      Graph.build(font_size: @font_size, translate: {0, vp_height - @height})
      |> rect({vp_width, @height}, fill: {48, 48, 48})
      |> text(notes, translate: {@indent, @font_size * 2})

    {:ok, %{graph: graph, viewport: opts[:viewport]}, push: graph}
  end
end
