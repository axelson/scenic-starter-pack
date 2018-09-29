defmodule ScenicStarter.Scene.Primitives do
  @moduledoc """
  Sample scene.
  """

  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives

  alias ScenicStarter.Component.Nav
  alias ScenicStarter.Component.Notes

  @bird_path :code.priv_dir(:scenic_starter)
             |> Path.join("/static/images/cyanoramphus_zealandicus_1849.jpg")
  @bird_hash Scenic.Cache.Hash.file!( @bird_path, :sha )

  @bird_width 100
  @bird_height 128

  @body_offset 80

  @line {{0, 0}, {60, 60}}

  @notes """
    \"Primitives\" shows the various primitives available in Scenic.
    It also shows a sampling of the styles you can apply to them.
  """

  @graph Graph.build(font: :roboto, font_size: 24)
         |> group(
           fn g ->
             g
             |> text("Various primitives and styles", translate: {15, 20})

             # lines
             |> group(
               fn g ->
                 g
                 |> line(@line, stroke: {4, :red})
                 |> line(@line, stroke: {20, :green}, cap: :butt, t: {60, 0})
                 |> line(@line, stroke: {20, :yellow}, cap: :round, t: {120, 0})
               end,
               t: {290, 50}
             )

             # row
             |> group(
               fn g ->
                 g
                 |> triangle({{0, 60}, {50, 0}, {50, 60}}, fill: :khaki, stroke: {4, :green})
                 |> circle(30, fill: :green, stroke: {6, :yellow}, t: {110, 30})
                 |> ellipse({30, 40}, rotate: 0.5, fill: :green, stroke: {4, :gray}, t: {200, 30})
               end,
               t: {15, 50}
             )

             # row
             |> group(
               fn g ->
                 g
                 |> rect({50, 60}, fill: :khaki, stroke: {4, :green})
                 |> rrect({50, 60, 6}, fill: :green, stroke: {6, :yellow}, t: {85, 0})
                 |> quad({{0, 100}, {160, 0}, {300, 110}, {200, 260}},
                   id: :quad,
                   fill: {:linear, {0, 0, 400, 400, :yellow, :purple}},
                   stroke: {10, :khaki},
                   translate: {160, 0},
                   scale: 0.3,
                   pin: {0, 0}
                 )
                 |> sector({100, -0.3, -0.8},
                   stroke: {3, :grey},
                   fill: {:radial, {0, 0, 20, 160, {:yellow, 128}, {:purple, 128}}},
                   translate: {270, 70}
                 )
                 |> arc({100, -0.1, -0.8}, stroke: {6, :orange}, translate: {320, 70})
               end,
               t: {15, 130}
             )

             # bird
             |> rect({@bird_width, @bird_height}, fill: {:image, @bird_hash}, t: {15, 230})

             # text
             |> group(
               fn g ->
                 g
                 |> text("Hello", translate: {0, 40})
                 |> text("World", translate: {90, 40}, fill: :yellow)
                 |> text("Blur", translate: {0, 80}, font_blur: 2)
                 |> text("Shadow", translate: {82, 82}, font_blur: 2, fill: :light_grey)
                 |> text("Shadow", translate: {80, 80})
               end,
               font_size: 40,
               t: {130, 240}
             )

             # twisty path
             |> path(
               [
                 :begin,
                 {:move_to, 0, 0},
                 {:bezier_to, 0, 20, 0, 50, 40, 50},
                 {:bezier_to, 60, 50, 60, 20, 80, 20},
                 {:bezier_to, 100, 20, 110, 0, 120, 0},
                 {:bezier_to, 140, 0, 160, 30, 160, 50}
               ],
               stroke: {2, :red},
               translate: {355, 230},
               rotate: 0.5
             )
           end,
           translate: {15, @body_offset}
         )

         # Nav and Notes are added last so that they draw on top
         |> Nav.add_to_graph(__MODULE__)
         |> Notes.add_to_graph(@notes)

  def init(_, _opts) do
    # load the parrot texture into the cache
    Scenic.Cache.File.load(@bird_path, @bird_hash)

    push_graph(@graph)

    {:ok, @graph}
  end
end
