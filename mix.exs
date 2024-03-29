defmodule Material.MixProject do
  use Mix.Project

  def project do
    [
      app: :material,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Material, []},
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, github: "jerel/scenic", branch: "modal", override: true},
      {:scenic_driver_glfw, "~> 0.10"},

      # These deps are optional and are included as they are often used.
      # If your app doesn't need them, they are safe to remove.
      {:scenic_sensor, "~> 0.7"},
      {:scenic_clock, "~> 0.10"}
    ]
  end
end
