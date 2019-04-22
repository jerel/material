defmodule Material.Scene.Sensor do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias Scenic.Sensor
  alias Scenic.Component.Modal

  import Scenic.Primitives
  import Scenic.Components

  alias Material.Component.Nav
  alias Material.Component.Notes

  @body_offset 80
  @font_size 160
  @degrees "°"

  @notes """
    \"Sensor\" is a simple scene that displays data from a simulated sensor.
    The sensor is in /lib/sensors/temperature and uses Scenic.Sensor
    The buttons are placeholders showing custom alignment.
  """

  @maintenance_text """
  Switching to maintenance mode will engage the secondary
  power bus and initiate hibernation sequence.
  """

  @moduledoc """
  This version of `Sensor` illustrates using spec functions to
  construct the display graph. Compare this with `Sensor` which uses
  anonymous functions.
  """

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
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
                id: :open_maintenance_modal,
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

    # subscribe to the simulated temperature sensor
    Sensor.subscribe(:temperature)

    {:ok, graph, push: graph}
  end

  def filter_event({:click, :open_settings_modal}, _, graph) do
    graph = Modal.open(graph, {Material.Component.Notes, "Test"}, size: {0.80, 0.80})

    {:noreply, graph}
  end

  def filter_event({:click, :open_maintenance_modal}, _, graph) do
    maintenance = fn graph ->
      graph
      |> text("Enter maintenance mode?", translate: {20, 40}, fill: {0, 0, 0}, font_size: 26)
      |> text(@maintenance_text, translate: {20, 90}, fill: {0, 0, 0}, font_size: 18)
      |> button("CANCEL", id: :dismiss_modal, translate: {270, 150}, theme: :text)
      |> button("OK", id: :proceed, translate: {385, 150}, theme: :text)
    end

    # percentage sizing
    # {:noreply, Modal.open(graph, maintenance, size: {0.80, 0.60})}
    {:noreply, Modal.open(graph, maintenance, size: {450, 200})}
  end

  def filter_event({:modal, {:click, :dismiss_modal}}, _, graph) do
    graph = Modal.dismiss(graph)

    {:halt, graph, push: graph}
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
