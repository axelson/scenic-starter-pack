defmodule ScenicStarter.Scene.Components do
  @moduledoc """
  Sample scene.
  """

  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components

  alias ScenicStarter.Component.Nav
  alias ScenicStarter.Component.Notes

  @body_offset 60

  @notes """
    \"Components\" shows the basic components available in Scenic.
    Messages sent by the component are displayed live.
    The crash button raises an error, demonstrating how recovery works.
  """

  @graph Graph.build(font: :roboto, font_size: 24, theme: :dark)
         |> group(
           fn g ->
             g
             |> text("Various components", translate: {15, 20})
             |> text("Event received:", translate: {15, 60}, id: :event)
             # this button will cause the scene to crash.
             |> button("Crash", id: :btn_crash, theme: :danger, t: {370, 0})

             # sample components
             |> group(
               fn g ->
                 g
                 # buttons as a group
                 |> group(
                   fn g ->
                     g
                     |> button("Primary", id: :btn_primary, theme: :primary)
                     |> button("Success", id: :btn_success, t: {90, 0}, theme: :success)
                     |> button("Info", id: :btn_info, t: {180, 0}, theme: :info)
                     |> button("Light", id: :btn_light, t: {270, 0}, theme: :light)
                     |> button("Warning", id: :btn_warning, t: {360, 0}, theme: :warning)
                     |> button("Dark", id: :btn_dark, t: {0, 40}, theme: :dark)
                     |> button("Text", id: :btn_text, t: {90, 40}, theme: :text)
                     |> button("Danger", id: :btn_danger, theme: :danger, t: {180, 40})
                     |> button("Secondary",
                       id: :btn_secondary,
                       width: 100,
                       t: {270, 40},
                       theme: :secondary
                     )
                   end,
                   translate: {0, 10}
                 )
                 |> slider({{0, 100}, 0}, id: :num_slider, t: {0, 95})
                 |> radio_group(
                   [
                     {"Radio A", :radio_a},
                     {"Radio B", :radio_b, true},
                     {"Radio C", :radio_c, false}
                   ],
                   id: :radio_group,
                   t: {0, 140}
                 )
                 |> checkbox({"Check Box", true}, id: :check_box, t: {200, 140})
                 |> toggle(false, id: :toggle, t: {340, 135})
                 |> text_field("", id: :text, width: 240, hint: "Type here...", t: {200, 160})
                 |> text_field("",
                   id: :password,
                   width: 240,
                   hint: "Password",
                   type: :password,
                   t: {200, 200}
                 )
                 |> dropdown(
                   {
                     [{"Choice 1", :choice_1}, {"Choice 2", :choice_2}, {"Choice 3", :choice_3}],
                     :choice_1
                   },
                   id: :dropdown,
                   translate: {0, 202}
                 )
               end,
               t: {15, 74}
             )
           end,
           translate: {0, @body_offset + 20}
         )

         # Nav and Notes are added last so that they draw on top
         |> Nav.add_to_graph(__MODULE__)
         |> Notes.add_to_graph(@notes)

  @event_str "Event received: "

  # ============================================================================

  def init(_, _opts) do
    push_graph(@graph)
    {:ok, @graph}
  end

  # force the scene to crash
  def filter_event({:click, :btn_crash}, _, _graph) do
    raise "The crash button was pressed. Crashing now..."
    # No need to return anything. Already crashed.
  end

  # display the received message
  def filter_event(event, _, graph) do
    graph =
      graph
      |> Graph.modify(:event, &text(&1, @event_str <> inspect(event)))
      |> push_graph()

    {:continue, event, graph}
  end
end
