defmodule TMI.MixProject do
  use Mix.Project

  def project do
    [
      app: :tmi,
      version: "0.6.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "tmi.ex",
      source_url: "https://github.com/ryanwinchester/tmi.ex",
      homepage_url: "https://github.com/ryanwinchester/tmi.ex",
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, "~> 1.0"},
      {:exirc, "~> 2.0"},
      {:nimble_parsec, "~> 1.0"},
      {:req, "~> 0.4"},
      {:websockex, "~> 0.4.3"},

      # Dev
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Connect to and interact with Twitch chat from Elixir.
    """
  end

  defp docs do
    [
      main: "readme",
      # logo: "path/to/logo.png",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      name: "tmi",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/ryanwinchester/tmi.ex"
      },
      files: ["README.md", "mix*", "lib/**/*.ex"]
    ]
  end
end
