defmodule Chuck.MixProject do
  use Mix.Project

  def project do
    [
      app: :chuck,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {Chuck.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:mojito, "~> 0.5.0"},
      {:plug_cowboy, "~> 2.1.2"}
    ]
  end
end
