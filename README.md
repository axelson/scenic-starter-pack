Scenic Starter Pack is a kit that helps you easily get up and running with Scenic. It is directly based on the [scenic_new](https://github.com/boydm/scenic_new) starter application but it adds live reload. Simply edit a file in the project and save it, then it will reload the currently selected scene!

To try it out after you have the project running (see below) in `lib/scenes/components.ex` try changing the `"Primary"` button to instead read `"First!"` and you should see the button on the text change.

# Demo

In this demo I replace the text "World" with "Scenic", then change the color of the text to purple. Next I change the shape of the bezier line.

[![Screencast Demo](./demo.gif)](https://raw.githubusercontent.com/axelson/scenic-starter-pack/master/demo.gif)

# Installation

Clone the repository

    mix deps.get

# Running

    mix scenic.run

    iex -S mix scenic.run

# How it works

Live compilation is provided by [ExSync](https://github.com/falood/exsync). The flow goes like this:

1. You edit a `.ex` file in your editor
2. ExSync detects the file edit and recompiles the file you edited
3. If there are no further file edits than ExSync calls the configured `:reload_callback`
4. The default `:reload_callback` in this project will call `:reload_current_scene` on the `Nav` component
5. This calls `Process.kill/2` on the current scene process and the scene process dies
6. The current scene's supervisor restarts the current scene with the new code that you just wrote

# Adding your own scene

1. Create your new Scenic.Scene
2. In your `init/2` function call `Process.register(self(), __MODULE__)`
3. In your `Scenic.Graph` instance add the `ScenicStarter.Component.Nav` component
4. Optionally add your new scene to the dropdown list in the `ScenicStarter.Component.Nav` component
5. Optionally, if you want your new scene to load on startup then add set it as the second or only scene in `config/config.exs` in the `:default_scene` tuple
