defmodule Protobuf.MixProject do
  use Mix.Project

  def project do
    [
      app: :protobuf,
      version: "0.1.0",
      elixir: "~> 1.9-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: :dev, runtime: false},
      {:jason, "~> 1.1", only: [:dev, :test]},
      {:ecto, "~> 3.1"}
    ]
  end
end
