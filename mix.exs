defmodule Fibz.MixProject do
  use Mix.Project

  def project do
    [
      app: :fibz,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Fibz, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.3", only: :test},
      # Credo has an issue on Elixir 1.6 - see https://github.com/rrrene/credo/issues/463
      # pull from master until new fixed version is released.
      {:credo, github: "rrrene/credo", only: [:dev, :test], runtime: false}
    ]
  end
end
